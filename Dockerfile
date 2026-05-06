FROM python:3.10-slim

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    default-jre \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

# hadolint ignore=DL3013
RUN pip install --no-cache-dir \
    "eth-pydantic-types==0.1.0a5" \
    "evm-trace==0.1.2" \
    "solc-select==1.0.4" \
    "slither-analyzer==0.9.0" \
    "web3==6.12.0" \
    "alive-progress==3.1.5" \
    "cloudscraper==1.2.71" \
    "beautifulsoup4==4.12.3" \
    "lxml==5.2.1" \
    "requests==2.31.0" \
    "z3-solver==4.12.4.0" \
    "pycryptodome==3.19.0" \
    "eth-abi==4.2.1" \
    "eth-utils==2.3.1" \
    "pandas==2.2.1" \
    "numpy==1.26.4" \
    "python-dateutil==2.9.0.post0" \
    "pytz==2024.1" \
    "crytic-compile==0.3.5" \
    "forbiddenfruit==0.1.4" \
    "graphviz==0.16" \
    "automata-lib==8.1.0" \
    "web3-input-decoder==0.1.10"

ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
