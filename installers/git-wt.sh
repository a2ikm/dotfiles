#!/bin/bash
set -euo pipefail

INSTALL_DIR="${HOME}/bin"

# OS 判定
detect_os() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin) echo "darwin" ;;
    Linux)  echo "linux" ;;
    *)
      echo "Unsupported OS: $os" >&2
      exit 1
      ;;
  esac
}

# アーキテクチャ判定
detect_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64)       echo "amd64" ;;
    amd64)        echo "amd64" ;;
    aarch64)      echo "arm64" ;;
    arm64)        echo "arm64" ;;
    *)
      echo "Unsupported architecture: $arch" >&2
      exit 1
      ;;
  esac
}

main() {
  local os arch version download_url filename tmpdir

  os="$(detect_os)"
  arch="$(detect_arch)"

  echo "Detected: OS=$os, Arch=$arch"

  # GitHub API から最新リリース情報を取得
  echo "Fetching latest release info..."
  local release_info
  release_info="$(curl -fsSL https://api.github.com/repos/k1LoW/git-wt/releases/latest)"

  version="$(echo "$release_info" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
  echo "Latest version: $version"

  # OS に応じた拡張子を決定
  local ext
  if [ "$os" = "darwin" ]; then
    ext="zip"
  else
    ext="tar.gz"
  fi

  # ダウンロード URL を構築
  filename="git-wt_${version}_${os}_${arch}.${ext}"
  download_url="$(echo "$release_info" | grep '"browser_download_url":' | grep "$filename" | sed -E 's/.*"([^"]+)".*/\1/')"

  if [ -z "$download_url" ]; then
    echo "Could not find download URL for $filename" >&2
    exit 1
  fi

  echo "Downloading: $download_url"

  # 一時ディレクトリを作成
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir:-}"' EXIT

  # ダウンロード
  curl -fsSL -o "${tmpdir}/${filename}" "$download_url"

  # インストールディレクトリを作成
  mkdir -p "$INSTALL_DIR"

  # 展開してインストール
  echo "Installing to $INSTALL_DIR..."
  if [ "$ext" = "zip" ]; then
    unzip -q -o "${tmpdir}/${filename}" -d "$tmpdir"
  else
    tar -xzf "${tmpdir}/${filename}" -C "$tmpdir"
  fi

  # バイナリをコピー
  cp "${tmpdir}/git-wt" "$INSTALL_DIR/"
  chmod +x "${INSTALL_DIR}/git-wt"

  echo "Successfully installed git-wt ${version} to ${INSTALL_DIR}/git-wt"
}

main "$@"
