#!/bin/bash

# Ethereum Mainnet Deployment Script
# This script deploys the PaymentGateway contract to Ethereum mainnet

set -e

echo "=========================================="
echo "Ethereum Mainnet PaymentGateway Deployment"
echo "=========================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with the required variables."
    exit 1
fi

# Source environment variables
source .env

# Check required variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$ETHEREUM_RPC_URL" ]; then
    echo "❌ Error: ETHEREUM_RPC_URL not set in .env"
    echo "Please add ETHEREUM_RPC_URL to your .env file"
    echo "Example: ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID"
    exit 1
fi

if [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "⚠️  Warning: ETHERSCAN_API_KEY not set. Contract will not be verified."
    VERIFY_FLAG=""
else
    VERIFY_FLAG="--verify --verifier-url https://api.etherscan.io/api --verifier ethereum"
fi

echo ""
echo "📋 Deployment Configuration:"
echo "  Network: Ethereum Mainnet (Chain ID: 1)"
echo "  RPC URL: $ETHEREUM_RPC_URL"
echo "  Owner: ${ETHEREUM_OWNER_ADDRESS:-Deployer address}"
echo "  Verification: ${VERIFY_FLAG:-Disabled}"
echo ""

read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 1
fi

echo ""
echo "🚀 Deploying contract..."
echo ""

forge script script/DeployEthereum.s.sol:DeployEthereumScript \
  --rpc-url "$ETHEREUM_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  $VERIFY_FLAG \
  -vvvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the deployed contract address from above"
echo "2. Update ethereum-tokens-database.json with the contract address"
echo ""

