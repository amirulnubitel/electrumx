#!/bin/bash

# ElectrumX Local Setup Script with RocksDB
# This script sets up ElectrumX for local development/testing

set -e

echo "🚀 Setting up ElectrumX locally with RocksDB..."

# Check if we're on macOS and install dependencies
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📦 Installing macOS dependencies..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Install RocksDB and other dependencies
    echo "Installing RocksDB and dependencies via Homebrew..."
    brew update
    brew install rocksdb snappy lz4 zlib bzip2 python@3.12
    
    # Set up environment variables for RocksDB compilation
    export ROCKSDB_PATH=$(brew --prefix rocksdb)
    export SNAPPY_PATH=$(brew --prefix snappy)
    export LZ4_PATH=$(brew --prefix lz4)
    export ZLIB_PATH=$(brew --prefix zlib)
    export BZIP2_PATH=$(brew --prefix bzip2)
    
    export LDFLAGS="-L$ROCKSDB_PATH/lib -L$SNAPPY_PATH/lib -L$LZ4_PATH/lib -L$ZLIB_PATH/lib -L$BZIP2_PATH/lib"
    export CPPFLAGS="-I$ROCKSDB_PATH/include -I$SNAPPY_PATH/include -I$LZ4_PATH/include -I$ZLIB_PATH/include -I$BZIP2_PATH/include"
    export PKG_CONFIG_PATH="$ROCKSDB_PATH/lib/pkgconfig:$SNAPPY_PATH/lib/pkgconfig:$LZ4_PATH/lib/pkgconfig:$ZLIB_PATH/lib/pkgconfig:$BZIP2_PATH/lib/pkgconfig"
    
    # Use Homebrew Python
    PYTHON_CMD=$(brew --prefix python@3.12)/bin/python3.12
else
    echo "📦 Installing Linux dependencies..."
    
    # Check if running on Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            python3.12 python3.12-venv python3.12-dev \
            build-essential pkg-config \
            librocksdb-dev libsnappy-dev libbz2-dev \
            zlib1g-dev liblz4-dev liblzma-dev \
            git
    elif command -v yum &> /dev/null; then
        sudo yum install -y \
            python3.12 python3.12-devel \
            gcc gcc-c++ make pkg-config \
            rocksdb-devel snappy-devel bzip2-devel \
            zlib-devel lz4-devel xz-devel \
            git
    else
        echo "❌ Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
    
    PYTHON_CMD=python3.12
fi

# Check if Python is available
if ! command -v $PYTHON_CMD &> /dev/null; then
    echo "❌ Python 3.12 not found. Please install Python 3.12 first."
    exit 1
fi

echo "✅ Using Python: $($PYTHON_CMD --version)"

# Create virtual environment
echo "🐍 Creating virtual environment..."
rm -rf venv
$PYTHON_CMD -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip and install wheel
echo "📦 Upgrading pip and installing build tools..."
pip install --upgrade pip setuptools wheel

# Install Cython first (required for python-rocksdb)
echo "🔧 Installing Cython..."
pip install 'Cython<3.0'

# Install python-rocksdb with proper flags
echo "🗄️ Installing python-rocksdb (using compatible version)..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # On macOS, we need to use a specific version compatible with newer RocksDB
    echo "Trying git version that's compatible with newer RocksDB..."
    pip install git+https://github.com/jansegre/python-rocksdb.git@314572c02e7204464a5c3e3475c79d57870a9a03
else
    # On Linux, try the standard package first, then fallback
    if ! pip install python-rocksdb; then
        echo "Standard package failed, trying git version..."
        pip install git+https://github.com/jansegre/python-rocksdb.git@314572c02e7204464a5c3e3475c79d57870a9a03
    fi
fi

# Install other dependencies
echo "📦 Installing other dependencies..."
pip install aiohttp
pip install uvloop
pip install pylru

# Install ElectrumX itself
echo "🚀 Installing ElectrumX..."
pip install -e .[rocksdb]

# Install additional coin-specific hashes (optional)
echo "🪙 Installing coin-specific hash functions..."
pip install tribushashm blake256 dash_hash || echo "⚠️ Some hash functions failed to install (optional)"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy config_template.env to .env and configure your settings:"
echo "   cp config_template.env .env"
echo ""
echo "2. Edit .env to set your Bitcoin daemon connection:"
echo "   export DAEMON_URL=\"http://username:password@localhost:8332/\""
echo ""
echo "3. Run ElectrumX:"
echo "   source venv/bin/activate"
echo "   source .env"
echo "   electrumx_server"
echo ""
echo "📖 For more information, see the documentation in docs/"
