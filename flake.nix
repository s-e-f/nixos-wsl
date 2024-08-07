{
  description = "My NixOS root flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kanagawa = {
      type = "github";
      owner = "s-e-f";
      repo = "kanagawa.nvim";
      flake = false;
    };
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    flake-utils.url = "github:numtide/flake-utils";
    nur.url = "github:nix-community/nur";
    zjstatus.url = "github:dj95/zjstatus";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      kanagawa,
      flake-utils,
      nur,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./nixos
            nur.nixosModules.nur
          ];
        };
      };

      homeConfigurations.sef = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./sef ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            vscode-langservers-extracted
            nil
            nixfmt-rfc-style
          ];
        };
      }
    );
}
