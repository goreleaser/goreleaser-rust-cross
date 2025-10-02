# Example Rust project

This is an example Rust project to demonstrate how to use `goreleaser-rust-cross` docker image to cross-compile to various targets.

```sh
  docker run \
    --rm \
    -v $(pwd):/usr/src/myapp \
    -w /usr/src/myapp \
    ghcr.io/goreleaser/goreleaser-rust-cross:<goreleaser-version> \
    release --snapshot --clean
```
