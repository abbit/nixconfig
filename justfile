[private]
default:
    @just --list

# update all flake inputs
update:
    nix flake update

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
