#!/bin/bash
set -euo pipefail

# Environment variables
CFX_USER="${CFX_USER:-conflux}"
HOME_DIR="${HOME_DIR:-/home/${CFX_USER}}"
DEFAULT_CONFIG_DIR="/tmp/default-configs"
DATA_DIR="/data"
NETWORK="${NETWORK:-}"

echo "==> Conflux Docker Container Starting"
echo "==> Network: $NETWORK"
echo "==> Working Directory: $(pwd)"
echo "==> Data Directory: $DATA_DIR"

# Function to get network-specific config filename
get_config_filename() {
    case "$NETWORK" in
        "mainnet")
            echo "hydra.toml"
            ;;
        "testnet")
            echo "testnet.toml"
            ;;
        "devnet")
            echo "config.toml"
            ;;
        *)
            echo "conflux.toml"
            ;;
    esac
}

# Function to setup configuration
setup_config() {
    echo "==> Setting up configuration"
    
    local config_filename=$(get_config_filename)
    
    if [ -f "$DATA_DIR/$config_filename" ]; then
        echo "==> Using user-provided configuration from $DATA_DIR/$config_filename"
        return 0
    fi
    
    echo "==> No user configuration found, copying default configuration"
    if [ ! -e "$DATA_DIR/conflux" ]; then
        ln -s /usr/local/bin/conflux "$DATA_DIR/conflux"
    fi

    if [ -d "$DEFAULT_CONFIG_DIR" ]; then
        cp -r "$DEFAULT_CONFIG_DIR"/* "$DATA_DIR/" 2>/dev/null || true
        echo "==> Default configuration copied to $DATA_DIR/ (official layout)"
    fi
    
    if [ "$NETWORK" = "devnet" ]; then
        mkdir -p "$DATA_DIR/pos_config"
        echo "==> Created devnet POS config directory in $DATA_DIR/pos_config"
    fi
}

# Function to extract chain_id from config
get_chain_id_from_config() {
    local config_filename=$(get_config_filename)
    local config_file="$DATA_DIR/$config_filename"
    local chain_id=""
    
    if [ -f "$config_file" ]; then
        # Extract chain_id using grep and awk
        chain_id=$(grep "^chain_id" "$config_file" | head -1 | awk '{print $3}' | tr -d ' ')
        
        if [ -n "$chain_id" ]; then
            echo "$chain_id"
            return 0
        fi
    fi
    
    # Default fallback
    echo "1"
}

# Function to generate POS configuration for devnet
generate_pos_config() {
    echo "==> Generating POS configuration for devnet"
    
    # Change to data directory for devnetctl output
    cd "$DATA_DIR"
    
    # Extract chain_id from configuration
    local chain_id=$(get_chain_id_from_config)
    echo "==> Using chain_id: $chain_id"
    
    # Check if POS config already exists (avoid regeneration if user provided it)
    if [ -f "$DATA_DIR/pos_config/initial_nodes.json" ] && [ -f "$DATA_DIR/pos_config/genesis_file" ] && [ -f "$DATA_DIR/pos_config/pos_key" ]; then
        echo "==> POS configuration already exists, skipping generation"
        return 0
    fi
    
    echo "==> Running devnetctl to generate POS configuration"
    
    # Generate unique seed for this container instance to avoid node ID conflicts
    # This ensures each devnet container has independent POS configuration
    local container_id="${HOSTNAME:-$(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo 'default')}"
    local seed=$(echo -n "$container_id" | sha256sum | cut -d' ' -f1)
    
    # Run devnetctl with proper parameters
    if ! devnetctl genesis random \
        --initial-seed="$seed" \
        --num-validator=1 \
        --num-genesis-validator=1 \
        --chain-id="$chain_id"; then
        echo "ERROR: Failed to generate POS configuration"
        exit 1
    fi
    
    echo "==> Moving generated files to pos_config directory"
    
    mkdir -p "$DATA_DIR/pos_config"
    
    [ -f "$DATA_DIR/initial_nodes.json" ] && mv "$DATA_DIR/initial_nodes.json" "$DATA_DIR/pos_config/"
    [ -f "$DATA_DIR/genesis_file" ] && mv "$DATA_DIR/genesis_file" "$DATA_DIR/pos_config/"
    
    if [ -f "$DATA_DIR/private_keys/0" ]; then
        mv "$DATA_DIR/private_keys/0" "$DATA_DIR/pos_config/pos_key"
        echo "==> Moved private key to pos_config/pos_key"
    fi
    
    rm -rf "$DATA_DIR/private_keys" "$DATA_DIR/public_key" 2>/dev/null || true
    
    echo "==> POS configuration generated successfully"
    
    # Update pos_config.yaml waypoint if both files exist
    # waypoint is a cryptographic commitment to the blockchain state at genesis
    # It ensures the PoS node starts from the correct initial state
    if [ -f "$DATA_DIR/pos_config/pos_config.yaml" ] && [ -f "$DATA_DIR/waypoint_config" ]; then
        local waypoint=$(cat "$DATA_DIR/waypoint_config")
        if [ -n "$waypoint" ]; then
            # Update waypoint in pos config
            if command -v sed >/dev/null 2>&1; then
                sed -i "s|from_config:.*|from_config: $waypoint|" "$DATA_DIR/pos_config/pos_config.yaml"
                echo "==> Updated waypoint in pos_config.yaml"
            fi
        fi
        rm -f "$DATA_DIR/waypoint_config"
    fi
}

# Function to start Conflux node
start_conflux() {
    echo "==> Starting Conflux node"
    
    local config_filename=$(get_config_filename)
    local config_file="$DATA_DIR/$config_filename"
    
    if [ ! -f "$config_file" ]; then
        echo "ERROR: Configuration file not found: $config_file"
        exit 1
    fi
    
    echo "==> Executing: ./conflux --config $config_file"
    exec ./conflux --config "$config_file" "$@"
}

# Main execution flow
main() {
    # start as root, fix permissions, then switch user
    if [ "$(id -u)" = "0" ]; then
        echo "==> Running as root, fixing data directory permissions"
        
        # Ensure data directory exists and has correct permissions
        mkdir -p "$DATA_DIR"
        chown -R "$CFX_USER:$CFX_USER" "$DATA_DIR" 2>/dev/null || true
        
        echo "==> Switching to user $CFX_USER"
        exec runuser -u "$CFX_USER" -- "$0" "$@"
        exit $?
    fi
    
    echo "==> Running as user $(whoami)"
    
    # Setup configuration
    setup_config
    
    # For devnet: generate POS configuration before starting
    if [ "$NETWORK" = "devnet" ] && command -v devnetctl >/dev/null 2>&1; then
        generate_pos_config
    fi
    
    # Start the Conflux node
    start_conflux "$@"
}

# Execute main function with all arguments
main "$@"