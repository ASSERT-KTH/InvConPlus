FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git=1:2.39.5-0+deb12u2 \
    curl=7.88.1-10+deb12u8 \
    wget=1.21.3-1+deb12u1 \
    build-essential=12.9 \
    default-jre=2:1.17-74 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir solc-select==1.0.4 \
    && solc-select install 0.8.0 \
    && solc-select use 0.8.0

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir \
    slither-analyzer==0.9.0 \
    web3==6.12.0 \
    evm-trace==0.1.2 \
    alive-progress==3.1.5 \
    cloudscraper==1.2.71 \
    beautifulsoup4==4.12.3 \
    lxml==5.2.1 \
    requests==2.31.0 \
    z3-solver==4.12.4.0 \
    pycryptodome==3.19.0 \
    eth-abi==4.2.1 \
    eth-utils==2.3.1 \
    pandas==2.2.1 \
    numpy==1.26.4 \
    python-dateutil==2.9.0.post0 \
    pytz==2024.1 \
    crytic-compile==0.3.5 \
    forbiddenfruit==0.1.4 \
    graphviz==0.16 \
    automata-lib==8.1.0 \
    web3-input-decoder==0.1.10

ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
