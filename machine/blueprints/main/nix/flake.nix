{
  description = "Configuration for the primary machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Apply with: nix run home-manager -- switch --flake ./machines/blueprints/main/nix#adityab
      homeConfigurations."adityab" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };

      # Apply with: sudo nixos-rebuild switch --flake ./machines/blueprints/main/nix#wsl-target
      nixosConfigurations."wsl-target" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./nixos-configuration.nix ];
      };
    };
}
