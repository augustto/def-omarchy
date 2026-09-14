# Zsh + Powerlevel10k Setup on Omarchy

Step-by-step guide to replicate this shell setup (zsh, autosuggestions,
syntax-highlighting, Powerlevel10k prompt, default-shell switch, and
`SUPER+RETURN` terminal fix) on a fresh Omarchy install.

## 1. Install zsh and plugins

These packages are in the official Arch `extra` repo, so no AUR access is
needed.

```bash
omarchy pkg add zsh zsh-autosuggestions zsh-syntax-highlighting
```

This requires `sudo` and a password prompt, so run it in an interactive
terminal (not from a non-interactive script/agent shell).

## 2. Create `~/.zshrc`

```bash
cat > ~/.zshrc << 'EOF'
# ~/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- Completion ---
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# --- Key bindings ---
bindkey -e   # emacs-style keybindings (arrow keys, ctrl+a/e, etc.)

# --- Prompt (Powerlevel10k) ---
source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Plugins ---
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Aliases ---
alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF
```

Plugin paths (`/usr/share/zsh/plugins/...`) are where Arch installs them via
pacman — confirm with:

```bash
find /usr/share/zsh/plugins -maxdepth 1
```

## 3. Install Powerlevel10k

Not in the official repos, so it's cloned directly (no root needed):

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.local/share/powerlevel10k
```

The `.zshrc` above already sources it from that path.

## 4. Nerd Font (for prompt icons)

Omarchy ships JetBrainsMono Nerd Font by default. Confirm it's installed and
set as your terminal's font:

```bash
omarchy font list       # check available fonts
omarchy font current    # check active font
fc-list | grep -i nerd  # confirm the font files are present
```

If missing, install a Nerd Font package (e.g. `otf-jetbrainsmono-nerd`) via
`omarchy pkg add`, then set it with `omarchy font set "JetBrainsMono Nerd Font"`.
Make sure your terminal emulator (foot/alacritty/kitty/ghostty) is actually
using that font — Omarchy themes usually wire this up automatically.

## 5. Set zsh as the default login shell

```bash
chsh -s /usr/bin/zsh
```

Requires your account password (interactive prompt). Takes effect on new
login sessions.

## 6. Run the Powerlevel10k configuration wizard

```bash
zsh            # or open a new terminal / log out and back in
p10k configure
```

Interactive wizard for prompt style (classic/lean/rainbow, icons, etc.). It
writes `~/.p10k.zsh`, which is already sourced by `~/.zshrc`.

## 7. Make `SUPER+RETURN` open zsh immediately (foot terminal)

Omarchy's default terminal launched by `SUPER+RETURN` picks its shell from
the `$SHELL` env var, which is set at **login time** — so it can still point
to bash until you log out/in again after `chsh`. To force it immediately,
pin the shell explicitly in the terminal's own config.

Check which terminal is currently default:

```bash
omarchy default terminal   # e.g. "foot"
```

For **foot**, edit `~/.config/foot/foot.ini` and add `shell=` under `[main]`:

```ini
[main]
include=~/.local/state/omarchy/current/theme/foot.ini
shell=/usr/bin/zsh
term=xterm-256color
```

Foot hot-reloads config on save — no restart needed. (Equivalent options
exist for alacritty/kitty/ghostty if you use a different default terminal;
each has its own `shell`/`command` config key.)

This override becomes redundant (but harmless) after your next full
login/reboot, once the session's `$SHELL` itself updates to zsh.

## Notes

- Skip step 7 entirely if you're fine waiting for a logout/reboot for
  `SUPER+RETURN` to pick up the new default shell.
- Steps 1 and 5 need an interactive terminal for password entry — they can't
  run from a non-interactive/agent shell.
