<p align="center">
  <img src="https://github.com/wireapp/ghc-flakr/actions/workflows/test-flake.yml/badge.svg"/>
  <img src="https://img.shields.io/badge/built%20with-nix-5277C3?logo=nixos"/>
</p>

<h1 align="center"> GHC flakr - Run Haskell scripts. NOW. </h1>

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
- ```bash
  chmod +x ./main.hs
  ```
- `./main.hs` should print `Hello flakr user`

## Using it to create a devShell

> **NOTE**
> This mainly useful if you want to include different deps

*requirements*
- a `nix` installation with `nix-commmand` and `flakes` experimental features enabled

*nice-to-haves:*
- a `direnv` installation with `nix-direnv` support

*usage:*
- run
  ```bash
  nix flake init -t github:wireapp/ghc-flakr`
  ```
- edit `flake.nix` to your liking, for more information, refer to
  - [the flake parts docs](https://flake.parts/)
  - [the devshell docs](https://flake.parts/options/devshell) ([upstream repository](https://github.com/numtide/devshell))
  - [the pre-commit-hooks.nix docs](https://flake.parts/options/pre-commit-hooks-nix) ([upstream repository](https://github.com/cachix/pre-commit-hooks.nix))
- run
  ```bash
  direnv allow
  ```
  or
  ```bash
  nix develop
  ```
  `devshell` will tell you about available commands (use `menu` to be reminded)

## Installing globally

*requirements*
- a `nix` installation with `nix-commmand` and `flakes` experimental features enabled

*usage:*
- to install:
  ```bash
  nix profile install github:wireapp/ghc-flakr
  ```
- to remove:
  ```bash
  nix profile remove ghc-flakr
  ```
- to use: this flake provides a single executable, `hs-run` that works as with `nix run` (see above)

## Some resources on using Haskell as a scripting language

### (Incomplete list of, maybe) Useful packages

- [turtle@hackage](https://flora.pm/packages/@hackage/turtle)
- [shelly@hackage](https://flora.pm/packages/@hackage/shelly)
- [procex@hackage](https://flora.pm/packages/@hackage/procex)
- [shh@hackage](https://flora.pm/packages/@hackage/shh)
- [foldl@hackage](https://flora.pm/packages/@hackage/foldl)

### Relevant blog-posts

- [Las about using GHCi as his shell](https://las.rs/blog/haskell-as-shell.html)
- [Gabriella about using Haskell for shell scripting](https://www.haskellforall.com/2015/01/use-haskell-for-shell-scripting.html)

## Caching

- there's a cachix available at https://ghc-flakr.cachix.org
- to use it, run
  ```bash
  cachix use ghc-flakr
  ```
  or add the appropriate settings in your `trusted-subsituters`, the public key is
  ```
  ghc-flakr.cachix.org-1:y2jnE5kv6OksYl+ZPis1pmWHCSa8el+FVCjcQI5LKx0=
  ```

## Contributing

This is mainly supposed to be a way to allow the wire backend team to easily write scripts in Haskell, so there's two possibilies:
- if you're a wire backend engineer and want to add dependencies to the shell that you think will be useful, ***please do so***
- if you're from outside of wire, please only open a PR if the change is unspecific to the used tooling, for everything else, please
  maintain your own fork.
