#!/bin/bash

# ElectrumX Development/Testing Script

set -e

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "❌ Virtual environment not found. Please run setup_local.sh first."
    exit 1
fi

echo "🧪 ElectrumX Development Tools"
echo ""

while true; do
    echo "Select an option:"
    echo "1) Run tests"
    echo "2) Check code style"
    echo "3) Start ElectrumX server"
    echo "4) RPC client (interactive)"
    echo "5) Show server status"
    echo "6) Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            echo "🧪 Running tests..."
            pytest --cov=electrumx tests/ || echo "Tests completed with issues"
            ;;
        2)
            echo "📝 Checking code style..."
            pycodestyle --max-line-length=100 src/ || echo "Code style check completed with issues"
            ;;
        3)
            echo "🚀 Starting ElectrumX server..."
            ./run_local.sh
            ;;
        4)
            echo "💬 ElectrumX RPC Client"
            echo "Available commands: getinfo, stop, peers, sessions, etc."
            electrumx_rpc -p 8000 getinfo || echo "Could not connect to server"
            ;;
        5)
            echo "📊 Server Status"
            electrumx_rpc -p 8000 getinfo 2>/dev/null || echo "Server not running or not accessible"
            ;;
        6)
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please try again."
            ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
    echo ""
done
