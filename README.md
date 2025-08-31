# Conflux Docker Builder

[![Build and Publish Conflux Node Image](https://github.com/iosh/conflux-docker-builder/actions/workflows/build.yml/badge.svg)](https://github.com/iosh/conflux-docker-builder/actions/workflows/build.yml)

Multi-architecture Docker images for Conflux blockchain nodes, supporting mainnet, testnet, and devnet with automated devnet POS generation.

## Quick Start

```bash
# Run devnet with automatic POS configuration
docker run -v ./data:/data -p 12537:12537 ghcr.io/iosh/conflux-node:v3.0.1-devnet

# Run mainnet
docker run -v ./data:/data -p 12537:12537 ghcr.io/iosh/conflux-node:v3.0.1-mainnet

# Run testnet
docker run -v ./data:/data -p 12537:12537 ghcr.io/iosh/conflux-node:v3.0.1-testnet
```

## Features

- **Multi-Architecture**: linux/amd64 and linux/arm64 support
- **Network Support**: Mainnet, testnet, and devnet configurations
- **Smart DevNet**: Automatic POS configuration generation with unique seeds
- **Optimized Builds**: Haswell optimizations for AMD64, ARMv8.2-a for ARM64
- **Easy Usage**: Single data directory mount point `/data`

## Building Locally

```bash
# Setup buildx (one time)
make buildx-setup

# Build all images
make build

# Build specific network
make devnet

# Build and push
make push
```

## Configuration

Place network-specific config files in your data directory:
- Mainnet: `hydra.toml`
- Testnet: `testnet.toml` 
- Devnet: `config.toml`

If no config is provided, default configurations are used automatically.

## Image Tags

`ghcr.io/iosh/conflux-node:<version>-<network>`

Examples:
- `ghcr.io/iosh/conflux-node:v3.0.1-mainnet`
- `ghcr.io/iosh/conflux-node:v3.0.1-testnet`
- `ghcr.io/iosh/conflux-node:v3.0.1-devnet`