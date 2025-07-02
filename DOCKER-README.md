# ElectrumX Docker Compose Setup

This directory contains a complete Docker Compose setup for running ElectrumX with Vertcoin.

## Quick Start

1. **Copy the example configuration files:**
   ```bash
   cp .env.example .env
   cp vertcoin.conf.example vertcoin.conf
   ```

2. **Edit the configuration:**
   - Modify `.env` with your specific settings
   - Update `vertcoin.conf` with your node preferences
   - Set your domain/IP in `REPORT_SERVICES`

3. **Start the services:**
   ```bash
   # Start both ElectrumX and Vertcoin node
   docker-compose up -d
   
   # Or start only ElectrumX (if you have an external node)
   docker-compose up -d electrumx
   ```

4. **Monitor the logs:**
   ```bash
   # View ElectrumX logs
   docker-compose logs -f electrumx
   
   # View Vertcoin node logs
   docker-compose logs -f vertcoin-node
   ```

## Configuration

### Environment Variables (.env)

Key settings to customize:

- `COIN`: Cryptocurrency to serve (default: Vertcoin)
- `DAEMON_URL`: Connection to your blockchain node
- `REPORT_SERVICES`: Your public server endpoints
- `CACHE_MB`: Memory allocation for caching
- `SSL_CERTFILE`/`SSL_KEYFILE`: SSL certificate paths

### Node Configuration (vertcoin.conf)

Important settings:

- `txindex=1`: Required for ElectrumX to function
- `rpcuser`/`rpcpassword`: Must match DAEMON_URL
- `rpcallowip`: Allow ElectrumX container to connect

## Services

### ElectrumX Server

- **TCP Port**: 50001 (standard Electrum protocol)
- **SSL Port**: 50002 (encrypted Electrum protocol)  
- **WebSocket Port**: 50004 (for web clients)
- **RPC Port**: 8000 (admin interface, localhost only)

### Vertcoin Node

- **P2P Port**: 5889 (blockchain network)
- **RPC Port**: 5888 (internal communication)

## Data Persistence

All data is stored in Docker volumes:

- `electrumx-db`: ElectrumX database and indexes
- `vertcoin-data`: Blockchain data and wallet

## SSL Setup (Optional)

To enable SSL/TLS:

1. Create SSL certificates in `./ssl/` directory
2. Uncomment SSL environment variables in `.env`
3. Restart the containers

## Monitoring

### Health Checks

Both services have health checks:

```bash
# Check service status
docker-compose ps

# View health check details
docker inspect electrumx-server --format='{{.State.Health}}'
```

### Resource Usage

```bash
# Monitor resource usage
docker stats electrumx-server vertcoin-node
```

## Maintenance

### Backup

```bash
# Backup volumes
docker run --rm -v electrumx-db:/data -v $(pwd):/backup alpine tar czf /backup/electrumx-backup.tar.gz /data
```

### Updates

```bash
# Pull latest images and restart
docker-compose pull
docker-compose up -d --force-recreate
```

### Clean Shutdown

```bash
# Graceful shutdown
docker-compose down

# Remove everything including volumes (WARNING: data loss!)
docker-compose down -v
```

## Troubleshooting

1. **Connection Issues**: Check firewall and port forwarding
2. **Sync Problems**: Ensure sufficient disk space and memory
3. **SSL Errors**: Verify certificate paths and permissions
4. **Performance**: Adjust `CACHE_MB` and resource limits

## Security Notes

- RPC interface is bound to localhost only
- Non-root user runs ElectrumX process
- Network isolation between containers
- Resource limits prevent system overload
