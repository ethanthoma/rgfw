pub const Window = @import("Window.zig");

pub const Monitor = extern struct {
    x: i32,
    y: i32,
    name: [128]u8,
    scale_x: f32,
    scale_y: f32,
    pixel_ratio: f32,
    phys_w: f32,
    phys_h: f32,
    mode: Mode,

    pub const Mode = extern struct {
        w: i32,
        h: i32,
        refresh_rate: u32,
        red: u8,
        blue: u8,
        green: u8,
    };
};

extern fn RGFW_getPrimaryMonitor() Monitor;
pub fn getPrimaryMonitor() Monitor {
    return RGFW_getPrimaryMonitor();
}

extern fn RGFW_getMonitors(len: *usize) [*]Monitor;
pub fn getMonitors(len: *usize) [*]Monitor {
    return RGFW_getMonitors(len);
}
