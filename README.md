# Conflux Docker Builder

[![Build and Publish Conflux Node Image](https://github.com/iosh/conflux-docker-builder/actions/workflows/build.yml/badge.svg)](https://github.com/iosh/conflux-docker-builder/actions/workflows/build.yml)

Multi-architecture Docker images for Conflux blockchain nodes, supporting mainnet, testnet, and devnet with automated devnet POS generation.

## Quick Start

```bash
# Run devnet with automatic POS configuration
docker run -v ./data:/data -p 12537:12537 ghcr.io/iosh/conflux-node:v3.0.1-devnet

# Run mainnet
docker run -v ./data:/data -p 12537:12537 ghcr.io/iosh/conflux-node:v3.0.1-mainnet

# Run testnet (uses testnet-specific version)
docker run -v ./data:/data -p 12537:12537 ghcr.io/iosh/conflux-node:v3.0.1-testnet-testnet
```

## Features

- **Multi-Architecture**: linux/amd64 and linux/arm64 support
- **Network Support**: Mainnet, testnet, and devnet configurations
- **Smart DevNet**: Automatic POS configuration generation with unique seeds
- **Optimized Builds**: Haswell optimizations for AMD64, ARMv8.2-a for ARM64
- **Easy Usage**: Single data directory mount point `/data`

## DevNet Configuration

### Chain IDs
- **Core Space Chain ID**: 1234
- **eSpace Chain ID**: 1235

### Genesis Accounts
DevNet comes pre-configured with 20 accounts, each with 1000 CFX balance. These accounts are generated using the standard Hardhat test mnemonic:

**Mnemonic**: `test test test test test test test test test test test junk`

The accounts and their addresses will be displayed when starting the devnet container, showing both Core Space and eSpace addresses for easy access during development.

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

**Tag Naming Convention:** `ghcr.io/iosh/conflux-node:<source-version>-<network>`

The naming follows a consistent pattern where:
- **Mainnet/Devnet**: Use the standard conflux-rust version (e.g., `v3.0.1`)
- **Testnet**: Use the testnet-specific version (e.g., `v3.0.1-testnet`)
- **Network suffix**: Always added to clearly identify the network type

Examples:
- `ghcr.io/iosh/conflux-node:v3.0.1-mainnet` (built from `v3.0.1` tag)
- `ghcr.io/iosh/conflux-node:v3.0.1-testnet-testnet` (built from `v3.0.1-testnet` tag)
- `ghcr.io/iosh/conflux-node:v3.0.1-testnet-fix-testnet` (built from `v3.0.1-testnet-fix` tag)  
- `ghcr.io/iosh/conflux-node:v3.0.1-devnet` (built from `v3.0.1` tag)