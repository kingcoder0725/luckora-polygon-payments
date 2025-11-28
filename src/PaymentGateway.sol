// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title PaymentGateway
 * @notice Handles native coin deposits and withdrawals for Polygon (MATIC)
 * @dev Uses OpenZeppelin Ownable and ReentrancyGuard for security
 */
contract PaymentGateway is Ownable, ReentrancyGuard {
    /// @notice Mapping of user address to their total deposits
    mapping(address => uint256) public deposits;

    /// @notice Total amount deposited across all users
    uint256 public totalDeposits;

    /// @notice Emitted when a user deposits native coin
    event Deposit(address indexed user, uint256 amount, uint256 timestamp);

    /// @notice Emitted when owner withdraws funds
    event Withdraw(address indexed to, uint256 amount, uint256 timestamp);

    /// @notice Emitted when a user withdraws their deposit
    event UserWithdraw(address indexed user, uint256 amount, uint256 timestamp);

    /// @notice Emitted when admin performs a payout
    event AdminPayout(address indexed to, uint256 amount, uint256 timestamp);

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Deposit native coin (MATIC) to the gateway
     * @dev Emits Deposit event
     */
    function deposit() external payable nonReentrant {
        require(msg.value > 0, "PaymentGateway: amount must be greater than 0");

        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;

        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @notice Get the deposit balance for a specific user
     * @param user The address to query
     * @return The total amount deposited by the user
     */
    function getDeposit(address user) external view returns (uint256) {
        return deposits[user];
    }

    /**
     * @notice Owner withdraws funds from the gateway
     * @param to Address to receive the funds
     * @param amount Amount to withdraw
     * @dev Only callable by owner, uses ReentrancyGuard
     */
    function withdraw(address payable to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "PaymentGateway: invalid address");
        require(amount > 0, "PaymentGateway: amount must be greater than 0");
        require(address(this).balance >= amount, "PaymentGateway: insufficient balance");

        (bool success, ) = to.call{value: amount}("");
        require(success, "PaymentGateway: transfer failed");

        emit Withdraw(to, amount, block.timestamp);
    }

    /**
     * @notice User withdraws their own deposit
     * @param amount Amount to withdraw
     * @dev Uses ReentrancyGuard for security
     */
    function userWithdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "PaymentGateway: amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "PaymentGateway: insufficient deposit balance");
        require(address(this).balance >= amount, "PaymentGateway: insufficient contract balance");

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "PaymentGateway: transfer failed");

        emit UserWithdraw(msg.sender, amount, block.timestamp);
    }

    /**
     * @notice Admin payout function - allows owner to payout funds to any address
     * @param to Address to receive the funds
     * @param amount Amount to payout
     * @dev Only callable by owner, uses ReentrancyGuard
     */
    function adminPayout(address to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "PaymentGateway: invalid address");
        require(amount > 0, "PaymentGateway: amount must be greater than 0");
        require(address(this).balance >= amount, "PaymentGateway: insufficient balance");

        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "PaymentGateway: transfer failed");

        emit AdminPayout(to, amount, block.timestamp);
    }

    /**
     * @notice Get the contract's native coin balance
     * @return The balance of the contract
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Receive function to allow direct transfers
     * @dev Automatically processes as a deposit
     */
    receive() external payable {
        deposits[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
}

