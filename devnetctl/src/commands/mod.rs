// Copyright 2019 Conflux Foundation. All rights reserved.
// Conflux is free software and distributed under GNU General Public License.
// See http://www.gnu.org/licenses/

pub mod genesis;

use crate::cli::Commands;
use crate::error::Error;

pub fn execute(command: Commands) -> Result<String, Error> {
    match command {
        Commands::Genesis { subcommand } => genesis::execute(subcommand),
    }
}