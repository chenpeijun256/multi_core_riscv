use std::net::{TcpListener, TcpStream};
use std::io::{Read, Write};

use std::thread;

use crate::utils;
use crate::config;
use crate::rv32_actor::Rv32Actor;

pub struct GdbServer {
    no_ack_mode: bool,
}

impl GdbServer {

    fn load_file() -> Rv32Actor {
        config::build_soc("rv32im.cfg".to_owned())
    }

    fn pack_rsp(&self, s: &str) -> String {
        let mut res = String::new();

        if self.no_ack_mode {
            res.push_str("$");
        } else {
            res.push_str("+$");
        }
        res.push_str(s);
        res.push('#');
        let sum = utils::str_add_sum(s);
        res.push_str(&utils::u8_to_hex(sum));

        res
    }

    fn handle_rsp(&mut self, soc: &mut Rv32Actor, in_str: String) -> Option<String> {
        let ss_str: Vec<&str> = in_str.split(&['$','#']).collect();
        if ss_str.len() >= 3 {
            let sum = utils::str_add_sum(ss_str[1]);
            let sum2 = utils::hex_to_u8(&ss_str[2][0..2]);
            println!("sum check: {sum} .. {sum2}");
            if sum == sum2 {
                let out_str;
                if ss_str[1].starts_with("qSupported") {
                    out_str = self.pack_rsp("PacketSize=1024;hwbreak+;QStartNoAckMode+");
                } else if ss_str[1].eq("QStartNoAckMode") {
                    out_str = self.pack_rsp("OK");
                    self.no_ack_mode = true;
                } else if ss_str[1].eq("?") {
                    out_str = self.pack_rsp("S05");
                } else if ss_str[1].eq("qAttached") {
                    out_str = self.pack_rsp("0");
                } else if ss_str[1].eq("g") {
                    out_str = self.pack_rsp(&soc.gdb_g());
                } else if ss_str[1].starts_with("p") {
                    let index = utils::hex_to_u32(&ss_str[1][1..]);
                    println!("index:{index}");
                    out_str = self.pack_rsp(&soc.gdb_p(index));
                } else if ss_str[1].starts_with("m") {
                    let start_size: Vec<&str> = ss_str[1][1..].split(',').collect();
                    if start_size.len() == 2 {
                        let start = utils::hex_to_u32(start_size[0]); 
                        let size = utils::hex_to_u32(start_size[1]);
                        println!("m start:{start}, size{size}");
                        out_str = self.pack_rsp(&soc.gdb_m(start, size));
                    } else {
                        out_str = self.pack_rsp("");
                    }
                } else if ss_str[1].starts_with("M") {
                    let start_size: Vec<&str> = ss_str[1][1..].split(&[',',':']).collect();
                    if start_size.len() == 3 {
                        let start = utils::hex_to_u32(start_size[0]); 
                        let size = utils::hex_to_u32(start_size[1]);
                        println!("M start:{start}, size{size}");
                        soc.gdb_upper_m(start, size, &start_size[2].to_owned());
                        out_str = self.pack_rsp("OK");
                    } else {
                        out_str = self.pack_rsp("");
                    }
                } else if ss_str[1].starts_with("vCont") {
                    out_str = self.pack_rsp("");
                } else if ss_str[1].starts_with("Z0") {
                    let start_size: Vec<&str> = ss_str[1].split(',').collect();
                    if start_size.len() == 3 {
                        let start = utils::hex_to_u32(start_size[1]); 
                        let size = utils::hex_to_u32(start_size[2]);
                        println!("Z0 start:{start}, size{size}");
                        if soc.gdb_bp() == 0 {
                            soc.gdb_set_bp(start);
                            out_str = self.pack_rsp("OK");
                        } else {
                            out_str = self.pack_rsp("");
                        }
                    } else {
                        out_str = self.pack_rsp("");
                    }
                } else if ss_str[1].starts_with("z0") {
                    let start_size: Vec<&str> = ss_str[1].split(',').collect();
                    if start_size.len() == 3 {
                        let start = utils::hex_to_u32(start_size[1]); 
                        let size = utils::hex_to_u32(start_size[2]);
                        println!("z0 start:{start}, size{size}");
                        if soc.gdb_bp() == start {
                            soc.gdb_set_bp(0);
                            out_str = self.pack_rsp("OK");
                        } else {
                            out_str = self.pack_rsp("");
                        }
                    } else {
                        out_str = self.pack_rsp("");
                    }
                } else if ss_str[1].eq("s") {
                    soc.gdb_s();
                    out_str = self.pack_rsp("S05");
                } else if ss_str[1].eq("c") {
                    soc.gdb_c();
                    out_str = self.pack_rsp("S05");
                } else if ss_str[1].eq("k") {
                    out_str = self.pack_rsp("OK");
                } else {
                    out_str = self.pack_rsp("");
                }
                println!("out: {out_str}");
                return Some(out_str);
            }
        }

        None
    }

    pub fn new() -> Self {
        GdbServer { no_ack_mode: false}
    }
}

   // Handles a single client
fn handle_client(mut stream: TcpStream) -> Result<(), std::io::Error> {
    println!("Incoming connection from: {}", stream.peer_addr()?);
    let mut buf = [0; 512];

    let mut soc = GdbServer::load_file();
    let mut gdb = GdbServer::new();
    loop {
        let bytes_read = stream.read(&mut buf)?;
        if bytes_read == 0 { 
            println!("read 0, return.");
            return Ok(()); 
        }
        // println!("in: {:?}", buf[..bytes_read].to_vec());
        match String::from_utf8(buf[0..bytes_read].to_vec()) {
            Ok(in_str) => {
                println!("in: {in_str}");
                match gdb.handle_rsp(&mut soc, in_str) {
                    Some(out_str) => {
                        stream.write(out_str.as_bytes()).unwrap();
                    }
                    None => println!("no response need."),
                };
            }
            Err(e) => println!("from utf8 error {e}."),
        }
    }
}

pub fn server_start() {
    let listener = TcpListener::bind("0.0.0.0:3333")
                                            .expect("Tcp listener bind failed.");
    for stream in listener.incoming() {
        match stream {
            Err(e) => { println!("failed: {e}") },
            Ok(stream) => {
                thread::spawn(move || {
                    handle_client(stream).
                        unwrap_or_else(|e| println!("{e}"));
                });
            },
        }
    }
}
