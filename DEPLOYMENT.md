# PaymentGateway Deployment

## Amoy Testnet Deployment

### Deployment Details

- **Contract Address**: `0x02E2EA37095BBA1269d0e8e89bd2c8f72E3Bbc9B`
- **Network**: Polygon Amoy Testnet (Chain ID: 80002)
- **Owner Address**: `0xa57D5fb4d4d8f7548a78f175Af481C42cb24e39e`
- **Deployer Address**: `0xa57D5fb4d4d8f7548a78f175Af481C42cb24e39e`
- **Verification**: ✅ Verified on [PolygonScan Amoy](https://amoy.polygonscan.com/address/0x02e2ea37095bba1269d0e8e89bd2c8f72e3bbc9b)

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
   - Set `POLYGON_CONTRACT_ADDRESS=0x02E2EA37095BBA1269d0e8e89bd2c8f72E3Bbc9B`
   - Ensure `POLYGON_RPC_URL` points to Amoy testnet
   - Ensure `POLYGON_ADMIN_PRIVATE_KEY` matches the deployer's private key

2. **Test the Contract**
   - Test deposit functionality
   - Test withdraw functionality
   - Verify event emission

3. **Mainnet Deployment** (when ready)
   - Update RPC URL to Polygon mainnet
   - Update API key for PolygonScan mainnet
   - Deploy with same script using mainnet configuration

## Contract Functions

**PaymentGateway (V1 - Native tokens only):**
- `deposit()` - Users can deposit native MATIC/BNB
- `withdraw(address to, uint256 amount)` - Owner can withdraw funds
- `getDeposit(address user)` - Get user's deposit balance
- `getBalance()` - Get contract's total balance

**PaymentGatewayV2 (Supports native + ERC20/BEP20 tokens like USDT):**
- `depositNative()` - Users can deposit native MATIC/BNB
- `depositToken(address token, uint256 amount)` - Users can deposit ERC20/BEP20 tokens (e.g., USDT)
- `withdrawNative(address to, uint256 amount)` - Owner can withdraw native tokens
- `withdrawToken(address token, address to, uint256 amount)` - Owner can withdraw ERC20/BEP20 tokens
- `getNativeDeposit(address user)` - Get user's native token deposit balance
- `getTokenDeposit(address token, address user)` - Get user's token deposit balance
- `getNativeBalance()` - Get contract's native token balance
- `getTokenBalance(address token)` - Get contract's token balance
- `setTokenWhitelist(address token, bool whitelisted)` - Owner can whitelist/blacklist tokens (optional security)

## Security Notes

- Contract uses OpenZeppelin's `Ownable` for access control
- Contract uses OpenZeppelin's `ReentrancyGuard` for security
- Only owner can call `withdraw`

---

## BSC (BEP20) Mainnet Deployment

### Deployment Details

- **Network**: Binance Smart Chain (BSC) Mainnet (Chain ID: 56)
- **Native Token**: BNB
- **Owner Address**: Set via `BSC_OWNER_ADDRESS` environment variable

### Deployment Command

```bash
cd polygon-payments
source .env
forge script script/DeployBSC.s.sol:DeployBSCScript \
  --rpc-url $BSC_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier-url https://api.bscscan.com/api \
  --verifier bsc \
  -vvvv
```

### Environment Variables Required

Add these to your `.env` file (keep existing `PRIVATE_KEY` and `API_KEY`):

```bash
# Existing variables (DO NOT CHANGE)
PRIVATE_KEY=your_private_key_here
POLYGONSCAN_API_KEY=your_api_key_here

# BSC/BEP20 Configuration
BSC_RPC_URL=https://bsc-dataseed1.binance.org/
# OR use a provider like:
# BSC_RPC_URL=https://bsc-dataseed1.defibit.io/
# BSC_RPC_URL=https://bsc-dataseed.binance.org/
# BSC_RPC_URL=https://rpc.ankr.com/bsc

BSC_TESTNET_RPC_URL=https://data-seed-prebsc-1-s1.binance.org:8545/
# OR use:
# BSC_TESTNET_RPC_URL=https://data-seed-prebsc-2-s1.binance.org:8545/

# BSCScan API Key (same as POLYGONSCAN_API_KEY or separate)
BSCSCAN_API_KEY=your_bscscan_api_key_here

# Owner address (optional, defaults to deployer address)
BSC_OWNER_ADDRESS=0xYourOwnerAddressHere
```

### BSC Testnet Deployment (Optional - for testing)

```bash
cd polygon-payments
source .env
forge script script/DeployBSC.s.sol:DeployBSCScript \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier-url https://api-testnet.bscscan.com/api \
  --verifier bsc_testnet \
  -vvvv
```

### Contract Verification

After deployment, the contract will be automatically verified on BSCScan if you:
1. Have `BSCSCAN_API_KEY` set in `.env`
2. Use the `--verify` flag
3. Specify the correct `--verifier-url` and `--verifier`

### Backend Configuration After Deployment

After successful deployment, update your backend `.env`:

```bash
# BSC/BEP20 Configuration
BSC_CONTRACT_ADDRESS=<deployed_contract_address>
BSC_RPC_URL=https://bsc-dataseed1.binance.org/
BSC_ADMIN_PRIVATE_KEY=<same_as_PRIVATE_KEY_or_owner_key>
BSC_CHAIN_ID=56
```

### Network Information

- **BSC Mainnet Chain ID**: 56
- **BSC Testnet Chain ID**: 97
- **Native Token**: BNB
- **Block Explorer**: https://bscscan.com
- **Testnet Explorer**: https://testnet.bscscan.com

### RPC Endpoints

**Mainnet:**
- `https://bsc-dataseed1.binance.org/`
- `https://bsc-dataseed1.defibit.io/`
- `https://bsc-dataseed.binance.org/`
- `https://rpc.ankr.com/bsc`

**Testnet:**
- `https://data-seed-prebsc-1-s1.binance.org:8545/`
- `https://data-seed-prebsc-2-s1.binance.org:8545/`

---

## Base Mainnet Deployment

### Deployment Command

```bash
cd polygon-payments
source .env
forge script script/DeployBase.s.sol:DeployBaseScript \
  --rpc-url $BASE_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier-url https://api.basescan.org/api \
  --verifier base \
  -vvvv
```

### Environment Variables Required

Add these to your `.env` file (keep existing `PRIVATE_KEY`):

```bash
# Base L2 Configuration
BASE_RPC_URL=https://mainnet.base.org
# Optional Base Sepolia for testing
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org

# BaseScan API Key (for verification)
BASESCAN_API_KEY=your_basescan_api_key_here

# Owner address (optional, defaults to deployer address)
BASE_OWNER_ADDRESS=0xYourOwnerAddressHere
```

### Backend Configuration After Deployment

After successful deployment, update your backend `.env`:

```bash
# Base L2 Configuration
BASE_CONTRACT_ADDRESS=<deployed_contract_address>
BASE_RPC_URL=https://mainnet.base.org
BASE_ADMIN_PRIVATE_KEY=<same_as_PRIVATE_KEY_or_owner_key>
BASE_CHAIN_ID=8453
```

### Network Information

- **Base Mainnet Chain ID**: 8453
- **Native Token**: ETH
- **Block Explorer**: https://basescan.org
- **RPC Endpoint**: https://mainnet.base.org

---

## Polygon Mainnet Deployment

### Deployment Command

```bash
cd ether-payments
source .env
forge script script/DeployPolygon.s.sol:DeployPolygonScript \
  --rpc-url $POLYGON_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier-url https://api.polygonscan.com/api \
  --verifier polygonscan \
  -vvvv
```

### Environment Variables Required

Add these to your `.env` file (keep existing `PRIVATE_KEY`):

```bash
# Polygon Mainnet Configuration
POLYGON_RPC_URL=https://polygon-rpc.com
# OR use a provider like:
# POLYGON_RPC_URL=https://rpc.ankr.com/polygon
# POLYGON_RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR_API_KEY

# PolygonScan API Key (for verification)
POLYGONSCAN_API_KEY=your_polygonscan_api_key_here

# Owner address (optional, defaults to deployer address)
POLYGON_OWNER_ADDRESS=0xYourOwnerAddressHere
```

### Backend Configuration After Deployment

After successful deployment, update your backend `.env`:

```bash
# Polygon Mainnet Configuration
POLYGON_CONTRACT_ADDRESS=<deployed_contract_address>
POLYGON_RPC_URL=https://polygon-rpc.com
POLYGON_ADMIN_PRIVATE_KEY=<same_as_PRIVATE_KEY_or_owner_key>
POLYGON_CHAIN_ID=137
```

### Network Information

- **Polygon Mainnet Chain ID**: 137
- **Native Token**: MATIC
- **Block Explorer**: https://polygonscan.com
- **RPC Endpoints**: 
  - `https://polygon-rpc.com`
  - `https://rpc.ankr.com/polygon`
  - `https://polygon-mainnet.g.alchemy.com/v2/YOUR_API_KEY`

### Common Polygon Token Addresses

**Mainnet:**
- USDT: `0xc2132D05D31c914a87C6611C10748AEb04B58e8F`
- USDC: `0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174`
- WBTC: `0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6`
- WETH: `0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619`
- AAVE: `0xD6DF932A45C0f255f85145f286eA0b292b21C90B`
- CRV: `0x172370d5Cd63279eFa6d502DAB29171933a610AF`
- LINK: `0x53e0bca35ec356bd5dddfebbd1fc0fd03fabad39`

---

## PaymentGatewayV2 - USDT/ERC20 Token Support

### Overview

**PaymentGatewayV2** extends the original contract to support both:
- ✅ **Native tokens**: BNB (BSC), MATIC (Polygon)
- ✅ **ERC20/BEP20 tokens**: USDT, USDC, BUSD, and any other ERC20/BEP20 token

### Key Features

1. **Dual Token Support**: Handles both native tokens and ERC20/BEP20 tokens
2. **Separate Tracking**: Tracks deposits separately for native tokens and each token type
3. **Token Whitelisting**: Optional security feature to restrict which tokens can be deposited
4. **SafeERC20**: Uses OpenZeppelin's SafeERC20 for secure token transfers

### BSC Mainnet Deployment (V2 with USDT support)

```bash
cd polygon-payments
source .env
forge script script/DeployBSCV2.s.sol:DeployBSCV2Script \
  --rpc-url $BSC_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier-url https://api.bscscan.com/api \
  --verifier bsc \
  -vvvv
```

### Common BSC Token Addresses

**Mainnet:**
- USDT (BEP20): `0x55d398326f99059fF775485246999027B3197955`
- USDC (BEP20): `0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d`
- BUSD (BEP20): `0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56`

**Testnet:**
- USDT (BEP20): `0x337610d27c682E347C9cD60BD4b3b107C9d34dDd`
- USDC (BEP20): `0x64544969ed7EBf5f083679233325356EbE738930`

### Usage Example

**Deposit USDT:**
```solidity
// 1. User approves the contract to spend USDT
IERC20 usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
usdt.approve(paymentGatewayAddress, amount);

// 2. User deposits USDT
PaymentGatewayV2(paymentGatewayAddress).depositToken(
    0x55d398326f99059fF775485246999027B3197955, // USDT address
    amount
);
```

**Deposit Native BNB:**
```solidity
// User sends BNB directly or calls depositNative()
PaymentGatewayV2(paymentGatewayAddress).depositNative{value: amount}();
```

### Backend Configuration (V2)

After deploying PaymentGatewayV2, update your backend:

```bash
# BSC/BEP20 Configuration
BSC_CONTRACT_ADDRESS=<deployed_v2_contract_address>
BSC_RPC_URL=https://bsc-dataseed1.binance.org/
BSC_ADMIN_PRIVATE_KEY=<same_as_PRIVATE_KEY_or_owner_key>
BSC_CHAIN_ID=56

# USDT Token Address (BSC Mainnet)
USDT_BSC_ADDRESS=0x55d398326f99059fF775485246999027B3197955
```

