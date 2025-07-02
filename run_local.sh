#!/bin/bash

# ElectrumX Local Runner Script

set -e

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run setup_local.sh first."
    exit 1
fi

# Activate virtual environment
echo "🔄 Activating virtual environment..."
source venv/bin/activate

# Check if config file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Configuration file .env not found."
    echo "📋 Copying template configuration..."
    cp config_template.env .env
    echo "✏️  Please edit .env file with your Bitcoin daemon settings before running."
    echo "📝 Minimum required settings:"
    echo "   - DAEMON_URL: Your Bitcoin daemon RPC URL"
    echo "   - DB_DIRECTORY: Where to store the database"
    echo ""
    echo "Example DAEMON_URL formats:"
    echo "   http://username:password@localhost:8332/  (Bitcoin Core)"
    echo "   http://user:pass@localhost:18332/          (Bitcoin Testnet)"
    echo ""
    read -p "Do you want to edit the config now? (y/n): " edit_config
    if [[ $edit_config =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} .env
    else
        echo "Please edit .env file manually and run this script again."
        exit 0
    fi
fi

# Load environment variables
echo "📄 Loading configuration from .env..."
set -a
source .env
set +a

# Create database directory if it doesn't exist
if [ ! -z "$DB_DIRECTORY" ] && [ ! -d "$DB_DIRECTORY" ]; then
    echo "📁 Creating database directory: $DB_DIRECTORY"
    mkdir -p "$DB_DIRECTORY"
fi

# Check if daemon is accessible (basic check)
if [ ! -z "$DAEMON_URL" ]; then
    echo "🔍 Checking daemon connection..."
    # Extract host and port from DAEMON_URL for basic connectivity check
    daemon_host=$(echo $DAEMON_URL | sed -n 's|.*://[^@]*@\([^:/]*\).*|\1|p')
    daemon_port=$(echo $DAEMON_URL | sed -n 's|.*://[^@]*@[^:]*:\([0-9]*\)/.*|\1|p')
    
    if [ ! -z "$daemon_host" ] && [ ! -z "$daemon_port" ]; then
        if ! nc -z "$daemon_host" "$daemon_port" 2>/dev/null; then
            echo "⚠️  Warning: Cannot connect to daemon at $daemon_host:$daemon_port"
            echo "   Make sure your Bitcoin daemon is running and accessible."
            read -p "Continue anyway? (y/n): " continue_anyway
            if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            echo "✅ Daemon connection check passed"
        fi
    fi
fi

echo ""
echo "🚀 Starting ElectrumX server..."
echo "📊 Configuration:"
echo "   Coin: ${COIN:-Bitcoin}"
echo "   Network: ${NET:-mainnet}"
echo "   Database: ${DB_ENGINE:-rocksdb} in ${DB_DIRECTORY:-./electrumx_db}"
echo "   Services: ${SERVICES:-tcp://:50001,ssl://:50002,rpc://127.0.0.1:8000}"
echo ""
echo "🔗 RPC interface will be available at: http://127.0.0.1:8000"
echo "📡 Electrum client can connect to: localhost:50001 (TCP) or localhost:50002 (SSL)"
echo ""
echo "🛑 To stop the server, press Ctrl+C"
echo ""

# Run ElectrumX server
exec electrumx_server
