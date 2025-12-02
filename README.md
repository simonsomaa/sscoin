# sscoin

A simple fungible token-style smart contract written in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-language) and managed with [Clarinet](https://docs.hiro.so/clarinet).

## Project structure

- `Clarinet.toml` – Clarinet project configuration.
- `contracts/sscoin.clar` – main sscoin smart contract.
- `settings/Devnet.toml` – local Devnet configuration (accounts, devnet options).
- `LICENSE` – project license.

## Requirements

- [Clarinet](https://docs.hiro.so/clarinet) `>= 3.10.0` installed and available on your `PATH`.

You can verify your installation with:

```bash path=null start=null
clarinet --version
```

## Contract overview

The `sscoin` contract implements a simple fungible-token style ledger with:

- A single owner (set on first initialization).
- A configurable initial supply.
- Per-account balances tracked in a map.
- Public functions to initialize, transfer, mint, and burn tokens.
- Read-only functions to inspect balances, total supply, and current owner.

### Data model

- `contract-owner : (optional principal)` – the owner of the contract (set once).
- `total-supply : uint` – total number of tokens in circulation.
- `balances : { account: principal } -> { balance: uint }` – balance mapping.

### Public functions

- `initialize(initial-supply uint)`
  - Can be called exactly once.
  - Sets `contract-owner` to `tx-sender`.
  - Mints `initial-supply` tokens to `tx-sender`.
  - Returns `(ok true)` on success, or `ERR-ALREADY-INITIALIZED` if called again.

- `transfer(amount uint, sender principal, recipient principal)`
  - Moves `amount` from `sender` to `recipient`.
  - Fails with `ERR-NOT-ENOUGH-BALANCE` if `sender` lacks sufficient balance.

- `mint(amount uint, recipient principal)`
  - Mints new tokens to `recipient`.
  - Only callable by the current `contract-owner`.
  - Increases `total-supply`.

- `burn(amount uint, from principal)`
  - Burns tokens from `from`.
  - Only callable by the current `contract-owner`.
  - Decreases `total-supply`.

### Read-only functions

- `get-owner()` → `(ok (optional principal))`
- `get-total-supply()` → `(ok uint)`
- `get-balance(account principal)` → `(ok uint)`

## Development

### Checking the contract

From the project root (`sscoin/`):

```bash path=null start=null
clarinet check
```

This will:

- Parse and type-check all contracts declared in `Clarinet.toml`.
- Use the local Devnet configuration under `settings/`.

### Running a console (REPL)

You can load the contract into Clarinet’s console for interactive exploration:

```bash path=null start=null
clarinet console
```

From the console, you can call functions like `initialize`, `transfer`, `mint`, and `burn` using simulated principals.

### Suggested next steps

- Add TypeScript tests under a `tests/` directory and wire them up with `vitest` (Clarinet’s default).
- Extend the contract to conform to the SIP-010 fungible token trait.
- Add access controls or additional roles (e.g. minters, pausers) as needed.

## License

See `LICENSE` for license information.
