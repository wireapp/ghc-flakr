# GHC flakr - Run Haskell scripts. NOW.

## Using for running

*requirements:*
- a `nix` installation with `nix-commmand` and `flakes` experimental features enabled
- a `Haskell` file with a `main :: IO` function in it

*usage:*
- if your file is called `main.hs`: `nix run github:wireapp/ghc-flakr`
- if your file is called `anything-else.hs`: `nix run github:wireapp/ghc-flakr# anything-else.hs`

## Using with shebangs

*requirements*:
- a `nix` installation with `nix-commmand` and `flakes` experimental features enabled
- your `/usr/bin/env` understands the `-S, --split-string=S` parameter (should be the case if your Linux was updated in the recent 5 years)

*usage:*
- create a file, `./main.hs`, as such:
  ```haskell
  #!/usr/bin/env -S nix run github:wireapp/ghc-flakr

  main = do
    putStrLn "Hello flakr user"
  ```
- `chmod +x ./main.hs`
- `./main.hs` should print `Hello flakr user`

## Using it to create a devShell

> **NOTE**
> This mainly useful if you want to include different deps

*requirements*
- a `nix` installation with `nix-commmand` and `flakes` experimental features enabled

*nice-to-haves:*
- a `direnv` installation with `nix-direnv` support

*usage:*
- run `nix flake init -t github:wireapp/ghc-flakr`
- edit `flake.nix` to your liking, for more information, refer to
  - [the flake parts docs](https://flake.parts/)
  - [the devshell docs](https://flake.parts/options/devshell) ([upstream repository](https://github.com/numtide/devshell))
  - [the pre-commit-hooks.nix docs](https://flake.parts/options/pre-commit-hooks-nix) ([upstream repository](https://github.com/cachix/pre-commit-hooks.nix))
- run `direnv allow`, `devshell` will tell you about available commands (use `menu` to be reminded)

## Installing globally

*requirements*
- a `nix` installation with `nix-commmand` and `flakes` experimental features enabled

*usage:*
- to install: `nix profile install github:wireapp/ghc-flakr`
- to remove: `nix profile remove ghc-flakr`
- to use: this flake provides a single executable, `hs-run` that works as with `nix run` (see above)

## Contributing

This is mainly supposed to be a way to allow the wire backend team to easily write scripts in Haskell, so there's two possibilies:
- if you're a wire backend engineer and want to add dependencies to the shell that you think will be useful, ***please do so***
- if you're from outside of wire, please only open a PR if the change is unspecific to the used tooling, for everything else, please
  maintain your own fork.
