{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Build tools
    pkg-config
    gcc
    gnumake
    autoconf
    automake
    binutils
    patch
    libtool
    gnome-keyring
    xvfb

    # CLI essentials
    curl
    wget
    jq
    ripgrep
    lsof
    tree
    fd
    nettools
    unzip
    file
    acl
    nano

    # CLI tools
    btop
    ncdu
    fastfetch
    strace
    cockpit
    hyperfine
    mkcert
    ffmpeg
    caddy
    dnsmasq
    zsh
    zsh-completions
    zsh-autosuggestions
    zsh-syntax-highlighting

    # Languages / toolchains
    git
    gh
    sqlite
    nodejs
    bun
    go
    jdk17
    # jdk8 omitted: jdk8 + jdk17 both ship lib/openjdk/lib/ct.sym and buildEnv fails. Use `nix shell nixpkgs#jdk8` per-project when needed.
    gradle
    python3
    docker
    rustup
    awscli2
    pulumi
    cloudflared
    act
    google-chrome
    zed-editor
    opencode
  ];
}
