const std = @import("std");
const Point = @import("root.zig").Point;
const Key = @import("key.zig").Key;

pub const KeyModifier = packed struct(u8) {
    caps_lock: bool = false,
    num_lock: bool = false,
    control: bool = false,
    alt: bool = false,
    alt_gr: bool = false,
    shift: bool = false,
    super: bool = false,
    _: u1 = 0,
};

pub const MouseButton = enum(u8) {
    left = 0,
    middle = 1,
    right = 2,
    scroll_up = 3,
    scroll_down = 4,
    _,
};

// C FFI event structs (keep for interop with RGFW)
const CCommonEvent = extern struct {
    type: EventType,
    win: *anyopaque,
};

const CMouseButtonEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    button: u8,
};

const CMouseScrollEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    x: f32,
    y: f32,
};

const CMousePosEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    x: i32,
    y: i32,
    vec_x: f32,
    vec_y: f32,
};

const CKeyEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    key: Key,
    key_char: u8,
    repeat: bool,
    modifier: KeyModifier,
};

const CDataDropEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    files: [*][*:0]u8,
    count: usize,
};

const CDataDragEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    x: i32,
    y: i32,
};

const CScaleUpdatedEvent = extern struct {
    type: EventType,
    win: *anyopaque,
    scale_x: f32,
    scale_y: f32,
};

// Clean Zig event payloads (no type or win fields)
pub const KeyPressed = struct {
    key: Key,
    key_char: u8,
    repeat: bool,
    modifier: KeyModifier,
};

pub const MouseButtonPressed = struct {
    button: MouseButton,
};

pub const MouseScroll = struct {
    x: f32,
    y: f32,
};

pub const MousePosition = struct {
    x: i32,
    y: i32,
    vec_x: f32,
    vec_y: f32,
};

pub const DataDrop = struct {
    files: [*][*:0]u8,
    count: usize,
};

pub const DataDrag = struct {
    x: i32,
    y: i32,
};

pub const ScaleUpdated = struct {
    scale_x: f32,
    scale_y: f32,
};

pub const EventType = enum(u8) {
    none = 0,
    key_pressed = 1,
    key_released = 2,
    mouse_button_pressed = 3,
    mouse_button_released = 4,
    mouse_scroll = 5,
    mouse_position_changed = 6,
    window_moved = 7,
    window_resized = 8,
    focus_in = 9,
    focus_out = 10,
    mouse_enter = 11,
    mouse_leave = 12,
    window_refresh = 13,
    quit = 14,
    data_drop = 15,
    data_drag = 16,
    window_maximized = 17,
    window_minimized = 18,
    window_restored = 19,
    scale_updated = 20,
};

pub const CEvent = extern union {
    type: EventType,
    common: CCommonEvent,
    button: CMouseButtonEvent,
    scroll: CMouseScrollEvent,
    mouse: CMousePosEvent,
    key: CKeyEvent,
    drop: CDataDropEvent,
    drag: CDataDragEvent,
    scale: CScaleUpdatedEvent,
};

pub const Event = union(EventType) {
    none: void,
    key_pressed: KeyPressed,
    key_released: KeyPressed,
    mouse_button_pressed: MouseButtonPressed,
    mouse_button_released: MouseButtonPressed,
    mouse_scroll: MouseScroll,
    mouse_position_changed: MousePosition,
    window_moved: void,
    window_resized: void,
    focus_in: void,
    focus_out: void,
    mouse_enter: void,
    mouse_leave: void,
    window_refresh: void,
    quit: void,
    data_drop: DataDrop,
    data_drag: DataDrag,
    window_maximized: void,
    window_minimized: void,
    window_restored: void,
    scale_updated: ScaleUpdated,

    pub fn fromC(c_event: CEvent) Event {
        return switch (c_event.type) {
            .none => .none,
            .key_pressed => .{ .key_pressed = .{
                .key = c_event.key.key,
                .key_char = c_event.key.key_char,
                .repeat = c_event.key.repeat,
                .modifier = c_event.key.modifier,
            } },
            .key_released => .{ .key_released = .{
                .key = c_event.key.key,
                .key_char = c_event.key.key_char,
                .repeat = c_event.key.repeat,
                .modifier = c_event.key.modifier,
            } },
            .mouse_button_pressed => .{ .mouse_button_pressed = .{
                .button = @enumFromInt(c_event.button.button),
            } },
            .mouse_button_released => .{ .mouse_button_released = .{
                .button = @enumFromInt(c_event.button.button),
            } },
            .mouse_scroll => .{ .mouse_scroll = .{
                .x = c_event.scroll.x,
                .y = c_event.scroll.y,
            } },
            .mouse_position_changed => .{ .mouse_position_changed = .{
                .x = c_event.mouse.x,
                .y = c_event.mouse.y,
                .vec_x = c_event.mouse.vec_x,
                .vec_y = c_event.mouse.vec_y,
            } },
            .window_moved => .window_moved,
            .window_resized => .window_resized,
            .focus_in => .focus_in,
            .focus_out => .focus_out,
            .mouse_enter => .mouse_enter,
            .mouse_leave => .mouse_leave,
            .window_refresh => .window_refresh,
            .quit => .quit,
            .data_drop => .{ .data_drop = .{
                .files = c_event.drop.files,
                .count = c_event.drop.count,
            } },
            .data_drag => .{ .data_drag = .{
                .x = c_event.drag.x,
                .y = c_event.drag.y,
            } },
            .window_maximized => .window_maximized,
            .window_minimized => .window_minimized,
            .window_restored => .window_restored,
            .scale_updated => .{ .scale_updated = .{
                .scale_x = c_event.scale.scale_x,
                .scale_y = c_event.scale.scale_y,
            } },
        };
    }
};
