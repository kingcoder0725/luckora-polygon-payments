// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title PaymentGatewayV2
 * @notice Handles native coin and ERC20/BEP20 token deposits and withdrawals
 * @dev Supports MATIC/BNB (native) and USDT/other tokens (ERC20/BEP20)
 * @dev Uses OpenZeppelin Ownable, ReentrancyGuard, and SafeERC20 for security
 */
contract PaymentGatewayV2 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Mapping of user address to their total native token deposits
    mapping(address => uint256) public nativeDeposits;

    /// @notice Mapping of token address => user address => deposit amount
    mapping(address => mapping(address => uint256)) public tokenDeposits;

    /// @notice Mapping to track if a token is whitelisted (optional security feature)
    mapping(address => bool) public whitelistedTokens;

    /// @notice Total amount of native tokens deposited across all users
    uint256 public totalNativeDeposits;

    /// @notice Mapping of token address => total deposits
    mapping(address => uint256) public totalTokenDeposits;

    /// @notice Emitted when a user deposits native coin
    event NativeDeposit(address indexed user, uint256 amount, uint256 timestamp);

    /// @notice Emitted when a user deposits ERC20/BEP20 token
    event TokenDeposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    /// @notice Emitted when owner withdraws native tokens
    event NativeWithdraw(address indexed to, uint256 amount, uint256 timestamp);

    /// @notice Emitted when owner withdraws ERC20/BEP20 tokens
    event TokenWithdraw(
        address indexed to,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    /// @notice Emitted when a token is whitelisted/blacklisted
    event TokenWhitelistUpdated(address indexed token, bool whitelisted);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Deposit native coin (MATIC on Polygon, BNB on BSC) to the gateway
     * @dev Emits NativeDeposit event
     */
    function depositNative() external payable nonReentrant {
        require(msg.value > 0, "PaymentGatewayV2: amount must be greater than 0");

        nativeDeposits[msg.sender] += msg.value;
        totalNativeDeposits += msg.value;

        emit NativeDeposit(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @notice Deposit ERC20/BEP20 token (e.g., USDT) to the gateway
     * @param token The token contract address
     * @param amount The amount of tokens to deposit
     * @dev User must approve this contract to spend tokens first
     * @dev Emits TokenDeposit event
     */
    function depositToken(address token, uint256 amount) external nonReentrant {
        require(token != address(0), "PaymentGatewayV2: invalid token address");
        require(amount > 0, "PaymentGatewayV2: amount must be greater than 0");
        
        // Optional: Check if token is whitelisted (if whitelisting is enabled)
        // Uncomment the next line if you want to enforce whitelisting
        // require(whitelistedTokens[token] || whitelistedTokens[address(0)], "PaymentGatewayV2: token not whitelisted");

        IERC20 tokenContract = IERC20(token);
        
        // Transfer tokens from user to this contract
        tokenContract.safeTransferFrom(msg.sender, address(this), amount);

        tokenDeposits[token][msg.sender] += amount;
        totalTokenDeposits[token] += amount;

        emit TokenDeposit(msg.sender, token, amount, block.timestamp);
    }

    /**
     * @notice Get the native token deposit balance for a specific user
     * @param user The address to query
     * @return The total amount of native tokens deposited by the user
     */
    function getNativeDeposit(address user) external view returns (uint256) {
        return nativeDeposits[user];
    }

    /**
     * @notice Get the ERC20/BEP20 token deposit balance for a specific user
     * @param token The token contract address
     * @param user The address to query
     * @return The total amount of tokens deposited by the user
     */
    function getTokenDeposit(address token, address user) external view returns (uint256) {
        return tokenDeposits[token][user];
    }

    /**
     * @notice Owner withdraws native tokens from the gateway
     * @param to Address to receive the funds
     * @param amount Amount to withdraw
     * @dev Only callable by owner, uses ReentrancyGuard
     */
    function withdrawNative(address payable to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "PaymentGatewayV2: invalid address");
        require(amount > 0, "PaymentGatewayV2: amount must be greater than 0");
        require(address(this).balance >= amount, "PaymentGatewayV2: insufficient balance");

        (bool success, ) = to.call{value: amount}("");
        require(success, "PaymentGatewayV2: transfer failed");

        emit NativeWithdraw(to, amount, block.timestamp);
    }

    /**
     * @notice Owner withdraws ERC20/BEP20 tokens from the gateway
     * @param token The token contract address
     * @param to Address to receive the funds
     * @param amount Amount to withdraw
     * @dev Only callable by owner, uses ReentrancyGuard and SafeERC20
     */
    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner nonReentrant {
        require(token != address(0), "PaymentGatewayV2: invalid token address");
        require(to != address(0), "PaymentGatewayV2: invalid address");
        require(amount > 0, "PaymentGatewayV2: amount must be greater than 0");

        IERC20 tokenContract = IERC20(token);
        require(
            tokenContract.balanceOf(address(this)) >= amount,
            "PaymentGatewayV2: insufficient token balance"
        );

        tokenContract.safeTransfer(to, amount);

        emit TokenWithdraw(to, token, amount, block.timestamp);
    }

    /**
     * @notice Get the contract's native token balance
     * @return The balance of the contract
     */
    function getNativeBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Get the contract's ERC20/BEP20 token balance
     * @param token The token contract address
     * @return The balance of the contract for the specified token
     */
    function getTokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
     * @notice Whitelist or blacklist a token (optional security feature)
     * @param token The token contract address
     * @param whitelisted Whether the token should be whitelisted
     * @dev Only callable by owner
     */
    function setTokenWhitelist(address token, bool whitelisted) external onlyOwner {
        whitelistedTokens[token] = whitelisted;
        emit TokenWhitelistUpdated(token, whitelisted);
    }

    /**
     * @notice Receive function to allow direct native token transfers
     * @dev Automatically processes as a native deposit
     */
    receive() external payable {
        nativeDeposits[msg.sender] += msg.value;
        totalNativeDeposits += msg.value;
        emit NativeDeposit(msg.sender, msg.value, block.timestamp);
    }
}

