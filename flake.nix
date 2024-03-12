{
  description = "ghc flakr - devenv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    pre-commit.url = "github:cachix/pre-commit-hooks.nix";
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs = inputs:
    inputs.parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.devshell.flakeModule inputs.pre-commit.flakeModule];
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {
        config,
        pkgs,
        lib,
        ...
      }: {
        pre-commit = {
          check.enable = true;
          settings = {
            hooks = {
              alejandra.enable = true;
              ormolu.enable = true;
              hlint.enable = true;
            };
            default_stages = [];
          };
        };
        apps = rec {
          default = hs-run;
          hs-run.program = config.packages.hs-run;
        };
        packages = let
          /*
          NOTE:
          - do package overrides here
          - add packages here (callHackage, callHackageDirect, overrideSrc, callCabal2nix)
          - if you want a different compiler, instead of `haskellPackages` use
            `haskell.pacakges.ghcxx` or `haskell.packages.ghcxxx`, be aware that this will
            potentially worsen the caching situation
          - for available overrides, visit:
            https://nixos.org/manual/nixpkgs/unstable/#haskell-overriding-haskell-packages
          */
          hspkgs = with pkgs.haskell.lib.compose;
            pkgs.haskell.packages.ghc94.override {
              overrides = hself: hsuper: {
              };
            };
        in rec {
          default = hs-run;
          /*
          NOTE:
          - if no arguments are supplied, try to run ./main.hs
          - if any arguments are supplied, pass them on to runghc
          */
          hs-run = pkgs.writeShellScriptBin "hs-run" ''
            args="$@";
            if [ $# -eq 0 ]
            then
              args="main.hs";
            fi
            ${lib.getExe' config.packages.ghc "runghc"} \
              -f ${lib.getExe' config.packages.ghc "ghc"} \
              $args
          '';

          /*
          NOTE:
          - take tooling from the haskell packageset
          */
          inherit (hspkgs) haskell-language-server ormolu hlint;
          /*
          NOTE:
          - tooling to add to the environment of the ghc
          - everything added here will be visible by the ghc in
            this environment and the hs-run script
          */
          ghc = hspkgs.ghcWithPackages (hps:
            with hps; [
              aeson
              base64-bytestring
              bytestring
              containers
              directory
              foldl
              http-client
              http-client-tls
              optparse-applicative
              servant
              servant-client
              shelly
              shh
              text
              turtle
              uuid
            ]);
        };
        devshells = {
          formatting = {
            commands = [
              {
                name = "fmt";
                help = "format all files";
                command = "pre-commit run --all-files";
              }
            ];
            devshell = {
              startup = {
                pre-commit.text = config.pre-commit.installationScript;
              };
            };
          };
          default = {
            packages = [
              /*
              NOTE
              - add tools you need additionally, here
              - with haskell tools, please follow the convention
                to first reexport as a flake output and then accessing
                via `config.packages`
              */
              config.packages.ghc
              config.packages.ormolu
              config.packages.haskell-language-server
              config.packages.hlint
            ];
            commands = [
              {
                name = "run";
                help = "run a haskell script";
                command =
                  /*
                  bash
                  */
                  ''nix run .# -- "$@"'';
              }
            ];
          };
        };
      };
      flake = {
        templates = rec {
          default = quick-dev;
          quick-dev = {
            path = toString inputs.self;
            description = "initialize a devShell with some necessary packages";
            welcomeText = ''
              # GHC flakr

              Welcome. This is a `nix` flake built to get you up and running with **Haskell** scripts in no time.

              ## DevShell

              Run `direnv allow` or `nix develop`

              ## Running

              - `run` (runs `main.hs`)
              - `run file.hs` (runs `file.hs`)
            '';
          };
        };
      };
    };
}
