{ config, pkgs, ... }:

{
  home.username = "adityab";
  home.homeDirectory = "/home/adityab";
  home.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
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
    zsh
    zsh-completions
    zsh-autosuggestions

    # Languages / toolchains
    git
    gh
    sqlite
    nodejs
    bun
    go
    jdk17
    jdk8
    gradle
    python
    docker
    rustup
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

  programs.bash = {
    enable = true;
    # Source PATH order lives in ~/.bashrc + ~/.profile (REPORT §1).
    # Keep those files as the source of truth; only assert the nix-owned bits here.
    sessionVariables = {
      JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
      ANDROID_HOME = "$HOME/android";
      ANDROID_SDK_ROOT = "$HOME/android";
      GOPATH = "$HOME/go";
      DENO_DIR = "$HOME/.cache/deno";
    };
    bashrcExtra = ''
      # machines/blueprints/main/nix/home.nix: bun + deno shims (same order as source ~/.bashrc)
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      [ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
      export PATH="$HOME/.local/bin:$PATH"
      . "$HOME/.cargo/env" 2>/dev/null || true
      export ANDROID_HOME="$HOME/android"
      export ANDROID_SDK_ROOT="$HOME/android"
      export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
      # Custom prompt from source ~/.bashrc (green user, blue cwd)
      export PS1='\[\e[1;32m\]\u\[\e[1;34m\]:\w\[\e[1;0m\]\$ '
    '';
    profileExtra = ''
      [ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
      [ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
      . "$HOME/.deno/env" 2>/dev/null || true
      . "$HOME/.cargo/env" 2>/dev/null || true
    '';
  };

  programs.git = {
    enable = true;
    # Mirrors machines/presets/git/gitconfig (backup source).
    userName = "Aditya Borkar";
    userEmail = "aditya.borkar.programs@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      credential."https://github.com".helper = "!/usr/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!/usr/bin/gh auth git-credential";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      PROMPT=$'%{\e[1;32m%}%n%{\e[1;34m%}:%~%{\e[1;0m%}$ '
    '';
  };

  programs.gh = {
    enable = true;
    # Mirrors machines/presets/gh/config.yml (backup source).
    # ~/.config/gh/hosts.yml stays secret: run `gh auth login`, never commit it.
    settings = {
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };


  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Link repo presets into ~/.config so machines/presets/* stays the source of truth.
  # Source files live at ../../../presets/... relative to this machines/blueprints/main/nix/ dir.
  # Secrets (*.example, hosts.yml, credentials, npmrc, wakatime, ssh keys,
  # opencode auth.json, cloudflared cert.pem, mkcert rootCA-key.pem) are
  # NEVER linked here — re-auth manually per CONFIG.md §5 + presets/README.md.
  # Shell bashrc/profile + gitconfig are owned by programs.bash/programs.git
  # above; presets/shell/* and presets/git/* are reference backups only.
  home.file = {
    ".config/opencode-preset".source = ../../../presets/opencode/config.json;
    ".config/vscode-settings-preset".source = ../../../presets/vscode/settings.json;
    ".config/zed-settings-preset".source = ../../../presets/zed/settings.json;
    ".config/biome-settings-preset".source = ../../../presets/biome/settings.json;
    # Backups from CONFIG.md (safe text configs only)
    ".ssh/config".source = ../../../presets/ssh/config;
    ".config/gh/config.yml".source = ../../../presets/gh/config.yml;
    ".aws/config".source = ../../../presets/aws/config;
    ".docker/config.json".source = ../../../presets/docker/config.json;
    ".config/htop/htoprc".source = ../../../presets/htop/htoprc;
    ".config/systemd/user/openusage-telemetry.service".source = ../../../presets/systemd/openusage-telemetry.service;
    ".config/systemd/user/uma-machine.service".source = ../../../presets/systemd/uma-machine.service;
  };

  # Manual post-steps this file deliberately does NOT automate (see HOW_TO.md):
  # Run `gh auth login` and `gh auth setup-git`
  # - `rustup default stable` (source had no toolchain)
  # - nvm install 24.15.0 / bun add -g ... / npm i -g agent-browser
  # - pip ML stack in a venv (torch 2.13.0, easyocr 1.7.2, opencv, ...)
  # - Android SDK payload via sdkmanager + adb pair/connect
  # - mkcert -install, caddy/dnsmasq/cockpit system units, docker login,
  #   gh/aws/pulumi/eas/opencode re-auth, ssh key copy, cloudflared cert.
}
