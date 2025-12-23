#!/bin/bash

# Polygon Mainnet Deployment Script
# This script deploys the PaymentGateway contract to Polygon mainnet

set -e

echo "=========================================="
echo "Polygon Mainnet PaymentGateway Deployment"
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

if [ -z "$POLYGON_RPC_URL" ]; then
    echo "❌ Error: POLYGON_RPC_URL not set in .env"
    echo "Please add POLYGON_RPC_URL to your .env file"
    echo "Example: POLYGON_RPC_URL=https://polygon-rpc.com"
    exit 1
fi

if [ -z "$POLYGONSCAN_API_KEY" ]; then
    echo "⚠️  Warning: POLYGONSCAN_API_KEY not set. Contract will not be verified."
    VERIFY_FLAG=""
else
    VERIFY_FLAG="--verify --verifier-url https://api.polygonscan.com/api --verifier polygonscan"
fi

echo ""
echo "📋 Deployment Configuration:"
echo "  Network: Polygon Mainnet (Chain ID: 137)"
echo "  RPC URL: $POLYGON_RPC_URL"
echo "  Owner: ${POLYGON_OWNER_ADDRESS:-Deployer address}"
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

forge script script/DeployPolygon.s.sol:DeployPolygonScript \
  --rpc-url "$POLYGON_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast \
  $VERIFY_FLAG \
  -vvvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the deployed contract address from above"
echo "2. Update polygon-tokens-database.json with the contract address"
echo "3. Update your backend .env with:"
echo "   POLYGON_CONTRACT_ADDRESS=<deployed_address>"
echo "   POLYGON_RPC_URL=$POLYGON_RPC_URL"
echo "   POLYGON_ADMIN_PRIVATE_KEY=$PRIVATE_KEY"
echo "   POLYGON_CHAIN_ID=137"
echo ""

