{ config, ... }:

# Secrets live encrypted in ../secrets.yaml (age key: ~/.config/sops/age/keys.txt)
# and are decrypted to ~ at activation. Edit with: sops ../secrets.yaml
# (run from machine/blueprints/main so .sops.yaml is found).
# Plaintext presets for these files are intentionally NOT in the repo.
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets.yaml;
    secrets = {
      aws_credentials = {
        path = "${config.home.homeDirectory}/.aws/credentials";
        mode = "0600";
      };
      gh_hosts = {
        path = "${config.home.homeDirectory}/.config/gh/hosts.yml";
        mode = "0600";
      };
      npmrc = {
        path = "${config.home.homeDirectory}/.npmrc";
        mode = "0600";
      };
      eas_settings = {
        path = "${config.home.homeDirectory}/.config/eas-cli-nodejs/user-settings.json";
        mode = "0644";
      };
      opencode_config = {
        path = "${config.home.homeDirectory}/.config/opencode/opencode.json";
        mode = "0644";
      };
      wakatime_cfg = {
        path = "${config.home.homeDirectory}/.wakatime.cfg";
        mode = "0644";
      };
    };
  };
}
