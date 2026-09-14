#!/usr/bin/env bash
# Restores this config onto a fresh Omarchy install.
# Run from anywhere: ~/def-omarchy/install.sh
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
dest="$HOME/.config"

TOTAL_STEPS=7
CURRENT_STEP=0
applied=0
skipped=0
declined=0

build_bar() {
  local pct=$1 width=20
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar="" i
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done
  printf '%s' "$bar"
}

progress() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  local pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
  printf '[%s] %3d%% (%d/%d) %s\n' "$(build_bar "$pct")" "$pct" "$CURRENT_STEP" "$TOTAL_STEPS" "$1"
}

log() {
  echo "    -> $1"
}

confirm() {
  local prompt="$1"
  if [[ ! -t 0 ]]; then
    log "Non-interactive shell, assuming no for: $prompt"
    return 1
  fi
  if command -v gum &>/dev/null; then
    gum confirm "$prompt"
  else
    local reply
    read -rp "$prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
  fi
}

# Prints a short "name (changed)/(new), ..." summary of files under src_dir
# that differ from (or are missing in) dest_dir. Returns 1 if none do.
diff_dir_summary() {
  local src_dir="$1" dest_dir="$2"
  local -a entries=()
  local f rel

  while IFS= read -r -d '' f; do
    rel="${f#"$src_dir"/}"
    if [[ ! -e "$dest_dir/$rel" ]]; then
      entries+=("$rel (new)")
    elif ! cmp -s "$f" "$dest_dir/$rel"; then
      entries+=("$rel (changed)")
    fi
  done < <(find "$src_dir" -type f -print0)

  [[ ${#entries[@]} -eq 0 ]] && return 1

  local shown=("${entries[@]:0:5}") out="" i
  for i in "${!shown[@]}"; do
    [[ $i -gt 0 ]] && out+=", "
    out+="${shown[$i]}"
  done
  if [[ ${#entries[@]} -gt 5 ]]; then
    out+=", +$(( ${#entries[@]} - 5 )) more"
  fi
  echo "$out"
}

apply_config_dir() {
  local name="$1" summary

  progress "$name config"

  if [[ ! -d "$dest/$name" ]]; then
    log "~/.config/$name not found"
    if confirm "Install ~/.config/$name?"; then
      mkdir -p "$dest/$name"
      cp -rv "$src/$name/." "$dest/$name/"
      log "Applied"
      applied=$((applied + 1))
    else
      log "Skipped"
      declined=$((declined + 1))
    fi
    return
  fi

  if summary=$(diff_dir_summary "$src/$name" "$dest/$name"); then
    log "~/.config/$name differs: $summary"
    if confirm "Apply changes to ~/.config/$name?"; then
      cp -rv "$src/$name/." "$dest/$name/"
      log "Applied"
      applied=$((applied + 1))
    else
      log "Skipped"
      declined=$((declined + 1))
    fi
  else
    log "Already applied"
    skipped=$((skipped + 1))
  fi
}

apply_single_file() {
  local src_file="$1" dest_file="$2" label="$3" post_hook="${4:-}"

  progress "$label"

  if [[ -f "$dest_file" ]] && cmp -s "$src_file" "$dest_file"; then
    log "Already applied"
    skipped=$((skipped + 1))
    return
  fi

  if [[ -f "$dest_file" ]]; then
    log "$dest_file differs from repo"
  else
    log "$dest_file not found"
  fi

  if confirm "Write $dest_file?"; then
    cp -v "$src_file" "$dest_file"
    log "Applied"
    applied=$((applied + 1))
    [[ -n "$post_hook" ]] && "$post_hook"
  else
    log "Skipped"
    declined=$((declined + 1))
  fi
}

apply_config_dir "hypr"
apply_config_dir "foot"
apply_single_file "$src/xcompose/.XCompose" "$HOME/.XCompose" "XCompose" omarchy-restart-xcompose

progress "zsh packages"
zsh_pkgs=(zsh zsh-autosuggestions zsh-syntax-highlighting)
missing_pkgs=()
for pkg in "${zsh_pkgs[@]}"; do
  pacman -Qi "$pkg" &>/dev/null || missing_pkgs+=("$pkg")
done
if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
  log "Already applied"
  skipped=$((skipped + 1))
else
  log "Missing: ${missing_pkgs[*]}"
  if confirm "Install missing zsh packages (needs sudo)?"; then
    omarchy pkg add "${missing_pkgs[@]}"
    log "Applied"
    applied=$((applied + 1))
  else
    log "Skipped"
    declined=$((declined + 1))
  fi
fi

progress "Powerlevel10k clone"
p10k_dir="$HOME/.local/share/powerlevel10k"
if [[ -d "$p10k_dir" ]]; then
  log "Already applied"
  skipped=$((skipped + 1))
else
  log "$p10k_dir not found"
  if confirm "Clone Powerlevel10k to $p10k_dir?"; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    log "Applied"
    applied=$((applied + 1))
  else
    log "Skipped"
    declined=$((declined + 1))
  fi
fi

apply_single_file "$src/zsh/.zshrc" "$HOME/.zshrc" ".zshrc"

progress "Default shell"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" == "/usr/bin/zsh" ]]; then
  log "Already applied"
  skipped=$((skipped + 1))
else
  log "Current shell is $current_shell"
  if confirm "Set zsh as your login shell (password required)?"; then
    chsh -s /usr/bin/zsh
    log "Applied"
    applied=$((applied + 1))
  else
    log "Skipped"
    declined=$((declined + 1))
  fi
fi

echo
echo "Summary: $applied applied, $skipped already up to date, $declined skipped."
echo "Reload Hyprland with: hyprctl reload"
