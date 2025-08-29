// Copyright 2019 Conflux Foundation. All rights reserved.
// Conflux is free software and distributed under GNU General Public License.
// See http://www.gnu.org/licenses/

use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "devnetctl")]
#[command(about = "A tool for managing Conflux devnet operations")]
#[command(version = "0.1.0")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Generate PoS genesis configuration (equivalent to pos-genesis-tool)
    Genesis {
        #[command(subcommand)]
        subcommand: GenesisCommands,
    },
}

#[derive(Subcommand)]
pub enum GenesisCommands {
    /// Generate random PoS configuration
    Random {
        /// Initial seed for randomness
        #[arg(long)]
        initial_seed: String,
        /// Number of validators
        #[arg(long, default_value = "1")]
        num_validator: usize,
        /// Number of genesis validators
        #[arg(long, default_value = "1")]
        num_genesis_validator: usize,
        /// Chain ID
        #[arg(long, default_value = "0")]
        chain_id: u32,
    },
    /// Generate PoS configuration from public keys
    FromPub {
        /// Initial seed for randomness
        #[arg(long)]
        initial_seed: String,
        /// Path to public key file
        #[arg(value_name = "FILE")]
        pkfile: PathBuf,
    },
}