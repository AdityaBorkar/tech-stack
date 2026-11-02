{ pkgs, gitName, gitEmail, ... }:

{
  programs.home-manager = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = gitName;
      user.email = gitEmail;
      init.defaultBranch = "dev";
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
    settings."*" = {
      HashKnownHosts = true;
      AddKeysToAgent = "yes";
      IdentitiesOnly = false;
    };
  };
}
