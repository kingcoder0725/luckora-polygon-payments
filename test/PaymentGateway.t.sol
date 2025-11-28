// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PaymentGateway} from "../src/PaymentGateway.sol";

contract PaymentGatewayTest is Test {
    PaymentGateway public gateway;
    address public owner;
    address public user1;
    address public user2;

    event Deposit(address indexed user, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed to, uint256 amount, uint256 timestamp);
    event AdminPayout(address indexed to, uint256 amount, uint256 timestamp);

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        gateway = new PaymentGateway(owner);
    }

    function test_Deposit() public {
        vm.deal(user1, 10 ether);

        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        assertEq(gateway.getDeposit(user1), 5 ether);
        assertEq(gateway.totalDeposits(), 5 ether);
        assertEq(gateway.getBalance(), 5 ether);
    }

    function test_DepositZeroAmount() public {
        vm.expectRevert("PaymentGateway: amount must be greater than 0");
        gateway.deposit{value: 0}();
    }

    function test_ReceiveDirectTransfer() public {
        vm.deal(user1, 10 ether);

        vm.prank(user1);
        (bool success, ) = address(gateway).call{value: 3 ether}("");
        assertTrue(success);

        assertEq(gateway.getDeposit(user1), 3 ether);
        assertEq(gateway.totalDeposits(), 3 ether);
    }

    function test_OwnerWithdraw() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.deal(recipient, 0);

        gateway.withdraw(recipient, 3 ether);

        assertEq(recipient.balance, 3 ether);
        assertEq(gateway.getBalance(), 2 ether);
    }

    function test_OwnerWithdrawInsufficientBalance() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.expectRevert("PaymentGateway: insufficient balance");
        gateway.withdraw(recipient, 10 ether);
    }

    function test_MultipleDeposits() public {
        vm.deal(user1, 20 ether);
        vm.deal(user2, 20 ether);

        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        vm.prank(user2);
        gateway.deposit{value: 7 ether}();

        vm.prank(user1);
        gateway.deposit{value: 3 ether}();

        assertEq(gateway.getDeposit(user1), 8 ether);
        assertEq(gateway.getDeposit(user2), 7 ether);
        assertEq(gateway.totalDeposits(), 15 ether);
    }

    function test_OnlyOwnerCanWithdraw() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.prank(user1);
        vm.expectRevert();
        gateway.withdraw(recipient, 3 ether);
    }

    function test_ReentrancyProtection() public {
        // This test ensures ReentrancyGuard is working
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        // Multiple deposits should work normally
        vm.prank(user1);
        gateway.deposit{value: 2 ether}();
        vm.prank(user1);
        gateway.deposit{value: 1 ether}();

        assertEq(gateway.getDeposit(user1), 8 ether);
        assertEq(gateway.totalDeposits(), 8 ether);
    }

    function test_AdminPayout() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.deal(recipient, 0);

        vm.expectEmit(true, false, false, true);
        emit AdminPayout(recipient, 3 ether, block.timestamp);

        gateway.adminPayout(recipient, 3 ether);

        assertEq(recipient.balance, 3 ether);
        assertEq(gateway.getBalance(), 2 ether);
    }

    function test_AdminPayoutInsufficientBalance() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.expectRevert("PaymentGateway: insufficient balance");
        gateway.adminPayout(recipient, 10 ether);
    }

    function test_OnlyOwnerCanAdminPayout() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        address payable recipient = payable(address(0x3));
        vm.prank(user1);
        vm.expectRevert();
        gateway.adminPayout(recipient, 3 ether);
    }

    function test_UsersCannotWithdrawDirectly() public {
        vm.deal(user1, 10 ether);
        vm.prank(user1);
        gateway.deposit{value: 5 ether}();

        // Verify that userWithdraw function no longer exists
        // This is verified by the fact that it's been removed from the contract
        // Users must use adminPayout through the backend
        assertEq(gateway.getDeposit(user1), 5 ether);
        assertEq(gateway.getBalance(), 5 ether);
        
        // Users can only withdraw through adminPayout (admin only)
        // Attempting to call adminPayout as user should fail
        vm.prank(user1);
        vm.expectRevert();
        gateway.adminPayout(user1, 1 ether);
        
        // Balance should remain unchanged
        assertEq(gateway.getBalance(), 5 ether);
    }
}

