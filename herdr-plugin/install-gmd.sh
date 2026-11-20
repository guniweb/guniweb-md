#!/bin/sh
# Build step of the herdr plugin: make sure a gmd binary is available.
#
# Uses gmd from PATH when present. Otherwise downloads the release matching
# this plugin's version from GitHub, verifies it against SHA256SUMS and puts
# it into ./bin/gmd, where view.sh finds it.

set -eu

repo=guniweb/guniweb-md
version=$(sed -n 's/^version = "\(.*\)"$/\1/p' herdr-plugin.toml | head -n 1)

if command -v gmd >/dev/null 2>&1; then
  printf 'guniweb-md: using gmd from PATH (%s)\n' "$(command -v gmd)"
  exit 0
fi

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) target=aarch64-apple-darwin ;;
  Darwin-x86_64) target=x86_64-apple-darwin ;;
  Linux-x86_64) target=x86_64-unknown-linux-musl ;;
  Linux-aarch64 | Linux-arm64) target=aarch64-unknown-linux-gnu ;;
  *)
    printf 'guniweb-md: no prebuilt gmd for %s %s; install it with\n' "$(uname -s)" "$(uname -m)" >&2
    printf '  cargo install --git https://github.com/%s --locked\n' "$repo" >&2
    exit 1
    ;;
esac

if command -v sha256sum >/dev/null 2>&1; then
  sha() { sha256sum "$1" | awk '{print $1}'; }
else
  sha() { shasum -a 256 "$1" | awk '{print $1}'; }
fi

archive=gmd-$version-$target.tar.gz
base=https://github.com/$repo/releases/download/v$version
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

printf 'guniweb-md: downloading %s\n' "$archive"
curl -fsSL -o "$tmp/$archive" "$base/$archive"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"

expected=$(awk -v f="$archive" '$2 == f {print $1}' "$tmp/SHA256SUMS")
actual=$(sha "$tmp/$archive")
if [ -z "$expected" ] || [ "$expected" != "$actual" ]; then
  printf 'guniweb-md: checksum mismatch for %s\n' "$archive" >&2
  exit 1
fi

tar -xzf "$tmp/$archive" -C "$tmp"
mkdir -p bin
install -m 755 "$tmp/gmd-$version-$target/gmd" bin/gmd
printf 'guniweb-md: installed gmd %s to %s/bin/gmd\n' "$version" "$PWD"
