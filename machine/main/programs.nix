{ pkgs, ... }:

{
  programs.home-manager = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    sessionVariables = {
      JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
      ANDROID_HOME = "$HOME/android";
      ANDROID_SDK_ROOT = "$HOME/android";
      GOPATH = "$HOME/go";
      DENO_DIR = "$HOME/.cache/deno";
    };
    bashrcExtra = builtins.readFile ../files/shell/bashrc-extra.sh;
    profileExtra = builtins.readFile ../files/shell/profile-extra.sh;
    logoutExtra = builtins.readFile ../files/shell/bash-logout.sh;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = builtins.readFile ../files/shell/zsh-init-extra.zsh;
  };

  programs.git = {
    enable = true;
    userName = "Aditya Borkar";
    userEmail = "aditya.borkar.programs@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      credential."https://github.com".helper = "!/usr/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!/usr/bin/gh auth git-credential";
    };
  };

  programs.gh = {
    enable = true;
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
    matchBlocks."*" = {
      hashKnownHosts = true;
      addKeysToAgent = "yes";
      identitiesOnly = false;
    };
  };
}
