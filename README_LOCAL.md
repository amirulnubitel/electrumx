# ElectrumX Local Development Setup

This guide helps you set up and run ElectrumX locally on your machine for development and testing.

## Quick Start

1. **Run the setup script:**

   ```bash
   ./setup_smart.sh
   ```

   This will install all dependencies and set up ElectrumX with LevelDB (and RocksDB if compatible).

2. **Configure your environment:**

   ```bash
   cp config_template.env .env
   # Edit .env with your Bitcoin daemon settings
   ```

3. **Start ElectrumX:**
   ```bash
   ./run_electrumx.sh
   ```

## Configuration

### Required Settings

Edit `.env` and configure at minimum:

```bash
# Bitcoin daemon connection (REQUIRED)
export DAEMON_URL="http://username:password@localhost:8332/"

# Database settings
export DB_ENGINE="leveldb"  # or "rocksdb" if available
export DB_DIRECTORY="./electrumx_db"

# Coin settings
export COIN="Bitcoin"  # or other supported coins
export NET="mainnet"   # or "testnet"
```

### Optional Settings

```bash
# Server settings
export SERVICES="tcp://:50001,ssl://:50002,rpc://127.0.0.1:8000"
export ALLOW_ROOT="true"  # Allow running as root (development only)

# Performance settings
export CACHE_MB="2000"
export MAX_SESSIONS="10000"
export MAX_SEND="10000000"

# SSL settings (for production)
export SSL_CERTFILE="/path/to/cert.pem"
export SSL_KEYFILE="/path/to/key.pem"
```

## Supported Coins

ElectrumX supports many cryptocurrencies. Set the `COIN` environment variable:

-  `Bitcoin` (BTC)
-  `BitcoinTestnet` (BTC testnet)
-  `Litecoin` (LTC)
-  `Dash` (DASH)
-  `Dogecoin` (DOGE)
-  `DigiByte` (DGB)
-  `Vertcoin` (VTC)
-  And many more...

## Database Backends

### LevelDB (Recommended for Development)

-  ✅ Easy to install
-  ✅ Stable and reliable
-  ✅ Good performance for development
-  ❌ Slightly slower than RocksDB

### RocksDB (Optional)

-  ✅ Better performance
-  ✅ Better compression
-  ❌ More complex to install
-  ❌ May have compatibility issues on some systems

## Development Workflow

### Starting Development

```bash
# Activate virtual environment
source venv/bin/activate

# Load configuration
source .env

# Run ElectrumX directly
electrumx_server
```

### Running Tests

```bash
source venv/bin/activate
pytest tests/
```

### Code Style

```bash
source venv/bin/activate
pycodestyle --max-line-length=100 src/
```

## Troubleshooting

### Database Issues

-  **LevelDB not found**: Make sure system LevelDB is installed (`brew install leveldb` on macOS)
-  **RocksDB compilation fails**: This is common. Use LevelDB instead by setting `DB_ENGINE=leveldb`
-  **Permission errors**: Make sure the database directory is writable

### Connection Issues

-  **Can't connect to daemon**: Check `DAEMON_URL` is correct and Bitcoin node is running
-  **Port already in use**: Change the port in `SERVICES` setting
-  **SSL issues**: For development, you can disable SSL by removing it from `SERVICES`

### Performance Issues

-  **Slow initial sync**: This is normal. Bitcoin has a large blockchain
-  **High memory usage**: Reduce `CACHE_MB` setting
-  **Slow queries**: Consider using RocksDB if available

## Scripts Reference

-  `setup_smart.sh`: Full setup with dependency installation
-  `run_electrumx.sh`: Start ElectrumX with proper environment
-  `config_template.env`: Configuration template

## Ports Used

-  **50001**: Electrum TCP protocol
-  **50002**: Electrum SSL protocol
-  **50004**: Electrum WebSocket protocol
-  **8000**: RPC interface (local only)

## Security Notes

⚠️ **This setup is for development only!**

-  `ALLOW_ROOT=true` should never be used in production
-  Default ports should be changed for production
-  SSL certificates should be properly configured for production
-  Database should be on persistent storage for production

## Getting Help

-  **ElectrumX Documentation**: See `docs/` directory
-  **Configuration Reference**: See `docs/environment.rst`
-  **Protocol Documentation**: See `docs/protocol.rst`
-  **GitHub Issues**: Report bugs and ask questions

## Next Steps

1. Set up a Bitcoin node (Bitcoin Core) if you don't have one
2. Configure SSL certificates for secure connections
3. Set up monitoring and logging for production use
4. Consider running behind a reverse proxy (nginx) for production
