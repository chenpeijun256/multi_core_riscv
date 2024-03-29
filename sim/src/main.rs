mod bin_file;
mod mem;
mod perips;
mod config;
mod rv32_actor;
mod utils;
mod intrrupt;
mod gdbserver;

fn test_from_local() {

    loop {
        let mut key = String::new();
        match std::io::stdin().read_line(&mut key) {
            Ok(_) => {
                // println!("{n} bytes read.");
                // println!("key = {}.", key.trim());
                let cmds = crate::utils::split_string(key);
                if cmds.len() > 0 {
                    if cmds[0] == "p" {
                        if cmds.len() > 2 {
                            // soc.print_d(&cmds[1], &cmds[2]);
                        } else {
                            println!("e.g. p cpu0 reg/csr.");
                            println!("     p mem address(hex).");
                            println!("     p gpio_a offset(hex).");
                        }
                    } else if cmds[0] == "s" {
                        if cmds.len() > 3 {
                            // soc.set_v_d(&cmds[1], &cmds[2], &cmds[3]);
                        } else {
                            println!("e.g. s cpu0 index(hex, reg<32, else csr) vvv(hex).");
                            println!("     s mem address(hex) vvv(hex).");
                            println!("     s gpio_a(perips) address(hex) vvv(hex).");
                        }
                    } else {
                        println!("command can not found.");
                    }
                } else {
                    println!("command can not found.");
                }
            },
            Err(e) => {
                println!("input error {e}.")
            },
        }
    }
}

fn main() {
    gdbserver::server_start();

    test_from_local();
}
