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
    PYTHON_CMD=$(brew --prefix python@3.12)/bin/python3
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
            boost-devel libsodium-devel \
            gcc gcc-c++ make git
    else
        echo "Unsupported Linux distribution. Please install dependencies manually."
        exit 1
    fi
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Create virtual environment
echo "Creating Python virtual environment..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # On macOS, use the Homebrew Python 3.12
    /usr/local/bin/python3.12 -m venv venv
else
    python3 -m venv venv
fi
source venv/bin/activate

# Upgrade pip and install wheel
echo "Upgrading pip and installing wheel..."
pip install --upgrade pip setuptools wheel

# Install Cython first (required for RocksDB)
echo "Installing Cython..."
pip install 'Cython<3.0'

# Try to install RocksDB Python bindings (may fail on some systems)
echo "Installing RocksDB Python bindings..."
if ! pip install python-rocksdb; then
    echo "⚠️  RocksDB installation failed. Trying alternative RocksDB package..."
    if ! pip install git+https://github.com/jansegre/python-rocksdb.git@314572c02e7204464a5c3e3475c79d57870a9a03; then
        echo "⚠️  RocksDB installation failed. Will use LevelDB instead."
        echo "   ElectrumX will work fine with LevelDB, just set DB_ENGINE=leveldb in your config."
    fi
fi

# Install ElectrumX with available database backends
echo "Installing ElectrumX..."
pip install -e .

# Install additional hash libraries for altcoins (optional)
echo "Installing additional hash libraries..."
pip install tribushashm blake256 dash_hash xevan_hash quark_hash groestlcoin_hash x16r_hash pycryptodomex x16rv2_hash

# Try to install some git-based hash libraries (these might fail on some systems)
echo "Installing additional git-based hash libraries..."
pip install git+https://github.com/bitcoinplusorg/x13-hash || echo "Warning: x13-hash installation failed"
pip install git+https://github.com/Electra-project/nist5_hash || echo "Warning: nist5_hash installation failed"
pip install git+https://github.com/VerusCoin/verushashpy || echo "Warning: verushashpy installation failed"

echo ""
echo "✅ ElectrumX setup complete!"
echo ""
echo "To activate the virtual environment:"
echo "  source venv/bin/activate"
echo ""
echo "To run ElectrumX server:"
echo "  electrumx_server"
echo ""
echo "To run ElectrumX RPC client:"
echo "  electrumx_rpc"
echo ""
echo "⚠️  Before running, you need to configure environment variables."
echo "   See the example configuration below or check README.md"
