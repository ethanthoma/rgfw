pub const Window = @import("Window.zig");
pub const Monitor = @import("monitor.zig").Monitor;
pub const MonitorMode = @import("monitor.zig").MonitorMode;

pub const Event = @import("event.zig").Event;
pub const EventType = @import("event.zig").EventType;

pub const KeyPressed = @import("event.zig").KeyPressed;
pub const MouseButtonPressed = @import("event.zig").MouseButtonPressed;
pub const MouseScroll = @import("event.zig").MouseScroll;
pub const MousePosition = @import("event.zig").MousePosition;
pub const DataDrop = @import("event.zig").DataDrop;
pub const DataDrag = @import("event.zig").DataDrag;
pub const ScaleUpdated = @import("event.zig").ScaleUpdated;

pub const Key = @import("key.zig").Key;
pub const KeyModifier = @import("event.zig").KeyModifier;
pub const MouseButton = @import("event.zig").MouseButton;

pub const Area = extern struct { width: u32, height: u32 };
pub const Point = extern struct { x: i32, y: i32 };
