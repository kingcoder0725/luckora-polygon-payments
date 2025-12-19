## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## PaymentGateway Deployment

This project contains a PaymentGateway contract that can be deployed to:
- **Polygon** (MATIC)
- **BSC/BEP20** (BNB)

### Quick Start

1. **Setup Environment Variables**

   Create a `.env` file in the `polygon-payments` directory:

   ```bash
   # Required (keep existing values)
   PRIVATE_KEY=your_private_key_here
   POLYGONSCAN_API_KEY=your_api_key_here

   # BSC/BEP20 Configuration
   BSC_RPC_URL=https://bsc-dataseed1.binance.org/
   BSCSCAN_API_KEY=your_bscscan_api_key_here
   BSC_OWNER_ADDRESS=0xYourOwnerAddressHere  # Optional
   ```

2. **Deploy to BSC Mainnet**

   **Option A: Using the deployment script (recommended)**
   ```bash
   ./deploy-bsc.sh
   ```

   **Option B: Manual deployment**
   ```bash
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

3. **Deploy to Base Mainnet**
   ```bash
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

4. **Deploy to Polygon (existing)**
   ```bash
   source .env
   forge script script/Deploy.s.sol:DeployScript \
     --rpc-url $AMOY_RPC_URL \
     --private-key $PRIVATE_KEY \
     --broadcast \
     --verify \
     -vvvv
   ```

### Environment Variables

See `DEPLOYMENT.md` for complete environment variable documentation.

**Required for BSC:**
- `PRIVATE_KEY` - Deployer's private key (keep existing)
- `BSC_RPC_URL` - BSC mainnet RPC endpoint
- `BSCSCAN_API_KEY` - BSCScan API key for verification

**Required for Base:**
- `PRIVATE_KEY` - Deployer's private key (keep existing)
- `BASE_RPC_URL` - Base mainnet RPC endpoint (e.g. https://mainnet.base.org)
- `BASESCAN_API_KEY` - BaseScan API key for verification

**Optional:**
- `BSC_OWNER_ADDRESS` - Contract owner address (defaults to deployer)
- `BSC_TESTNET_RPC_URL` - For testnet deployments
- `BASE_OWNER_ADDRESS` - Custom owner address (defaults to deployer)
- `BASE_SEPOLIA_RPC_URL` - For Base Sepolia test deployments

### Network Information

**BSC Mainnet:**
- Chain ID: 56
- Native Token: BNB
- Explorer: https://bscscan.com
- RPC: https://bsc-dataseed1.binance.org/

**BSC Testnet:**
- Chain ID: 97
- Explorer: https://testnet.bscscan.com
- RPC: https://data-seed-prebsc-1-s1.binance.org:8545/

**Base Mainnet:**
- Chain ID: 8453
- Native Token: ETH
- Explorer: https://basescan.org
- RPC: https://mainnet.base.org

### Documentation

For detailed deployment instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md)
