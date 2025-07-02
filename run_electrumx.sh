#!/bin/bash

# ElectrumX Run Script
# This script activates the virtual environment and runs ElectrumX

set -e

echo "🚀 Starting ElectrumX..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run setup_smart.sh first."
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

# Load configuration
if [ -f ".env" ]; then
    echo "📋 Loading configuration from .env..."
    source .env
else
    echo "⚠️ No .env file found. Using default configuration."
    echo "💡 You can copy config_template.env to .env and customize it."
fi

# Check if database directory exists, create if not
if [ ! -d "$DB_DIRECTORY" ]; then
    echo "📁 Creating database directory: $DB_DIRECTORY"
    mkdir -p "$DB_DIRECTORY"
fi

# Display current configuration
echo ""
echo "📋 Current configuration:"
echo "   Database Engine: $DB_ENGINE"
echo "   Database Directory: $DB_DIRECTORY"
echo "   Coin: $COIN"
echo "   Services: $SERVICES"
echo "   Daemon URL: $DAEMON_URL"
echo ""

# Check if daemon URL is set
if [[ "$DAEMON_URL" == *"username:password"* ]]; then
    echo "⚠️  IMPORTANT: You need to configure your Bitcoin daemon connection!"
    echo "   Edit .env and set DAEMON_URL to your actual Bitcoin node."
    echo "   Example: export DAEMON_URL=\"http://user:pass@localhost:8332/\""
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "🔌 Starting ElectrumX server..."
echo "   Press Ctrl+C to stop"
echo ""

# Run ElectrumX
electrumx_server
