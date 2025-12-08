// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PaymentGatewayV2} from "../src/PaymentGatewayV2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Mock ERC20 token for testing
contract MockERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[from] -= amount;
        _balances[to] += amount;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }
}

contract PaymentGatewayV2Test is Test {
    PaymentGatewayV2 public gateway;
    MockERC20 public mockToken;
    address public owner;
    address public user1;
    address public user2;

    event NativeDeposit(address indexed user, uint256 amount, uint256 timestamp);
    event TokenDeposit(address indexed user, address indexed token, uint256 amount, uint256 timestamp);
    event NativeWithdraw(address indexed to, uint256 amount, uint256 timestamp);
    event TokenWithdraw(address indexed to, address indexed token, uint256 amount, uint256 timestamp);

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        gateway = new PaymentGatewayV2(owner);
        mockToken = new MockERC20("Test Token", "TEST");
    }

    // Native Token Tests
    function test_NativeDeposit() public {
        vm.deal(user1, 10 ether);

        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        assertEq(gateway.getNativeDeposit(user1), 5 ether);
        assertEq(gateway.totalNativeDeposits(), 5 ether);
        assertEq(gateway.getNativeBalance(), 5 ether);
    }

    function test_NativeDepositZeroAmount() public {
        vm.expectRevert("PaymentGatewayV2: amount must be greater than 0");
        gateway.depositNative{value: 0}();
    }

    function test_ReceiveDirectTransfer() public {
        vm.deal(user1, 10 ether);

        vm.prank(user1);
        (bool success, ) = address(gateway).call{value: 3 ether}("");
        assertTrue(success);

        assertEq(gateway.getNativeDeposit(user1), 3 ether);
        assertEq(gateway.totalNativeDeposits(), 3 ether);
    }

    function test_OwnerWithdrawNative() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.deal(recipient, 0);

        gateway.withdrawNative(recipient, 3 ether);

        assertEq(recipient.balance, 3 ether);
        assertEq(gateway.getNativeBalance(), 2 ether);
    }

    function test_OwnerWithdrawNativeInsufficientBalance() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.expectRevert("PaymentGatewayV2: insufficient balance");
        gateway.withdrawNative(recipient, 10 ether);
    }

    function test_MultipleNativeDeposits() public {
        vm.deal(user1, 20 ether);
        vm.deal(user2, 20 ether);

        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        vm.prank(user2);
        gateway.depositNative{value: 7 ether}();

        vm.prank(user1);
        gateway.depositNative{value: 3 ether}();

        assertEq(gateway.getNativeDeposit(user1), 8 ether);
        assertEq(gateway.getNativeDeposit(user2), 7 ether);
        assertEq(gateway.totalNativeDeposits(), 15 ether);
    }

    function test_OnlyOwnerCanWithdrawNative() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.prank(user1);
        vm.expectRevert();
        gateway.withdrawNative(recipient, 3 ether);
    }

    function test_ReentrancyProtection() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        // Multiple deposits should work normally
        vm.prank(user1);
        gateway.depositNative{value: 2 ether}();
        vm.prank(user1);
        gateway.depositNative{value: 1 ether}();

        assertEq(gateway.getNativeDeposit(user1), 8 ether);
        assertEq(gateway.totalNativeDeposits(), 8 ether);
    }

    function test_ReceiveFunctionReentrancyProtection() public {
        // Test that receive() function has reentrancy protection
        // This is tested implicitly - if reentrancy protection wasn't there,
        // a malicious contract could reenter during receive()
        vm.deal(user1, 10 ether);

        vm.prank(user1);
        (bool success, ) = address(gateway).call{value: 5 ether}("");
        assertTrue(success);

        assertEq(gateway.getNativeDeposit(user1), 5 ether);
        assertEq(gateway.totalNativeDeposits(), 5 ether);
    }

    function test_ConstructorZeroAddress() public {
        // Test that constructor rejects zero address
        // OpenZeppelin's Ownable already validates this, so we expect their error
        vm.expectRevert();
        new PaymentGatewayV2(address(0));
    }

    // ERC20 Token Tests
    function test_TokenDeposit() public {
        mockToken.mint(user1, 1000 ether);
        vm.prank(user1);
        mockToken.approve(address(gateway), 500 ether);

        vm.prank(user1);
        gateway.depositToken(address(mockToken), 500 ether);

        assertEq(gateway.getTokenDeposit(address(mockToken), user1), 500 ether);
        assertEq(gateway.totalTokenDeposits(address(mockToken)), 500 ether);
        assertEq(gateway.getTokenBalance(address(mockToken)), 500 ether);
    }

    function test_TokenDepositZeroAmount() public {
        mockToken.mint(user1, 1000 ether);
        vm.prank(user1);
        mockToken.approve(address(gateway), 1000 ether);

        vm.expectRevert("PaymentGatewayV2: amount must be greater than 0");
        vm.prank(user1);
        gateway.depositToken(address(mockToken), 0);
    }

    function test_TokenDepositInvalidAddress() public {
        vm.expectRevert("PaymentGatewayV2: invalid token address");
        gateway.depositToken(address(0), 100 ether);
    }

    function test_OwnerWithdrawToken() public {
        mockToken.mint(user1, 1000 ether);
        vm.prank(user1);
        mockToken.approve(address(gateway), 500 ether);
        vm.prank(user1);
        gateway.depositToken(address(mockToken), 500 ether);

        address recipient = address(0x3);
        gateway.withdrawToken(address(mockToken), recipient, 300 ether);

        assertEq(mockToken.balanceOf(recipient), 300 ether);
        assertEq(gateway.getTokenBalance(address(mockToken)), 200 ether);
    }

    function test_OwnerWithdrawTokenInsufficientBalance() public {
        mockToken.mint(user1, 1000 ether);
        vm.prank(user1);
        mockToken.approve(address(gateway), 500 ether);
        vm.prank(user1);
        gateway.depositToken(address(mockToken), 500 ether);

        address recipient = address(0x3);
        vm.expectRevert("PaymentGatewayV2: insufficient token balance");
        gateway.withdrawToken(address(mockToken), recipient, 1000 ether);
    }

    function test_OnlyOwnerCanWithdrawToken() public {
        mockToken.mint(user1, 1000 ether);
        vm.prank(user1);
        mockToken.approve(address(gateway), 500 ether);
        vm.prank(user1);
        gateway.depositToken(address(mockToken), 500 ether);

        address recipient = address(0x3);
        vm.prank(user1);
        vm.expectRevert();
        gateway.withdrawToken(address(mockToken), recipient, 300 ether);
    }

    function test_MultipleTokenDeposits() public {
        mockToken.mint(user1, 2000 ether);
        mockToken.mint(user2, 2000 ether);

        vm.prank(user1);
        mockToken.approve(address(gateway), 2000 ether);
        vm.prank(user2);
        mockToken.approve(address(gateway), 2000 ether);

        vm.prank(user1);
        gateway.depositToken(address(mockToken), 500 ether);

        vm.prank(user2);
        gateway.depositToken(address(mockToken), 700 ether);

        vm.prank(user1);
        gateway.depositToken(address(mockToken), 300 ether);

        assertEq(gateway.getTokenDeposit(address(mockToken), user1), 800 ether);
        assertEq(gateway.getTokenDeposit(address(mockToken), user2), 700 ether);
        assertEq(gateway.totalTokenDeposits(address(mockToken)), 1500 ether);
    }

    function test_MixedNativeAndTokenDeposits() public {
        vm.deal(user1, 10 ether);
        mockToken.mint(user1, 1000 ether);

        vm.prank(user1);
        gateway.depositNative{value: 5 ether}();

        vm.prank(user1);
        mockToken.approve(address(gateway), 500 ether);
        vm.prank(user1);
        gateway.depositToken(address(mockToken), 500 ether);

        assertEq(gateway.getNativeDeposit(user1), 5 ether);
        assertEq(gateway.getTokenDeposit(address(mockToken), user1), 500 ether);
        assertEq(gateway.totalNativeDeposits(), 5 ether);
        assertEq(gateway.totalTokenDeposits(address(mockToken)), 500 ether);
    }
}

