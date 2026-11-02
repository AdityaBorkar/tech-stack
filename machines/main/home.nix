{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
    ANDROID_HOME = "$HOME/android";
    ANDROID_SDK_ROOT = "$HOME/android";
    GOPATH = "$HOME/go";
  };

  home.file = {
    ".bashrc".source = ./files/.bashrc;
    ".profile".source = ./files/.profile;
    ".bash_logout".source = ./files/.bash_logout;
    ".zshrc".source = ./files/.zshrc;
    ".aws/config".source = ./files/.aws/config;
    ".docker/config.json".source = ./files/.docker/config.json;
    ".config/htop/htoprc".source = ./files/.config/htop/htoprc;
    ".ssh/known_hosts".source = ./files/.ssh/known_hosts;
    ".config/opencode/AGENTS.md".source = ./files/.config/opencode/AGENTS.md;
    ".config/opencode/agents/ask.md".source = ./files/.config/opencode/agents/ask.md;
    ".config/opencode/agents/codebase-memory.md".source = ./files/.config/opencode/agents/codebase-memory.md;
    ".config/opencode/agents/codebase-memory-auditor.md".source = ./files/.config/opencode/agents/codebase-memory-auditor.md;
    ".config/opencode/agents/codebase-memory-scout.md".source = ./files/.config/opencode/agents/codebase-memory-scout.md;
    ".config/opencode/cli.json".source = ./files/.config/opencode/cli.json;
    ".config/opencode/commands/improve-comments.md".source = ./files/.config/opencode/commands/improve-comments.md;
    ".config/opencode/commands/recommend-packages.md".source = ./files/.config/opencode/commands/recommend-packages.md;
    ".config/opencode/commands/recommend-tools.md".source = ./files/.config/opencode/commands/recommend-tools.md;
    ".config/opencode/plugins/cbm-augment.ts".source = ./files/.config/opencode/plugins/cbm-augment.ts;
    ".config/opencode/plugins/rtk.ts".source = ./files/.config/opencode/plugins/rtk.ts;
    ".config/opencode/skills/codebase-memory/SKILL.md".source = ./files/.config/opencode/skills/codebase-memory/SKILL.md;
    ".config/opencode/skills/use-docucraft/SKILL.md".source = ./files/.config/opencode/skills/use-docucraft/SKILL.md;
    ".config/Code/User/settings.json".source = ./files/.config/Code/User/settings.json;
    ".config/zed/settings.json".source = ./files/.config/zed/settings.json;
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets.yaml;

    secrets = {
      aws_prod_access_key_id = { };
      aws_prod_secret_access_key = { };
      aws_dev_access_key_id = { };
      aws_dev_secret_access_key = { };
      gh_oauth_token = { };
      npm_auth_token = { };
      eas_analytics_device_id = { };
      opencode_context7_api_key = { };
      wakatime_api_key = { };
    };

    templates = {
      "aws-credentials" = {
        path = "${config.home.homeDirectory}/.aws/credentials";
        mode = "0600";
        content = builtins.replaceStrings
          [
            "@@AWS_PROD_ACCESS_KEY_ID@@"
            "@@AWS_PROD_SECRET_ACCESS_KEY@@"
            "@@AWS_DEV_ACCESS_KEY_ID@@"
            "@@AWS_DEV_SECRET_ACCESS_KEY@@"
          ]
          [
            config.sops.placeholder.aws_prod_access_key_id
            config.sops.placeholder.aws_prod_secret_access_key
            config.sops.placeholder.aws_dev_access_key_id
            config.sops.placeholder.aws_dev_secret_access_key
          ]
          (builtins.readFile ./files/.aws/credentials);
      };

      "gh-hosts" = {
        path = "${config.home.homeDirectory}/.config/gh/hosts.yml";
        mode = "0600";
        content = builtins.replaceStrings
          [ "@@GH_OAUTH_TOKEN@@" ]
          [ config.sops.placeholder.gh_oauth_token ]
          (builtins.readFile ./files/.config/gh/hosts.yml);
      };

      "npmrc" = {
        path = "${config.home.homeDirectory}/.npmrc";
        mode = "0600";
        content = builtins.replaceStrings
          [ "@@NPM_AUTH_TOKEN@@" ]
          [ config.sops.placeholder.npm_auth_token ]
          (builtins.readFile ./files/.npmrc);
      };

      "eas-settings" = {
        path = "${config.home.homeDirectory}/.config/eas-cli-nodejs/user-settings.json";
        mode = "0644";
        content = builtins.replaceStrings
          [ "@@EAS_ANALYTICS_DEVICE_ID@@" ]
          [ config.sops.placeholder.eas_analytics_device_id ]
          (builtins.readFile ./files/.config/eas-cli-nodejs/user-settings.json);
      };

      "opencode-config" = {
        path = "${config.home.homeDirectory}/.config/opencode/opencode.json";
        mode = "0644";
        content = builtins.replaceStrings
          [ "@@OPENCODE_CONTEXT7_API_KEY@@" ]
          [ config.sops.placeholder.opencode_context7_api_key ]
          (builtins.readFile ./files/.config/opencode/opencode.json);
      };

      "wakatime-cfg" = {
        path = "${config.home.homeDirectory}/.wakatime.cfg";
        mode = "0644";
        content = builtins.replaceStrings
          [ "@@WAKATIME_API_KEY@@" ]
          [ config.sops.placeholder.wakatime_api_key ]
          (builtins.readFile ./files/.wakatime.cfg);
      };
    };
  };
}
