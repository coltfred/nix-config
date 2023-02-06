{
  description = "colt nix cross-platform system configurations";

  nixConfig = {
    bash-prompt = "";
    bash-prompt-suffix = "(nixflake)#";
  };

  inputs = {
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ironhide.url = "git+ssh://git@github.com/IronCoreLabs/ironhide-rs?ref=main";
  };

  outputs = inputs@{ self, darwin, nixpkgs-master, nixpkgs, nixpkgs-unstable
    , home-manager, ... }:
    let
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

      overlays = {
        # Overlays to add different versions `nixpkgs` into package set
        master = _: prev: {
          master = import nixpkgs-master {
            inherit (prev.stdenv) system;
            inherit (nixpkgsConfig) config;
          };
        };
        stable = _: prev: {
          stable = import nixpkgs {
            inherit (prev.stdenv) system;
            inherit (nixpkgsConfig) config;
          };
        };
        unstable = _: prev: {
          unstable = import nixpkgs-unstable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsConfig) config;
          } // {
            ironhide =
              inputs.ironhide.packages.${prev.stdenv.system}.ironhide-rs;
          };
        };
        apple-silicon = _: prev:
          nixpkgs-unstable.lib.optionalAttrs
          (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs-unstable {
              system = "x86_64-darwin";
              inherit (nixpkgsConfig) config;
            };
          };
      };
    in {

      darwinConfigurations = {
        breq = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            inherit (nixpkgsConfig) config;
            overlays = with overlays; [ master stable unstable apple-silicon
            (_: prev: {
            ironhide =
                inputs.ironhide.packages.${prev.stdenv.system}.ironhide-rs;
              }
            )
             ];
          };
          specialArgs = {
            inherit inputs darwin username nixpkgs-unstable nixpkgs;
          };
          modules = [
            ./modules/darwin
            { homebrew.brewPrefix = "/opt/homebrew/bin"; }
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = { inherit inputs darwin username; };
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "bak";
                users.colt = {
                  imports = [
                    ./modules/home-manager
                    {
                      home.sessionVariables = {
                        NIX_PATH =
                          "nixpkgs=${nixpkgs-unstable}:stable=${nixpkgs}\${NIX_PATH:+:}$NIX_PATH";
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
