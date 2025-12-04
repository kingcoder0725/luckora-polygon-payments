#!/bin/bash

# BSC/BEP20 Deployment Script
# This script deploys the PaymentGateway contract to BSC mainnet

set -e

echo "=========================================="
echo "BSC/BEP20 PaymentGateway Deployment"
echo "=========================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with the required variables."
    echo "See DEPLOYMENT.md for required environment variables."
    exit 1
fi

# Source environment variables
source .env

# Check required variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ Error: PRIVATE_KEY not set in .env"
    exit 1
fi

if [ -z "$BSC_RPC_URL" ]; then
    echo "❌ Error: BSC_RPC_URL not set in .env"
    echo "Please add BSC_RPC_URL to your .env file"
    exit 1
fi

if [ -z "$BSCSCAN_API_KEY" ]; then
    echo "⚠️  Warning: BSCSCAN_API_KEY not set. Contract will not be verified."
    VERIFY_FLAG=""
else
    VERIFY_FLAG="--verify --verifier-url https://api.bscscan.com/api --verifier bsc"
fi

echo ""
echo "📋 Deployment Configuration:"
echo "  Network: BSC Mainnet (Chain ID: 56)"
echo "  RPC URL: $BSC_RPC_URL"
echo "  Owner: ${BSC_OWNER_ADDRESS:-Deployer address}"
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

forge script script/DeployBSC.s.sol:DeployBSCScript \
  --rpc-url "$BSC_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  $VERIFY_FLAG \
  -vvvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the deployed contract address from above"
echo "2. Update your backend .env with:"
echo "   BSC_CONTRACT_ADDRESS=<deployed_address>"
echo "   BSC_RPC_URL=$BSC_RPC_URL"
echo "   BSC_ADMIN_PRIVATE_KEY=$PRIVATE_KEY"
echo "   BSC_CHAIN_ID=56"
echo ""

