{
  description = "ghc flakr - devenv";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    pre-commit.url = "github:cachix/pre-commit-hooks.nix";
    flake-compat.url = "github:edolstra/flake-compat";
    gitignore.url = "github:hercules-ci/gitignore.nix";

    # non-flake inputs
    amqp.flake = false;
    amqp.url = "github:hreinhardt/amqp";
    cql-io.flake = false;
    cql-io.url = "git+https://gitlab.com/wireapp/forks/cql-io.git?ref=control-conn";
    ghc-source-gen.flake = false;
    ghc-source-gen.url = "github:circuithub/ghc-source-gen/ghc-9.4";
    hsaml2.flake = false;
    hsaml2.url = "github:wireapp/hsaml2/update-crypto";
    http-client.flake = false;
    http-client.url = "github:wireapp/http-client/wip";
    saml2-web-sso.flake = false;
    saml2-web-sso.url = "github:wireapp/saml2-web-sso";
    tinylog.flake = false;
    tinylog.url = "git+https://gitlab.com/wireapp/forks/tinylog.git?ref=wire-fork";
    transitive-anns.flake = false;
    transitive-anns.url = "github:wireapp/transitive-anns";
    wai-predicates.flake = false;
    wai-predicates.url = "git+https://gitlab.com/wireapp/forks/wai-predicates.git?ref=develop";
    wai-routing.flake = false;
    wai-routing.url = "git+https://gitlab.com/twittner/wai-routing.git?rev=7e996a93fec5901767f845a50316b3c18e51a61d";
    wire-server.flake = false;
    wire-server.url = "git+https://github.com/wireapp/wire-server.git?submodules=1";
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
          inherit (inputs.gitignore.lib) gitignoreSource;

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
              overrides = hself: hsuper:
                lib.mapAttrs (_: dontHaddock) {
                  # libraries maintained in wire-server
                  cassandra-util = hself.callPackage "${inputs.wire-server}/libs/cassandra-util" {inherit gitignoreSource;};
                  deriving-swagger2 = hself.callPackage "${inputs.wire-server}/libs/deriving-swagger2" {inherit gitignoreSource;};
                  extended = hself.callPackage "${inputs.wire-server}/libs/extended" {inherit gitignoreSource;};
                  hscim = hself.callPackage "${inputs.wire-server}/libs/hscim" {inherit gitignoreSource;};
                  imports = hself.callPackage "${inputs.wire-server}/libs/imports" {inherit gitignoreSource;};
                  metrics-core = hself.callPackage "${inputs.wire-server}/libs/metrics-core" {inherit gitignoreSource;};
                  metrics-wai = hself.callPackage "${inputs.wire-server}/libs/metrics-wai" {inherit gitignoreSource;};
                  schema-profunctor = hself.callPackage "${inputs.wire-server}/libs/schema-profunctor" {inherit gitignoreSource;};
                  sodium-crypto-sign = hself.callPackage "${inputs.wire-server}/libs/sodium-crypto-sign" {inherit gitignoreSource;};
                  types-common = hself.callPackage "${inputs.wire-server}/libs/types-common" {inherit gitignoreSource;};
                  wai-utilities = hself.callPackage "${inputs.wire-server}/libs/wai-utilities" {inherit gitignoreSource;};
                  wire-api =
                    addBuildDepends [config.packages.mls-test-cli]
                    (hself.callPackage "${inputs.wire-server}/libs/wire-api" {inherit gitignoreSource;});
                  wire-message-proto-lens =
                    addBuildTools [pkgs.protobuf]
                    (hself.callPackage "${inputs.wire-server}/libs/wire-message-proto-lens" {inherit gitignoreSource;});
                  zauth = hself.callPackage "${inputs.wire-server}/libs/zauth" {inherit gitignoreSource;};

                  # libraries maintained in external repositories
                  amqp = dontCheck (hself.callCabal2nix "amqp" "${inputs.amqp}" {});
                  cql-io = (hself.callCabal2nix "cql-io" "${inputs.cql-io}" {}).overrideAttrs {doCheck = false;};
                  ghc-source-gen = hself.callCabal2nix "ghc-source-gen" "${inputs.ghc-source-gen}" {};
                  hsaml2 = (hself.callCabal2nix "hsaml2" "${inputs.hsaml2}" {}).overrideAttrs {doCheck = false;};
                  http-client = hself.callCabal2nix "http-client" "${inputs.http-client}/http-client" {};
                  http-client-openssl = hself.callCabal2nix "http-client" "${inputs.http-client}/http-client-openssl" {};
                  http-client-tls = hself.callCabal2nix "http-client" "${inputs.http-client}/http-client-tls" {};
                  http-conduit = hself.callCabal2nix "http-client" "${inputs.http-client}/http-conduit" {};
                  saml2-web-sso = dontCheck (hself.callCabal2nix "saml2-web-sso" "${inputs.saml2-web-sso}" {});
                  tinylog = hself.callCabal2nix "tinylog" "${inputs.tinylog}" {};
                  transitive-anns = (hself.callCabal2nix "transitive-anns" "${inputs.transitive-anns}" {}).overrideAttrs {doCheck = false;};
                  wai-predicates = hself.callCabal2nix "wai-predicates" "${inputs.wai-predicates}" {};
                  wai-routing = doJailbreak (hself.callCabal2nix "wait-routing" "${inputs.wai-routing}" {});

                  # libraries from hackage
                  HsOpenSSL = hself.callHackage "HsOpenSSL" "0.11.7.6" {};
                  wai-route = hself.callHackage "wai-route" "0.4.0" {};
                  warp = dontCheck (hself.callHackage "warp" "3.3.29" {});
                  warp-tls = hself.callHackage "warp-tls" "3.4.3" {};
                  tls = hself.callHackage "tls" "1.9.0" {};

                  # package overrides
                  binary-parsers = markUnbroken (doJailbreak hsuper.binary-parsers);
                  bytestring-arbitrary = markUnbroken (doJailbreak hsuper.bytestring-arbitrary);
                  bytestring-conversion = markUnbroken hsuper.bytestring-conversion;
                  lens-datetime = markUnbroken (doJailbreak hsuper.lens-datetime);
                  openapi3 = markUnbroken (dontCheck hsuper.openapi3);
                  proto-lens-protoc = doJailbreak hsuper.proto-lens-protoc;
                  proto-lens-setup = doJailbreak hsuper.proto-lens-setup;
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
              turtle
              shelly
              shh
              foldl
              aeson
              http-conduit
              wire-api
            ]);
          mls-test-cli = pkgs.callPackage "${inputs.wire-server}/nix/pkgs/mls-test-cli" {};
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
