set -U fish_greeting # disable fish greeting
set -U fish_key_bindings fish_vi_key_bindings # use vi-mode

# Ghostty supports auto-injection but Nix-darwin hard overwrites XDG_DATA_DIRS
# which make it so that we can't use the auto-injection. We have to source manually.
if set -q GHOSTTY_RESOURCES_DIR
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
end

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-fish
# For some reason if the Fish completions are added at the end of `fish_complete_path` they don't
# seem to work, but they do work if added at the start.
if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end