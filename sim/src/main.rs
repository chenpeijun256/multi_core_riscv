mod bin_file;
mod mem;
mod perips;
mod config;
mod rv32_actor;
mod utils;
mod intrrupt;
mod gdbserver;

fn main() {
    gdbserver::server_start();
}
