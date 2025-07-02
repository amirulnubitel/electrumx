# Multi-stage Dockerfile for ElectrumX Server
# This builds ElectrumX from source with all required dependencies

FROM python:3.12 AS builder

# Set working directory
WORKDIR /app

# Install build dependencies and system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
   build-essential \
   pkg-config \
   librocksdb-dev \
   libsnappy-dev \
   libbz2-dev \
   libz-dev \
   liblz4-dev \
   liblzma-dev \
   git \
   && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install wheel
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy project files one by one to better identify any issues
COPY pyproject.toml ./
COPY MANIFEST.in ./
# COPY README.md ./
# COPY LICENCE ./
COPY src/ ./src/

# Install the package with optional dependencies
RUN pip install --no-cache-dir .[rocksdb]

# Production stage
FROM python:3.12

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
   librocksdb8.8 \
   libsnappy1v5 \
   libbz2-1.0 \
   zlib1g \
   liblz4-1 \
   liblzma5 \
   && rm -rf /var/lib/apt/lists/*

# Copy the virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Create electrumx user for security
RUN groupadd -r electrumx && useradd -r -g electrumx electrumx

# Set up directories
ENV DB_DIRECTORY=/var/lib/electrumx
RUN mkdir -p "$DB_DIRECTORY" && chown electrumx:electrumx "$DB_DIRECTORY"

# Default environment variables
ENV SERVICES="tcp://:50001,ssl://:50002,wss://:50004,rpc://127.0.0.1:8000"
ENV COIN=Vertocoin
ENV DAEMON_URL="http://username:password@localhost:8332/"
ENV ALLOW_ROOT=false
ENV DB_ENGINE=rocksdb
ENV MAX_SEND=10000000
ENV BANDWIDTH_UNIT_COST=50000
ENV CACHE_MB=2000
ENV MAX_SESSIONS=10000
ENV SSL_CERTFILE=""
ENV SSL_KEYFILE=""
ENV BANNER_FILE=""
ENV TOR_BANNER_FILE=""
ENV ANON_LOGS=false
ENV LOG_SESSIONS=3600
ENV DONATION_ADDRESS=""

# Set working directory
WORKDIR /app

# Create volumes for data persistence
VOLUME ["$DB_DIRECTORY"]

# Switch to electrumx user
USER electrumx

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
   CMD python -c "import socket; s=socket.socket(); s.connect(('127.0.0.1', 8000)); s.close()" || exit 1

# Expose ports
EXPOSE 50001 50002 50004 8000

# Default command
CMD ["electrumx_server"]

# Build instructions:
# docker build -t electrumx:latest .
#
# Run instructions:
# docker run -d \
#   --name electrumx \
#   -p 50001:50001 \
#   -p 50002:50002 \
#   -p 50004:50004 \
#   -v electrumx-db:/var/lib/electrumx \
#   -e DAEMON_URL="http://user:pass@bitcoin-node:8332/" \
#   -e REPORT_SERVICES="tcp://your-domain.com:50001,ssl://your-domain.com:50002" \
#   electrumx:latest
#
# For clean shutdown:
# docker stop electrumx