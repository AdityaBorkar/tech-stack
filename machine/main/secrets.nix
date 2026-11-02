{ config, ... }:

# Structure is world-readable here. Only leaf values live encrypted in ../secrets.yaml.
# Edit secrets with: sops ../secrets.yaml (run from machine/main so .sops.yaml is found).
{
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
        content = ''
          [production]
          aws_access_key_id = "${config.sops.placeholder.aws_prod_access_key_id}"
          aws_secret_access_key = "${config.sops.placeholder.aws_prod_secret_access_key}"

          [development]
          aws_access_key_id = "${config.sops.placeholder.aws_dev_access_key_id}"
          aws_secret_access_key = "${config.sops.placeholder.aws_dev_secret_access_key}"
        '';
      };

      "gh-hosts" = {
        path = "${config.home.homeDirectory}/.config/gh/hosts.yml";
        mode = "0600";
        content = ''
          github.com:
              users:
                  AdityaBorkar:
                      oauth_token: ${config.sops.placeholder.gh_oauth_token}
              git_protocol: https
              oauth_token: ${config.sops.placeholder.gh_oauth_token}
              user: AdityaBorkar
        '';
      };

      "npmrc" = {
        path = "${config.home.homeDirectory}/.npmrc";
        mode = "0600";
        content = ''
          //registry.npmjs.org/:_authToken=${config.sops.placeholder.npm_auth_token}
        '';
      };

      "eas-settings" = {
        path = "${config.home.homeDirectory}/.config/eas-cli-nodejs/user-settings.json";
        mode = "0644";
        content = ''
          {
            "analyticsDeviceId": "${config.sops.placeholder.eas_analytics_device_id}"
          }
        '';
      };

      "opencode-config" = {
        path = "${config.home.homeDirectory}/.config/opencode/opencode.json";
        mode = "0644";
        content = ''
          {
              "$schema": "https://opencode.ai/config.json",
              "lsp": true,
              "mcp": {
                  "context7": {
                      "type": "local",
                      "command": [
                          "context7-mcp",
                          "--api-key",
                          "${config.sops.placeholder.opencode_context7_api_key}"
                      ],
                      "enabled": true
                  },
                  "GitHits": {
                      "type": "local",
                      "command": [
                          "githits",
                          "mcp",
                          "start"
                      ],
                      "enabled": true
                  },
                  "codebase-memory-mcp": {
                      "command": [
                          "/home/aditya/.local/bin/codebase-memory-mcp"
                      ],
                      "type": "local",
                      "enabled": true
                  },
                  "codedb": {
                      "type": "local",
                      "command": [
                          "codedb",
                          "mcp"
                      ],
                      "enabled": false
                  },
                  "expect": {
                      "type": "local",
                      "command": [
                          "npx",
                          "-y",
                          "expect-cli@latest",
                          "mcp"
                      ],
                      "enabled": false
                  }
              },
              "autoupdate": true,
              "share": "disabled",
              "username": "adityaborkar",
              "permissions": [
                  {
                      "action": "external_directory",
                      "resource": "~/.agents/*",
                      "effect": "allow"
                  },
                  {
                      "action": "external_directory",
                      "resource": "/tmp/*",
                      "effect": "allow"
                  }
              ]
          }
        '';
      };

      "wakatime-cfg" = {
        path = "${config.home.homeDirectory}/.wakatime.cfg";
        mode = "0644";
        content = ''
          [settings]
          api_key = ${config.sops.placeholder.wakatime_api_key}
        '';
      };
    };
  };
}
