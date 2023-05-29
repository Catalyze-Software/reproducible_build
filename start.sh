#! /bin/bash
sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >> rustup.sh
sh rustup.sh -y
rm -rf rustup.sh
rustup target add wasm32-unknown-unknown
dfx start --background
dfx deploy parent