# RGFW Zig Bindings

**Thanks to https://codeberg.org/Zettexe/rgfw-zig for the base**

Minimal cross-platform window management library using RGFW header-only C
library.

## Known Issues

### Wayland Window Sizing

**Issue**: Wayland backend ignores window size parameters. All windows are
created taking up the full screen but also not adhearing to tiling manager? I
have to fullscreen and unfullscreen it to get it to work. No resize events are
triggered, and calling `resize()` after creation has no effect.

This might be an upstream RGFW bug in the Wayland implementation where window
size hints are not properly communicated to the compositor during window
creation. Unsure, haven't tested aginst the C source at all.

**Workaround**: Use XWayland (X11 compatibility layer) which works perfectly:

```bash
WAYLAND_DISPLAY="" zig build example
```

The library compiles with both backends - RGFW automatically uses X11 when
`WAYLAND_DISPLAY` is unset.

## Build

```bash
zig build              # Build library and examples
zig build test         # Run tests (got none lmao)
zig build example      # Build and run basic example
```

## Usage

```zig
const std = @import("std");
const rgfw = @import("rgfw");

pub fn main() !void {
    // Create window with flags
    var window = try rgfw.Window.init(
        "My Window",
        .{ .x = 100, .y = 100, .width = 800, .height = 600 },
        .{ .center = true },
    );
    defer window.deinit();

    while (!window.should_close) {
        while (window.getEvent()) |event| {
            std.debug.print("Event: {s}\n", .{@tagName(event)});
            // Handle events
        }
    }
}
```

## Dependencies

- **RGFW** (header-only): https://github.com/ColleagueRiley/RGFW
- **X11 libraries**: libX11, libXi, libXext, libXinerama, libXrandr, libXcursor,
  libXrender, libXfixes, libGL
- **Wayland libraries** (for experimental Wayland support): wayland-client,
  wayland-protocols, libdecor, libxkbcommon
- **wayland-scanner**: For generating Wayland protocol bindings

Environment variables set by Nix flake:

- `LD_LIBRARY_PATH`: Runtime library paths
- `C_INCLUDE_PATH`: Header include paths
- `WAYLAND_PROTOCOLS_DIR`: Wayland protocol XML files
- `WAYLAND_SCANNER`: Path to wayland-scanner binary
