#!/bin/bash

# Base L2 Deployment Script
# Deploys PaymentGatewayV2 to Base mainnet

set -e

echo "=========================================="
echo "Base L2 PaymentGatewayV2 Deployment"
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

if [ -z "$BASE_RPC_URL" ]; then
    echo "❌ Error: BASE_RPC_URL not set in .env"
    echo "Please add BASE_RPC_URL to your .env file"
    exit 1
fi

# Optional verification
if [ -z "$BASESCAN_API_KEY" ]; then
    echo "⚠️  Warning: BASESCAN_API_KEY not set. Contract will not be verified."
    VERIFY_FLAG=""
else
    VERIFY_FLAG="--verify --verifier-url https://api.basescan.org/api --verifier base"
fi

echo ""
echo "📋 Deployment Configuration:"
echo "  Network: Base Mainnet (Chain ID: 8453)"
echo "  RPC URL: $BASE_RPC_URL"
echo "  Owner: ${BASE_OWNER_ADDRESS:-Deployer address}"
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

forge script script/DeployBase.s.sol:DeployBaseScript \
  --rpc-url "$BASE_RPC_URL" \
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
echo "   BASE_CONTRACT_ADDRESS=<deployed_address>"
echo "   BASE_RPC_URL=$BASE_RPC_URL"
echo "   BASE_ADMIN_PRIVATE_KEY=$PRIVATE_KEY"
echo "   BASE_CHAIN_ID=8453"
echo ""

