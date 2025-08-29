// Copyright 2019 Conflux Foundation. All rights reserved.
// Conflux is free software and distributed under GNU General Public License.
// See http://www.gnu.org/licenses/

mod error;
mod cli;
mod commands;

use cli::Cli;
use clap::Parser;
use diem_types::term_state::pos_state_config::POS_STATE_CONFIG;
use std::process;

fn main() {
    env_logger::try_init().expect("Logger initialized only once.");
    POS_STATE_CONFIG.set(Default::default()).unwrap();

    let cli = Cli::parse();

    match commands::execute(cli.command) {
        Ok(message) => println!("{}", message),
        Err(err) => {
            eprintln!("{}", err);
            process::exit(1);
        }
    }
}