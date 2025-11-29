# PaymentGateway Deployment

## Amoy Testnet Deployment

### Deployment Details

- **Contract Address**: `0x7044BD47899eFdB66f29abba82662A3BBF5eaC5B`
- **Network**: Polygon Amoy Testnet (Chain ID: 80002)
- **Owner Address**: `0xa57D5fb4d4d8f7548a78f175Af481C42cb24e39e`
- **Deployer Address**: `0xa57D5fb4d4d8f7548a78f175Af481C42cb24e39e`
- **Transaction Hash**: `0x42bf69fd9d3084c9d4f9a28bdab923bd7cb142338936d5a13cfe7a011eb7e3ce`
- **Transaction Link**: [View on PolygonScan Amoy](https://amoy.polygonscan.com/tx/0x42bf69fd9d3084c9d4f9a28bdab923bd7cb142338936d5a13cfe7a011eb7e3ce)
- **Verification**: ✅ Verified on [PolygonScan Amoy](https://amoy.polygonscan.com/address/0x7044bd47899efdb66f29abba82662a3bbf5eac5b)

### Deployment Command

```bash
cd polygon-payments
source .env
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $AMOY_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

### Contract Verification

The contract has been verified on PolygonScan Amoy and is available at:
https://amoy.polygonscan.com/address/0x7044bd47899efdb66f29abba82662a3bbf5eac5b

### Environment Variables Used

- `AMOY_RPC_URL`: RPC endpoint for Amoy testnet
- `PRIVATE_KEY`: Deployer's private key
- `POLYGONSCAN_API_KEY`: API key for contract verification

### Next Steps

1. **Update Backend Configuration**
   - Set `POLYGON_CONTRACT_ADDRESS=0x7044BD47899eFdB66f29abba82662A3BBF5eaC5B`
   - Ensure `POLYGON_RPC_URL` points to Amoy testnet
   - Ensure `POLYGON_ADMIN_PRIVATE_KEY` matches the deployer's private key

2. **Test the Contract**
   - Test deposit functionality
   - Test admin payout functionality
   - Verify event emission

3. **Mainnet Deployment** (when ready)
   - Update RPC URL to Polygon mainnet
   - Update API key for PolygonScan mainnet
   - Deploy with same script using mainnet configuration

## Contract Functions

- `deposit()` - Users can deposit native MATIC
- `adminPayout(address to, uint256 amount)` - Owner can payout to any address
- `getDeposit(address user)` - Get user's deposit balance
- `getBalance()` - Get contract's total balance

## Security Notes

- Contract uses OpenZeppelin's `Ownable` for access control
- Contract uses OpenZeppelin's `ReentrancyGuard` for security
- Only owner can call `adminPayout`
- Users cannot withdraw directly - all withdrawals go through admin

