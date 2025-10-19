const std = @import("std");
const rgfw = @import("rgfw");

pub fn main() !void {
    var window = try rgfw.Window.init(
        "RGFW Example",
        .{ .x = 100, .y = 100 },
        .{ .width = 200, .height = 200 },
        .{},
    );
    defer window.deinit();

    while (!window.should_close) {
        while (window.getEvent()) |event| {
            std.debug.print("Event: {s}\n", .{@tagName(event)});

            switch (event) {
                .key_pressed, .key_released => |key| {
                    std.debug.print("  Key: {s} (repeat: {})\n", .{ @tagName(key.key), key.repeat });
                },
                .mouse_position_changed => |pos| {
                    std.debug.print("  Mouse: ({}, {})\n", .{ pos.x, pos.y });
                },
                .mouse_button_pressed, .mouse_button_released => |btn| {
                    std.debug.print("  Button: {s}\n", .{@tagName(btn.button)});
                },
                .mouse_scroll => |scroll| {
                    std.debug.print("  Scroll: ({d:.2}, {d:.2})\n", .{ scroll.x, scroll.y });
                },
                .window_resized => {
                    std.debug.print("  Window resized\n", .{});
                },
                else => {},
            }
        }
    }
}
