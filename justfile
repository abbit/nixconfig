[private]
default:
    @just --choose

# update all flake inputs
update-flake:
    nix flake update

# update brew and packages
[macos]
update-brew:
    brew update
    brew upgrade

[linux]
update-brew:
    echo "Skipping brew update on linux"

# update neovim plugins
update-nvim:
    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+TSUpdate" +qa

update-all: update-flake update-brew update-nvim

# remove all generations older than 7 days
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# rebuild the system with the given name
[linux]
rebuild name:
    nixos-rebuild switch --flake .#{{name}}

# rebuild the system
[macos]
rebuild:
    darwin-rebuild switch --flake .#macos

rebuild-home name:
    home-manager switch --flake .#{{name}}
