use std::{fs::{self, File}, io::BufReader};
use crate::{bin_file, mem::Mem, rv32_actor::Rv32Actor};
use crate::perips::Perips;
use crate::rv32_actor::cpu::Rv32Cpu;

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct CCpu {
    name: String,
    class: String,
    isa: String,
    freq: f32,
    rst_pc: u32,
    bin_file: String,
}

#[derive(Serialize, Deserialize)]
struct CMem {
    name: String,
    start: u32,
    size: u32,
}

#[derive(Serialize, Deserialize)]
struct CPerips {
    name: String,
    class: u32,
    start: u32,
    size: u32,
    intr: u32,
}

#[derive(Serialize, Deserialize)]
struct CSoc {
    name: String,
    gdb_active: i32,
    cpus: Vec<CCpu>,
    mems: Vec<CMem>,
    perips: Vec<CPerips>,
}

pub fn build_soc(cfg_file: String) -> Rv32Actor {
    let soc_cfg = read_cfg(cfg_file);
    println!("create {} soc.", soc_cfg.name);
    let mut soc: Rv32Actor = Rv32Actor::new(soc_cfg.name, soc_cfg.gdb_active);

    for i in 0..soc_cfg.mems.len() {
        println!("start read {}", soc_cfg.cpus[i].bin_file);
        match bin_file::read_file(&soc_cfg.cpus[i].bin_file) {
            Ok(bytes) => {
                let name = soc_cfg.mems[i].name.to_owned();
                let mut mem = Mem::new(name, soc_cfg.mems[i].start, soc_cfg.mems[i].size);
                println!("add mem {:?} to soc.", mem);
                mem.fill(bytes, 0);
                soc.add_mem(mem);
            },
            Err(e) => {
                println!("bin file read failed, {}", e);
            }
        }
    }

    for cfg in soc_cfg.cpus {
        println!("add {} to soc.", cfg.name);
        let cpu = Rv32Cpu::new(cfg.name, cfg.rst_pc, cfg.freq);
        soc.add_cpu(cpu);
    }

    for cfg in soc_cfg.perips {
        let p = Perips::new(cfg.name, cfg.start, cfg.size, cfg.intr);
        println!("add perips {:?} to soc.", p);
        soc.add_perips(p);
    }

    soc
}

fn read_cfg(cfg_file: String) -> CSoc {

    match fs::File::open(cfg_file) {
        Ok(f) => {
            let reader = BufReader::new(f);
            match serde_json::from_reader::<BufReader<File>, CSoc>(reader) {
                Ok(s) => {
                    return s;
                },
                Err(e) => println!("json string read failed. {e}"),
            }
        },
        Err(e) => println!("config file open failed. {e}"),
    };

    return CSoc{name: "default".to_owned(), gdb_active: 0,
                cpus: vec![CCpu{name: "cpu0".to_owned(), class: "rv32".to_owned(), isa: "im".to_owned(), 
                                freq: 50.0, rst_pc: 0, bin_file: "main.bin".to_owned()}], 
                mems: vec![CMem{name: "ram".to_owned(), start: 0, size: 8192}], 
                perips: Vec::new()
            };

    // let json_str = "{\"name\": \"cpu0\", \"freq\": 50.0}";
    // let json = serde_json::from_str(json_str);
    // let mut s = Soc{name: "my_board".to_owned(), cpus: Vec::new()};
    // s.cpus.push(Cpu{name: "cpu0".to_owned(), class: "rv32".to_owned(), isa: "im".to_owned(), freq: 100.0});
    // s.cpus.push(Cpu{name: "cpu1".to_owned(), class: "rv64".to_owned(), isa: "g".to_owned(), freq: 150.0});
    // s.cpus.push(Cpu{name: "cpu2".to_owned(), class: "rv64".to_owned(), isa: "imacfd".to_owned(), freq: 1000.0});

    // let json_ob = serde_json::to_string_pretty::<Soc>(&s);
    // match json_ob {
    //     Ok(json_str) => println!("{}", json_str),
    //     Err(_) => println!("json seri failed."),
    // }
    
}

