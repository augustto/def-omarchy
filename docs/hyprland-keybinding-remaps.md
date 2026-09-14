# Hyprland Keybinding Remaps: Screenshot + Google Maps

Step-by-step guide to reproduce two personal keybinding overrides on a fresh
Omarchy install:

1. Move the screenshot shortcut onto `SUPER+SHIFT+S` (Omarchy's default slot
   for the Google Maps webapp).
2. Relocate the Google Maps webapp to `SUPER+SHIFT+M` (Omarchy's default slot
   for Music/Spotify).

The final result lives in `config/hypr/bindings.lua` in this repo. This doc
explains *why* it's written that way, since the two pitfalls below aren't
obvious from the code alone.

## Background: why `hl.unbind` is required first

Omarchy loads its default keybindings, then loads `~/.config/hypr/bindings.lua`
on top. If you add a new `o.bind()` for a key combo that's already bound by a
default, Hyprland does **not** replace the old bind — it registers both, and
**both fire** on that key press. So rebinding an existing key always needs an
explicit `hl.unbind()` first, or the old default action keeps running
alongside (or instead of) the new one.

Check what a key combo currently does before touching it:

```bash
omarchy menu keybindings --print
```

## 1. Move screenshot to `SUPER+SHIFT+S`

`SUPER+SHIFT+S` is Omarchy's default shortcut for opening the Google Maps
webapp (see `$OMARCHY_PATH/default/hypr/bindings/applications.lua`). Unbind
that default before adding the screenshot binding:

```lua
-- Unbind default SUPER+SHIFT+S (was: Google Maps) to avoid conflict with screenshot
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
```

## 2. Relocate Google Maps to `SUPER+SHIFT+M`

`SUPER+SHIFT+M` is Omarchy's default shortcut for Music/Spotify. Unbind it,
then bind Google Maps there instead.

### Pitfall: don't reuse the plain webapp table shorthand

The straightforward way to bind a webapp with focus-or-launch behavior is:

```lua
o.bind("SUPER + SHIFT + M", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
```

**Avoid this form.** With `focus = true`, Omarchy's underlying
`omarchy-launch-or-focus-webapp` helper searches all open windows for one
whose **title or window class contains the bind's description text**
(case-insensitive, word-boundary match) — in this case, the literal string
`"Google Maps"`. If *any other open window* happens to have that text in its
title (for example, a terminal whose title bar shows a summary of what you're
currently working on), the shortcut focuses that unrelated window instead of
opening or focusing the actual Maps webapp. This is a real, reproducible
failure mode, not a hypothetical edge case.

### Fix: match by the webapp's stable window class instead

Bypass the table shorthand and build the launch/focus command yourself with
an explicit, unambiguous window-class pattern:

```lua
-- Unbind default SUPER+SHIFT+M (was: Music/Spotify) to reassign to Google Maps
-- Match by window class (not the generic "Google Maps" title text), since a
-- title-based match can accidentally hit any other window whose title happens
-- to contain that phrase (e.g. a terminal title).
hl.unbind("SUPER + SHIFT + M")
o.bind("SUPER + SHIFT + M", "Google Maps", o.launch_webapp_sole("chrome-maps.google.com__-Default", "https://maps.google.com/"))
```

`o.launch_webapp_sole(pattern, url)` builds the same
`omarchy-launch-or-focus-webapp <pattern> <url>` command, but here `pattern`
is the webapp's actual Chrome window class instead of the human-readable
description — so it can only ever match the real Maps window.

To confirm the exact class value on your own machine (Chrome derives it
deterministically from the app URL, but it's worth verifying):

```bash
# Open the webapp once manually, then inspect it:
google-chrome --app="https://maps.google.com/" &
sleep 3
hyprctl clients -j | jq -r '.[] | select(.class | test("maps"; "i")) | .class'
# → chrome-maps.google.com__-Default
```

## 3. Apply and validate

```bash
hyprctl reload
hyprctl configerrors        # must be empty
omarchy menu keybindings --print | grep -E "SHIFT \+ S|SHIFT \+ M"
```

Also confirm there's exactly one bind registered per key combo (no leftover
duplicate from a missing `hl.unbind`):

```bash
hyprctl binds | awk '/^bind/{b=$0} /modmask:/{m=$0} /key: S$/{if(b&&m) print b, m}'
```

## Notes

- These two remaps depend on each other only by convention (reusing the slots
  Omarchy assigned to Maps and Music) — they can be applied independently.
- The window-class-matching pitfall in step 2 applies to *any* `focus = true`
  webapp binding you add yourself, not just Google Maps: prefer matching on
  the app's window class over its display name whenever there's a realistic
  chance another window's title could contain the same text.
