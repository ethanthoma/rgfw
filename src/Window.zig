const std = @import("std");
const Point = @import("root.zig").Point;
const Area = @import("root.zig").Area;
const Event = @import("event.zig").Event;
const CEvent = @import("event.zig").CEvent;
const Monitor = @import("monitor.zig").Monitor;

const Window = @This();

const RGFW_Window = extern struct {};

window: *RGFW_Window,
should_close: bool,

pub const Flags = packed struct(u32) {
    /// Window without a border
    no_border: bool = false,
    /// Window cannot be resized by the user
    no_resize: bool = false,
    /// Window supports drag and drop
    allow_drag_and_drop: bool = false,
    /// Hide the mouse cursor (can toggle later with RGFW_window_showMouse)
    hide_mouse: bool = false,
    /// Window is fullscreen by default
    fullscreen: bool = false,
    /// Window is transparent (works properly on X11 and macOS)
    transparent: bool = false,
    /// Center the window on the screen
    center: bool = false,
    _7: u1 = 0,
    /// Scale the window to the monitor
    scale_to_monitor: bool = false,
    /// Window is hidden
    hide: bool = false,
    /// Window is maximized
    maximize: bool = false,
    /// Center the cursor in the window
    center_cursor: bool = false,
    /// Create a floating window
    floating: bool = false,
    /// Focus the window when it's shown
    focus_on_show: bool = false,
    /// Window is minimized
    minimize: bool = false,
    /// Window has focus
    focus: bool = false,
    _16: u1 = 0,
    /// Create an OpenGL context
    opengl: bool = false,
    /// Create an EGL context
    egl: bool = false,
    _: u13 = 0,
};

extern fn RGFW_createWindow(name: [*c]const u8, x: i32, y: i32, w: i32, h: i32, flags: u32) ?*RGFW_Window;
pub fn init(name: [:0]const u8, location: Point, size: Area, flags: Flags) !Window {
    const rgfw_window = RGFW_createWindow(
        name.ptr,
        location.x,
        location.y,
        @intCast(size.width),
        @intCast(size.height),
        @bitCast(flags),
    ) orelse return error.WindowCreationFailed;
    return .{ .window = rgfw_window, .should_close = false };
}

extern fn RGFW_window_close(win: *RGFW_Window) void;
pub fn deinit(self: *Window) void {
    RGFW_window_close(self.window);
}

extern fn RGFW_window_shouldClose(win: *RGFW_Window) bool;

extern fn RGFW_window_checkEvent(win: *RGFW_Window, event: *CEvent) bool;
pub fn getEvent(self: *Window) ?Event {
    self.should_close = RGFW_window_shouldClose(self.window);

    var c_event: CEvent = undefined;
    while (RGFW_window_checkEvent(self.window, &c_event)) {
        // Filter events to only return ones for this window
        if (c_event.common.win == @as(*anyopaque, @ptrCast(self.window))) {
            return Event.fromC(c_event);
        }
    }
    return null;
}
