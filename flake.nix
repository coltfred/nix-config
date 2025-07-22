{
  description = "colt nix cross-platform system configurations";

  nixConfig = {
    bash-prompt = "";
    bash-prompt-suffix = "(nixflake)#";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ironhide.url = "git+ssh://git@github.com/IronCoreLabs/ironhide?ref=main";
  };

  outputs = inputs @ {
    self,
    darwin,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  }: let
    username = "colt";
    # Configuration for `nixpkgs`
    nixpkgsConfig = {
      config = {
        allowUnsupportedSystem = true;
        allowBroken = false;
        allowUnfree = true;
        experimental-features = "nix-command flakes";
        keep-derivations = true;
        keep-outputs = true;
      };
    };
  in {
    darwinConfigurations = let
      system = "aarch64-darwin";
    in {
      inherit system;
      breq = darwin.lib.darwinSystem {
        pkgs = import nixpkgs-unstable {
          inherit system;
          inherit (nixpkgsConfig) config;
          overlays = [
            (_: prev: {
              stable = import nixpkgs {
                inherit system;
                inherit (nixpkgsConfig) config;
              };
            })
            (
              _: prev: {
                ironhide =
                  inputs.ironhide.packages.${prev.stdenv.system}.ironhide;
              }
            )
          ];
        };
        specialArgs = {
          inherit inputs darwin username nixpkgs;
        };
        modules = [
          ./modules/darwin
          {homebrew.brewPrefix = "/opt/homebrew/bin";}
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {inherit inputs darwin username;};
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              users."${username}" = {
                imports = [
                  ./modules/home-manager
                  {
                    home.sessionVariables = {
                      NIX_PATH = "nixpkgs=${nixpkgs-unstable}:stable=${nixpkgs}\${NIX_PATH:+:}$NIX_PATH";
                    };
                  }
                ];
              };
            };
          }
        ];
      };
    };
  };
}
