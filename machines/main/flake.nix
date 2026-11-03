{
  description = "Configuration for the primary machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      gitName =
        let v = builtins.getEnv "GIT_NAME";
        in if v == "" then throw "GIT_NAME is not set. Run with GIT_NAME=\"Your Name\" GIT_EMAIL=\"you@example.com\" (requires --impure for getEnv)." else v;
      gitEmail =
        let v = builtins.getEnv "GIT_EMAIL";
        in if v == "" then throw "GIT_EMAIL is not set. Run with GIT_NAME=\"Your Name\" GIT_EMAIL=\"you@example.com\" (requires --impure for getEnv)." else v;
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username gitName gitEmail; };
        modules = [
          ./home.nix
          ./packages.nix
          ./programs.nix
          ./bun.nix
          sops-nix.homeManagerModules.sops
        ];
      };
    };
}
