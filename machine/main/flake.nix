{
  description = "Configuration for the primary machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
    let
      system = "x86_64-linux";
      username = builtins.getEnv "USER";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Apply with: nix run home-manager -- switch --flake ./machine/blueprints/main#adityab
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./packages.nix
          ./programs.nix
          ./secrets.nix
          ./services.nix
          sops-nix.homeManagerModules.sops
        ];
      };
    };
}
