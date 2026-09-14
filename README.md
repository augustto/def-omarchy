# def-omarchy

Personal Omarchy (Hyprland + foot) config, for a quick restore after reinstalling.

## What's here

- `config/hypr/` — monitors (Alienware m16 R1 + ASUS PA278CGRV @ 144Hz), keyboard layout (US + US Intl with dead keys, toggle `Ctrl+Shift+K`), keybindings (screenshot moved to `SUPER+SHIFT+S`, Google Maps moved to `SUPER+SHIFT+M`)
- `config/foot/` — terminal font size, and `shell=/usr/bin/zsh` so `SUPER+RETURN` opens zsh right away
- `config/zsh/.zshrc` — zsh setup: history, completion, Powerlevel10k prompt, autosuggestions, syntax-highlighting, and `eza`-based `ls`/`lt` aliases with icons (matching Omarchy's bash defaults)
- `config/xcompose/.XCompose` — Omarchy's default compose (emoji, identification) plus a Windows Intl-style cedilla override (`dead_acute` + `c` → `ç`/`Ç`) for the US Intl keyboard layout
- `docs/zsh-powerlevel10k-setup.md` — the manual, step-by-step version of what `install.sh` automates for zsh (useful as a reference or if you want to redo a step by hand)
- `docs/hyprland-keybinding-remaps.md` — step-by-step guide to reproduce the screenshot/Google Maps keybinding remap, including the `hl.unbind`-before-rebind rule and a window-class-matching pitfall to avoid

## After reinstalling Omarchy

```
git clone https://github.com/augustto/def-omarchy.git ~/def-omarchy
~/def-omarchy/install.sh
hyprctl reload
```

`install.sh` walks through 7 steps (hypr, foot, XCompose, zsh packages,
Powerlevel10k, `.zshrc`, default shell) with a progress bar, and for each one
**checks first whether it's already applied**. A step that's already in
place is skipped silently; one that isn't shows what would change and asks
for a `y`/`N` confirmation (via `gum confirm`, or a plain prompt if `gum`
isn't installed) before touching anything — nothing is overwritten without
you saying yes. `hypr` and `foot` are each checked and confirmed as a whole
directory, not file by file. Package install and `chsh` need your sudo/
account password, so run the script from an interactive terminal. A summary
line at the end reports how many steps were applied, already up to date, or
skipped. Open a new terminal afterwards and run `p10k configure` if you want
to customize the prompt — it's optional, the `.zshrc` already has sane
defaults without it.

## Updating the backup

Whenever you change `~/.config/hypr`, `~/.config/foot`, `~/.zshrc`, or `~/.XCompose` and want to save it here:

```
cp -r ~/.config/hypr/* ~/def-omarchy/config/hypr/
cp ~/.config/foot/foot.ini ~/def-omarchy/config/foot/foot.ini
cp ~/.zshrc ~/def-omarchy/config/zsh/.zshrc
cp ~/.XCompose ~/def-omarchy/config/xcompose/.XCompose
cd ~/def-omarchy && git status && git diff  # review before staging — this repo is public
git add -A && git commit -m "describe the change" && git push
```

`.gitignore` blocks common secret-bearing files (keys, `.env`, history files,
credential/token file names) from being added by accident, but it's not a
substitute for reading the diff before every commit, since this repo is
public.
