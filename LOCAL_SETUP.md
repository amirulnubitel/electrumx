# ElectrumX Local Development Setup

This guide helps you run ElectrumX locally for development and testing.

## Quick Start

### 1. Initial Setup

```bash
./setup_local.sh
```

This script will:

-  Install system dependencies (RocksDB, Snappy, etc.)
-  Create a Python virtual environment
-  Install ElectrumX and all dependencies
-  Install additional hash libraries for altcoins

### 2. Configuration

```bash
cp config_template.env .env
# Edit .env with your settings
```

**Minimum required configuration:**

-  `DAEMON_URL`: Your Bitcoin daemon RPC URL
-  `DB_DIRECTORY`: Where to store the database

**Example configurations:**

For Bitcoin Core (mainnet):

```bash
export DAEMON_URL="http://username:password@localhost:8332/"
export COIN="Bitcoin"
export NET="mainnet"
```

For Bitcoin testnet:

```bash
export DAEMON_URL="http://username:password@localhost:18332/"
export COIN="Bitcoin"
export NET="testnet"
```

### 3. Run ElectrumX

```bash
./run_local.sh
```

### 4. Development Tools

```bash
./dev_tools.sh
```

## Manual Setup (Alternative)

If the automatic setup doesn't work, you can set up manually:

### Prerequisites

**macOS (using Homebrew):**

```bash
brew install python@3.12 rocksdb snappy lz4 zlib bzip2 leveldb boost libsodium
```

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv python3-dev \
    libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev \
    liblz4-dev librocksdb-dev libleveldb-dev \
    libboost-all-dev libsodium-dev \
    build-essential pkg-config git
```

### Python Environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel
pip install 'Cython<3.0'
pip install git+https://github.com/jansegre/python-rocksdb.git@314572c02e7204464a5c3e3475c79d57870a9a03
pip install -e .[rocksdb]
```

## Running Different Coins

ElectrumX supports many cryptocurrencies. Edit your `.env` file:

**Litecoin:**

```bash
export COIN="Litecoin"
export DAEMON_URL="http://username:password@localhost:9332/"
```

**Dogecoin:**

```bash
export COIN="Dogecoin"
export DAEMON_URL="http://username:password@localhost:22555/"
```

**See the ElectrumX documentation for a full list of supported coins.**

## Ports and Services

Default ports:

-  **50001**: TCP (unencrypted)
-  **50002**: SSL (encrypted)
-  **8000**: RPC interface

## Testing

Run the test suite:

```bash
source venv/bin/activate
pip install pytest pytest-asyncio pytest-cov pycodestyle
pytest --cov=electrumx
```

## RPC Interface

Query the server status:

```bash
electrumx_rpc -p 8000 getinfo
```

Available RPC commands:

-  `getinfo`: Server information
-  `peers`: Connected peers
-  `sessions`: Active sessions
-  `stop`: Shutdown server

## Troubleshooting

### Common Issues

1. **RocksDB installation fails:**

   -  Make sure you have the development headers installed
   -  On macOS: `brew install rocksdb`
   -  On Ubuntu: `sudo apt-get install librocksdb-dev`

2. **Daemon connection fails:**

   -  Check that your Bitcoin daemon is running
   -  Verify the RPC credentials in your daemon's configuration
   -  Ensure the daemon allows RPC connections

3. **Permission errors:**

   -  Make sure the database directory is writable
   -  Set `ALLOW_ROOT=true` if running as root (not recommended for production)

4. **SSL errors:**
   -  Generate SSL certificates or disable SSL
   -  Use only TCP port 50001 for testing

### Environment Variables

All configuration is done through environment variables. Key variables:

-  `COIN`: Cryptocurrency (Bitcoin, Litecoin, etc.)
-  `NET`: Network (mainnet, testnet, regtest)
-  `DAEMON_URL`: Blockchain daemon RPC URL
-  `DB_DIRECTORY`: Database storage location
-  `DB_ENGINE`: Database engine (rocksdb, leveldb)
-  `SERVICES`: Listening services and ports
-  `CACHE_MB`: Memory cache size in MB

## Development Workflow

1. Make changes to the code
2. Restart the server: `./run_local.sh`
3. Test with RPC: `electrumx_rpc -p 8000 getinfo`
4. Run tests: `pytest`

## Production Deployment

For production deployment, use the Docker setup or refer to the main README.md for systemd configuration.
