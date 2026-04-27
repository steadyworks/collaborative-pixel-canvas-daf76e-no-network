# Collaborative Pixel Canvas

Build a real-time shared pixel art canvas — think r/place — where any visitor can paint pixels on a 64×64 grid. No accounts, no login. Everyone who opens the page sees the same living artwork and can contribute to it instantly.

## Stack

- **Frontend**: Port **3000**
- **Backend**: Any Python framework / server (port **3001**)
- **Persistence**: Sqlite
- **Real-time**: WebSockets

## User Identity

There is no authentication. When the page first loads, the frontend mints a short random display name for the visitor (e.g. `PixelFox-4829`) and writes it to `localStorage` so it survives page refreshes in the same browser. The name is shown on screen and attached to every pixel placement as the placer's identity.

## The Canvas

A **64-column × 64-row** grid of clickable cells. Clicking a cell paints it in the currently selected palette color. Cells that have never been painted are empty/white.

Every placement — position, color, placer name, and timestamp — is persisted in PostgreSQL. On page load the frontend fetches the full canvas state and renders it. After a backend restart, reloading the page must restore the identical picture.

All connected clients receive pixel placements in real-time without reloading the page.

## Color Palette

A fixed palette of exactly **16 colors** is always visible. The colors are:

`#FFFFFF` `#E4E4E4` `#888888` `#222222`
`#FFA7D1` `#E50000` `#E59500` `#A06A42`
`#E5D900` `#94E044` `#02BE01` `#00D3DD`
`#0083C7` `#0000EA` `#CF6EE4` `#820080`

One color is always "active." Clicking a swatch activates it; the active swatch must be visually distinguished (e.g. an outline ring). There is no custom color input — only these 16.

## Cooldown

After placing a pixel, the user enters a **5-second cooldown**. During cooldown:

- Additional placement attempts are silently ignored — no error toast, no visual glitch.
- A countdown element shows the remaining whole seconds (e.g. `5 → 4 → 3 → 2 → 1`).
- Once the timer reaches zero it disappears (or shows `0`) and the canvas becomes interactive again.

## Pixel Tooltips

Hovering over a painted cell shows a small tooltip containing:

- The placer's display name
- When the pixel was placed (a human-readable string, e.g. `"5 minutes ago"` or a formatted local datetime)

Hovering over an empty cell shows nothing.

## Timelapse Replay

A **Timelapse** button triggers replay mode:

- The canvas resets to blank and re-applies every historical pixel placement in chronological order, one at a time, at a fast but perceptible speed.
- The canvas is non-interactive during replay.
- A visible **Stop** control lets the user exit replay at any point.
- Exiting replay (whether it finishes naturally or is stopped) restores the live canvas state.

## Page Structure

The app is a **single page at `/`**. There are no other frontend routes.

## `data-testid` Reference

Every interactive and observable element must carry the exact `data-testid` attribute listed below. The test harness depends on these strings.

### Canvas

- `canvas-grid` — outer container of the 64×64 grid
- `pixel-{x}-{y}` — each cell, where `x` is the 0-based column and `y` is the 0-based row. Example: column 5, row 5 → `pixel-5-5`

### Color Palette

- `color-palette` — the palette container
- `color-swatch-{hex}` — each swatch; `{hex}` is the 6-character hex code in lowercase with no `#`. Example: `color-swatch-e50000`
- `selected-color-display` — an element reflecting the active color; must have a `data-color` attribute set to the full uppercased hex string including `#`, e.g. `data-color="#E50000"`

### Cooldown

- `cooldown-timer` — the countdown element. Text content must be the remaining whole seconds while active (e.g. `"5"`, `"4"`, …). Hidden or empty when no cooldown is in effect.

### Tooltip

- `pixel-tooltip` — the tooltip container (only present/visible while hovering a painted cell)
- `tooltip-user` — the placer's display name inside the tooltip
- `tooltip-timestamp` — the placement time string inside the tooltip

### Timelapse

- `timelapse-btn` — starts replay mode (always visible on the main page)
- `timelapse-stop` — exits replay mode (visible only while replay is active)

### Identity

- `user-identifier` — element showing the current user's display name
