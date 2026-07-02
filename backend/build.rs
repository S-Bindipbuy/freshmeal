fn main() {
    prost_build::Config::new()
        .compile_protos(&["../schema/freshmeal.proto"], &["../schema"])
        .unwrap();
    println!("cargo:rerun-if-changed=../schema/freshmeal.proto");
}
