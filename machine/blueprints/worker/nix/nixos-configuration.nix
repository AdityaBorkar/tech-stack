{ config, pkgs, ... }:

{
  boot.loader.grub.devices = [ "nodev" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  networking.hostName = "wsl-target";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Asia/Kolkata";
  system.stateVersion = "25.05";
  # WSL interop needs the nixos-wsl input (not in flake.nix) — leave off.
  # wsl.enable = true;

  users.users.adityab = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.bash;
  };
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    # Not understood why
    pkg-config
    gcc
    gnumake
    autoconf
    automake
    binutils
    patch
    libtool
    gnome-keyring
    xorg.xvfb

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

    # Languages / toolchains
    git
    gh
    sqlite
    nodejs
    bun
    go
    rustup
    jdk17
    jdk8
    gradle
    python
    docker
    awscli2
    pulumi
    cloudflared
    act
    google-chrome
    zed-editor
    opencode

    # NOTE: EAS/Expo, agent-browser, context7-mcp, githits, expect-cli,
    # pi-coding-agents are NOT in nixpkgs — reinstall via bun/npm per HOW_TO §4.
    # pacman-contrib is Arch-only (paccache etc.) — no nixpkgs equivalent; skip on NixOS/Ubuntu.
  ];
  # Java default must stay 17 (source: update-alternatives -> java-17).
  # If jdk8 is needed for legacy builds, call it explicitly:
  #   /nix/store/...-jdk8/bin/java
  environment.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
  };

  fonts.packages = with pkgs; [
    freefont_ttf
    ipafont
    liberation_ttf
    noto-fonts-color-emoji
    unifont
    wqy_zenhei
  ];

  programs.ssh.startAgent = true;

  programs.gnupg.agent.enable = true;

  # # REPORT §2.3 — services that were APT system units on source
  # services.caddy = {
  #   enable = true;
  #   # Source /etc/caddy/Caddyfile was the stock `:80 file_server` default.
  #   # Paste your real Caddyfile here when migrating off the default.
  #   virtualHosts."http://localhost".extraConfig = ''
  #     root * /srv/www
  #     file_server
  #   '';
  # };

  # services.dnsmasq = {
  #   enable = true;
  #   # Source: dnsmasq 2.91 stock, no custom /etc/dnsmasq.d observed.
  #   # Add extraConfig here if you exported custom rules.
  # };

  # services.cockpit = {
  #   enable = true;
  # };

  virtualisation.docker = {
    enable = true;
  };

  # Deploy preset backups to /etc on NixOS (Path B). On Ubuntu/WSL (Path A)
  # copy manually: sudo cp machines/presets/<name> /etc/<name>.
  # See machines/presets/README.md + CONFIG.md §4.
  environment.etc = {
    "wsl.conf".source = ../../../presets/wsl/wsl.conf;
    "caddy/Caddyfile".source = ../../../presets/caddy/Caddyfile;
    "dnsmasq.conf".source = ../../../presets/dnsmasq/dnsmasq.conf;
    "cockpit/disallowed-users".source = ../../../presets/cockpit/disallowed-users;
  };

  # Everything secret or stateful stays OUT of this file (REPORT §5):
  # ~/.ssh/id_ed25519, ~/.aws/credentials, gh hosts.yml, pulumi credentials.json,
  # opencode auth.json, cloudflared cert.pem, mkcert rootCA-key.pem,
  # ~/.pulumi stacks/, ~/android payload, browser profiles, DB files.
}
