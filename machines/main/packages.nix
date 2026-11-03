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
    gradle
    python3
    docker
    awscli2
    pulumi
    cloudflared
    act
    google-chrome
    zed-editor
    opencode
  ];
}
