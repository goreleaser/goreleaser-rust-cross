# goreleaser-rust-cross

> 🚀 Help me to become a full-time open-source developer by [sponsoring me on GitHub](https://github.com/sponsors/vedantmgoyal9)

Docker image for cross-compiling Rust projects with GoReleaser.

TODO:
- [ ] Add chocolatey

## Installed tools

- `rustup`/`cargo` (stable - 1.84.0) - you can install other toolchains as needed
- [`cargo-zigbuild`](https://github.com/rust-cross/cargo-zigbuild) (thanks to [**@messense**](https://github.com/messense))
- [`zig`](https://ziglang.org)
- [`cargo-xwin`](https://github.com/rust-cross/cargo-xwin) (thanks to [**@messense**](https://github.com/messense) and [**@Jake-Shadle**](https://github.com/Jake-Shadle))
- Microsoft CRT headers and libraries
- Windows SDK headers and libraries
- MacOSX11.3.sdk

> **By using this software you are consented to accept the license at https://go.microsoft.com/fwlink/?LinkId=2086102**

> [**Please ensure you have read and understood the Xcode license terms before continuing.**](https://www.apple.com/legal/sla/docs/xcode.pdf)

## Docker

### Environment variables

- [GoReleaser](https://github.com/goreleaser/goreleaser) variables.
- `GPG_KEY` (optional) - defaults to /secrets/key.gpg. Ignored if file not found.
- `DOCKER_CREDS_FILE` (optional) - path to JSON file with docker login credentials. Useful when push to multiple docker registries required.
- `DOCKER_FAIL_ON_LOGIN_ERROR` (optional) - fail on docker login error.

### Login to registry

#### Github Actions

Use [docker login](https://github.com/docker/login-action) to auth to repos and mount docker config file. For example:

```shell
docker run -v $(HOME)/.docker/config.json:/root/.docker/config.json ...
```

#### Docker Creds file

To login from within `goreleaser-rust-cross` container, create creds file.

```json
{
    "registries": [
        {
            "user": "<username>",
            "pass": "<password>",
            "registry": "<registry-url>" // for e.g. ghcr.io
        }
    ]
}
```

## License

This work is released under the MIT license. A copy of the license is provided in the [LICENSE](./LICENSE) file.
