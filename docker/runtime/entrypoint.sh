#!/bin/bash
set -euo pipefail

# Environment variables
CFX_USER="${CFX_USER:-conflux}"
DEFAULT_CONFIG_DIR="/tmp/default-configs"
DATA_DIR="/data"
NETWORK="${NETWORK:-}"

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
        echo "==> Default $NETWORK configuration copied to $DATA_DIR/"
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
    
    if [ -f "$config_file" ]; then
        # Extract chain_id using grep and awk
        local chain_id=$(grep "^chain_id" "$config_file" | head -1 | awk '{print $3}' | tr -d ' ')
        [ -n "$chain_id" ] && echo "$chain_id" && return 0
    fi
    
    # Default fallback
    echo "1"
}

# Function to log genesis accounts information
log_genesis_accounts() {
    echo "==> 20 accounts with 1000 CFX each, generated with mnemonic:"
    echo "==> \"test test test test test test test test test test test junk\""
    echo ""
    echo "Account #01: Core Space: net1234:aak39z1fdm02v71y33znvaxwthh99skcp2jt1tvnua | eSpace: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    echo "Account #02: Core Space: net1234:aajkw8nu2ypbf1b4aegh4arzb2gvt1d33adfbk6a0d | eSpace: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    echo "Account #03: Core Space: net1234:aasekxs704yub8vnnbs7fgtahyktyuyx1u5e0x0ch3 | eSpace: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
    echo "Account #04: Core Space: net1234:aajttg907p0e9b2dp1x2ngbsd6jb7e73a2nhtktf9t | eSpace: 0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    echo "Account #05: Core Space: net1234:aam7gwztmuxh5r812rx2hgztsguayndmpynn9rjfd2 | eSpace: 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"
    echo "Account #06: Core Space: net1234:aap0myd7dkm53uxknvpnyf15g9pbxpfe5umwnaj62x | eSpace: 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc"
    echo "Account #07: Core Space: net1234:aan07k4ae5xwpzmr03n9yzd0hm8u2sumzexyygja15 | eSpace: 0x976EA74026E726554dB657fA54763abd0C3a0aa9"
    echo "Account #08: Core Space: net1234:aamr28p0k0vpbc3drgfx4tgh3j3bwtp3myua9pm0a7 | eSpace: 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955"
    echo "Account #09: Core Space: net1234:aak0ddyb6t46579zku80n7952cz9npu8v6781ng6py | eSpace: 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f"
    echo "Account #10: Core Space: net1234:aajs68uyfyxh2h30sfhezd5zpe1wbk61eafe59tktg | eSpace: 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720"
    echo "Account #11: Core Space: net1234:aasrjbbr6wp7cxwzaasp1pwmmytx1fmaw2kcbzu86j | eSpace: 0xBcd4042DE499D14e55001CcbB24a551F3b954096"
    echo "Account #12: Core Space: net1234:aaj5629xhbhz9spkw0e2zbzuf83ee5c1va2d5f2de3 | eSpace: 0x71bE63f3384f5fb98995898A86B02Fb2426c5788"
    echo "Account #13: Core Space: net1234:aarn0c0k44fu0vc90641e619ea0fpynkkj7mwdsek6 | eSpace: 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a"
    echo "Account #14: Core Space: net1234:aasn4s3hscjk4xuu8fn6ztee26xea68k7unz8aw11u | eSpace: 0x1CBd3b2770909D4e10f157cABC84C7264073C9Ec"
    echo "Account #15: Core Space: net1234:aatx6gg0ktdmxa90sszxdhgm6x24m9duw6nk044fmc | eSpace: 0xdF3e18d64BC6A983f673Ab319CCaE4f1a57C7097"
    echo "Account #16: Core Space: net1234:aasx07xp31nm66uvjh4ffvmu3kvzw3gsse4fej60dy | eSpace: 0xcd3B766CCDd6AE721141F452C550Ca635964ce71"
    echo "Account #17: Core Space: net1234:aamyrtgx3bdcd4n05apfzerkem1ht5hpgachtpapzg | eSpace: 0x2546BcD3c84621e976D8185a91A922aE77ECEc30"
    echo "Account #18: Core Space: net1234:aas4m7d59zw9bdtnmxfyp1z2tzasmg23t2a5d0e455 | eSpace: 0xbDA5747bFD65F08deb54cb465eB87D40e51B197E"
    echo "Account #19: Core Space: net1234:aasw9zc2ck28epb0aj2twp57nucdbt4e2amna2hmbt | eSpace: 0xdD2FD4581271e230360230F9337D5c0430Bf44C0"
    echo "Account #20: Core Space: net1234:aancr7yyb21nfcku784p77e5fytw3havxeb3j83epg | eSpace: 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"
    echo ""
}

# Function to generate POS configuration for devnet
generate_pos_config() {
    echo "==> Generating POS configuration for devnet"
    
    # Log genesis accounts information
    log_genesis_accounts
    
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
    local container_id="${HOSTNAME:-default-$(date +%s)}"
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
    echo "==> Conflux Docker Container Starting"
    echo "==> Network: $NETWORK"
    echo "==> Working Directory: $(pwd)"
    echo "==> Data Directory: $DATA_DIR"
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