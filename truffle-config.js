const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*", // Match any network id
      // gas: 8500000,
      // gasPrice: 1000000000,  // 1 gwei (in wei) (default: 100 gwei)
    },
    live: {
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, process.env.KOVAN_RPC_URL)
      },
      network_id: '*',
      // ~~Necessary due to https://github.com/trufflesuite/truffle/issues/1971~~
      // Necessary due to https://github.com/trufflesuite/truffle/issues/3008
      skipDryRun: true,
    },
    testnet: {
      provider: () => new HDWalletProvider('obey tone fragile mail pig fork fan act delay frog crumble into', `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    bsc: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  // contracts_directory: './src/contracts/',
  // contracts_build_directory: './src/abis/',
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.0", // A version or constraint - Ex. "^0.5.0"
    }
  }
}
