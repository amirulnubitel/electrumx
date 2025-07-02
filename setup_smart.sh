#!/bin/bash

# ElectrumX Local Setup Script with RocksDB fallback to LevelDB
# This script sets up ElectrumX for local development/testing

set -e

echo "🚀 Setting up ElectrumX locally with database backend..."

# Check if we're on macOS and install dependencies
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📦 Installing macOS dependencies..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # Install database backends and other dependencies
    echo "Installing database backends and dependencies via Homebrew..."
    brew update
    brew install leveldb snappy lz4 zlib bzip2 python@3.12
    
    # Set up basic environment variables
    export LEVELDB_PATH=$(brew --prefix leveldb)
    export SNAPPY_PATH=$(brew --prefix snappy)
    export LZ4_PATH=$(brew --prefix lz4)
    export ZLIB_PATH=$(brew --prefix zlib)
    export BZIP2_PATH=$(brew --prefix bzip2)
    
    export LDFLAGS="-L$LEVELDB_PATH/lib -L$SNAPPY_PATH/lib -L$LZ4_PATH/lib -L$ZLIB_PATH/lib -L$BZIP2_PATH/lib"
    export CPPFLAGS="-I$LEVELDB_PATH/include -I$SNAPPY_PATH/include -I$LZ4_PATH/include -I$ZLIB_PATH/include -I$BZIP2_PATH/include"
    export PKG_CONFIG_PATH="$LEVELDB_PATH/lib/pkgconfig:$SNAPPY_PATH/lib/pkgconfig:$LZ4_PATH/lib/pkgconfig:$ZLIB_PATH/lib/pkgconfig:$BZIP2_PATH/lib/pkgconfig"
    
    # Try to install RocksDB (optional)
    if brew install rocksdb; then
        echo "✅ RocksDB installed successfully"
        ROCKSDB_AVAILABLE=true
        
        # Add RocksDB paths to environment variables
        export ROCKSDB_PATH=$(brew --prefix rocksdb)
        export LDFLAGS="$LDFLAGS -L$ROCKSDB_PATH/lib"
        export CPPFLAGS="$CPPFLAGS -I$ROCKSDB_PATH/include"
        export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$ROCKSDB_PATH/lib/pkgconfig"
    else
        echo "⚠️ RocksDB installation failed, will use LevelDB only"
        ROCKSDB_AVAILABLE=false
    fi
    
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
            libleveldb-dev libsnappy-dev libbz2-dev \
            zlib1g-dev liblz4-dev liblzma-dev \
            git
            
        # Try to install RocksDB (optional)
        if sudo apt-get install -y librocksdb-dev; then
            echo "✅ RocksDB installed successfully"
            ROCKSDB_AVAILABLE=true
        else
            echo "⚠️ RocksDB installation failed, will use LevelDB only"
            ROCKSDB_AVAILABLE=false
        fi
    elif command -v yum &> /dev/null; then
        sudo yum install -y \
            python3.12 python3.12-devel \
            gcc gcc-c++ make pkg-config \
            leveldb-devel snappy-devel bzip2-devel \
            zlib-devel lz4-devel xz-devel \
            git
            
        # Try to install RocksDB (optional)
        if sudo yum install -y rocksdb-devel; then
            echo "✅ RocksDB installed successfully"
            ROCKSDB_AVAILABLE=true
        else
            echo "⚠️ RocksDB installation failed, will use LevelDB only"
            ROCKSDB_AVAILABLE=false
        fi
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

# Install Cython first (required for database bindings)
echo "🔧 Installing Cython..."
pip install 'Cython<3.0'

# Try to install RocksDB support if available
if [ "$ROCKSDB_AVAILABLE" = true ]; then
    echo "🗄️ Attempting to install RocksDB Python bindings..."
    if pip install git+https://github.com/jansegre/python-rocksdb.git@314572c02e7204464a5c3e3475c79d57870a9a03; then
        echo "✅ RocksDB Python bindings installed successfully"
        DB_BACKEND="rocksdb"
    else
        echo "⚠️ RocksDB Python bindings failed to install, falling back to LevelDB"
        DB_BACKEND="leveldb"
    fi
else
    echo "📄 Using LevelDB as database backend"
    DB_BACKEND="leveldb"
fi

# Install LevelDB support (always available as fallback)
echo "📄 Installing LevelDB Python bindings..."
pip install plyvel

# Install other dependencies
echo "📦 Installing other dependencies..."
pip install aiohttp
pip install uvloop
pip install pylru

# Install ElectrumX itself
echo "🚀 Installing ElectrumX..."
if [ "$DB_BACKEND" = "rocksdb" ]; then
    pip install -e .[rocksdb]
else
    pip install -e .
fi

# Install additional coin-specific hashes (optional)
echo "🪙 Installing coin-specific hash functions..."
pip install tribushashm blake256 dash_hash || echo "⚠️ Some hash functions failed to install (optional)"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Database backend: $DB_BACKEND"
echo ""
echo "📋 Next steps:"
echo "1. Copy config_template.env to .env and configure your settings:"
echo "   cp config_template.env .env"
echo ""
echo "2. Edit .env to set your database backend and Bitcoin daemon connection:"
echo "   export DB_ENGINE=\"$DB_BACKEND\""
echo "   export DAEMON_URL=\"http://username:password@localhost:8332/\""
echo ""
echo "3. Run ElectrumX:"
echo "   source venv/bin/activate"
echo "   source .env"
echo "   electrumx_server"
echo ""
echo "📖 For more information, see the documentation in docs/"
