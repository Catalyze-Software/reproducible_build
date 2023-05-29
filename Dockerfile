FROM ubuntu:22.04
ENV NODE_VERSION=14
ENV PATH=/cargo/bin:/rust/bin:$PATH
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
ENV RUST_BACKTRACE=full
ENV RUSTUP_HOME=/rust
ENV CARGO_HOME=/cargo
ENV NVM_DIR=/root/.nvm

WORKDIR /root/dfx
RUN apt-get update
RUN apt-get install libunwind8
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        libdigest-sha-perl \
        cmake \
        curl \
        git \
        rsync \
        ssh \
        libssl-dev \
        pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /
COPY _test_environment/. ./
COPY dfx.json .
COPY Cargo.toml .
COPY start.sh .
CMD ["/bin/bash","-c","./start.sh"]