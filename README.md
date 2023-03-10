# cache-cargo-install-action

[![release](https://img.shields.io/github/release/taiki-e/cache-cargo-install-action?style=flat-square&logo=github)](https://github.com/taiki-e/cache-cargo-install-action/releases/latest)
[![build status](https://img.shields.io/github/actions/workflow/status/taiki-e/cache-cargo-install-action/ci.yml?branch=main&style=flat-square&logo=github)](https://github.com/taiki-e/cache-cargo-install-action/actions)

GitHub Action for `cargo install` with cache.

This is intended for installing crates that are not supported by [install-action].
For performance and robustness, we recommend using [install-action] if the tool is supported by [install-action].

- [Usage](#usage)
  - [Inputs](#inputs)
  - [Example workflow](#example-workflow)
- [Migrate from/to install-action](#migrate-fromto-install-action)
- [Compatibility](#compatibility)
- [Related Projects](#related-projects)
- [License](#license)

## Usage

### Inputs

| Name | Required | Description         | Type    | Default |
| ---- |:--------:| ------------------- | ------- | ------- |
| tool | **true** | Crate to install    | String  |         |

### Example workflow

```yaml
- uses: taiki-e/cache-cargo-install-action@v1
  with:
    tool: cargo-hack
```

To install a specific version, use `@version` syntax:

```yaml
- uses: taiki-e/cache-cargo-install-action@v1
  with:
    tool: cargo-hack@0.5.24
```

Omitting minor/patch versions is not supported yet.

## Migrate from/to install-action

This action provides an interface compatible with [install-action].

Therefore, migrating from/to [install-action] is usually just a change of action to be used. (if the tool and version are supported by install-action or install-action's `binstall` fallback)

To migrate from this action to install-action:

```diff
- - uses: taiki-e/cache-cargo-install-action@v1
+ - uses: taiki-e/install-action@v2
    with:
      tool: cargo-hack
```

To migrate from install-action to this action:

```diff
- - uses: taiki-e/install-action@v2
+ - uses: taiki-e/cache-cargo-install-action@v1
    with:
      tool: cargo-hack
```

The interface of this action is a subset of the interface of [install-action], so note the following limitations when migrating from install-action to this action.

- install-action supports specifying multiple crates in a single action call, but this action does not.

  For example, in install-action, you can write:

  ```yaml
  - uses: taiki-e/install-action@v2
      with:
        tool: cargo-hack,cargo-minimal-versions
  ```

  In this action, you need to write:

  ```yaml
  - uses: taiki-e/cache-cargo-install-action@v1
      with:
        tool: cargo-hack
  - uses: taiki-e/cache-cargo-install-action@v1
      with:
        tool: cargo-minimal-versions
  ```

- install-action supports omitting minor/patch versions, but this action does not.

- install-action supports `@<tool_name>` shorthand, but this action does not.

## Compatibility

This action has been tested for GitHub-hosted runners (Ubuntu, macOS, Windows) and containers (Ubuntu, Debian, Alpine, Fedora, CentOS, Rocky).
To use this action in self-hosted runners or in containers, you will need to install at least the following:

- bash
- GNU tar
- cargo

## Related Projects

- [install-action]: GitHub Action for installing development tools (mainly from GitHub Releases).
- [create-gh-release-action]: GitHub Action for creating GitHub Releases based on changelog.
- [upload-rust-binary-action]: GitHub Action for building and uploading Rust binary to GitHub Releases.
- [setup-cross-toolchain-action]: GitHub Action for setup toolchains for cross compilation and cross testing for Rust.

[create-gh-release-action]: https://github.com/taiki-e/create-gh-release-action
[setup-cross-toolchain-action]: https://github.com/taiki-e/setup-cross-toolchain-action
[upload-rust-binary-action]: https://github.com/taiki-e/upload-rust-binary-action
[install-action]: https://github.com/taiki-e/install-action

## License

Licensed under either of [Apache License, Version 2.0](LICENSE-APACHE) or
[MIT license](LICENSE-MIT) at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall
be dual licensed as above, without any additional terms or conditions.
