const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const enable_webgpu = b.option(bool, "webgpu", "Enable WebGPU support (requires wgpu_native)") orelse false;
    const enable_wayland = b.option(bool, "wayland", "Enable Wayland support") orelse true;

    const rgfw_dep = b.dependency("rgfw", .{});

    const wayland_protocols_dir = b.graph.env_map.get("WAYLAND_PROTOCOLS_DIR") orelse "/nix/store/yb6rfy0ia24j7qqjq4f1jgdiikhkgbv0-wayland-protocols-1.45/share/wayland-protocols";
    const wayland_scanner = b.graph.env_map.get("WAYLAND_SCANNER") orelse "wayland-scanner";

    const xdg_shell_xml = b.fmt("{s}/stable/xdg-shell/xdg-shell.xml", .{wayland_protocols_dir});
    const gen_xdg_shell = b.addSystemCommand(&.{ wayland_scanner, "client-header" });
    gen_xdg_shell.addArg(xdg_shell_xml);
    const xdg_shell_h = gen_xdg_shell.addOutputFileArg("xdg-shell.h");
    const gen_xdg_shell_code = b.addSystemCommand(&.{ wayland_scanner, "private-code" });
    gen_xdg_shell_code.addArg(xdg_shell_xml);
    const xdg_shell_c = gen_xdg_shell_code.addOutputFileArg("xdg-shell.c");

    const toplevel_icon_xml = b.fmt("{s}/staging/xdg-toplevel-icon/xdg-toplevel-icon-v1.xml", .{wayland_protocols_dir});
    const gen_toplevel_icon = b.addSystemCommand(&.{ wayland_scanner, "client-header" });
    gen_toplevel_icon.addArg(toplevel_icon_xml);
    const toplevel_icon_h = gen_toplevel_icon.addOutputFileArg("xdg-toplevel-icon-v1.h");
    const gen_toplevel_icon_code = b.addSystemCommand(&.{ wayland_scanner, "private-code" });
    gen_toplevel_icon_code.addArg(toplevel_icon_xml);
    const toplevel_icon_c = gen_toplevel_icon_code.addOutputFileArg("xdg-toplevel-icon-v1.c");

    const xdg_decoration_xml = b.fmt("{s}/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml", .{wayland_protocols_dir});
    const gen_xdg_decoration = b.addSystemCommand(&.{ wayland_scanner, "client-header" });
    gen_xdg_decoration.addArg(xdg_decoration_xml);
    const xdg_decoration_h = gen_xdg_decoration.addOutputFileArg("xdg-decoration-unstable-v1.h");
    const gen_xdg_decoration_code = b.addSystemCommand(&.{ wayland_scanner, "private-code" });
    gen_xdg_decoration_code.addArg(xdg_decoration_xml);
    const xdg_decoration_c = gen_xdg_decoration_code.addOutputFileArg("xdg-decoration-unstable-v1.c");

    const relative_pointer_xml = b.fmt("{s}/unstable/relative-pointer/relative-pointer-unstable-v1.xml", .{wayland_protocols_dir});
    const gen_relative_pointer = b.addSystemCommand(&.{ wayland_scanner, "client-header" });
    gen_relative_pointer.addArg(relative_pointer_xml);
    const relative_pointer_h = gen_relative_pointer.addOutputFileArg("relative-pointer-unstable-v1.h");
    const gen_relative_pointer_code = b.addSystemCommand(&.{ wayland_scanner, "private-code" });
    gen_relative_pointer_code.addArg(relative_pointer_xml);
    const relative_pointer_c = gen_relative_pointer_code.addOutputFileArg("relative-pointer-unstable-v1.c");

    const pointer_constraints_xml = b.fmt("{s}/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml", .{wayland_protocols_dir});
    const gen_pointer_constraints = b.addSystemCommand(&.{ wayland_scanner, "client-header" });
    gen_pointer_constraints.addArg(pointer_constraints_xml);
    const pointer_constraints_h = gen_pointer_constraints.addOutputFileArg("pointer-constraints-unstable-v1.h");
    const gen_pointer_constraints_code = b.addSystemCommand(&.{ wayland_scanner, "private-code" });
    gen_pointer_constraints_code.addArg(pointer_constraints_xml);
    const pointer_constraints_c = gen_pointer_constraints_code.addOutputFileArg("pointer-constraints-unstable-v1.c");

    const xdg_output_xml = b.fmt("{s}/unstable/xdg-output/xdg-output-unstable-v1.xml", .{wayland_protocols_dir});
    const gen_xdg_output = b.addSystemCommand(&.{ wayland_scanner, "client-header" });
    gen_xdg_output.addArg(xdg_output_xml);
    const xdg_output_h = gen_xdg_output.addOutputFileArg("xdg-output-unstable-v1.h");
    const gen_xdg_output_code = b.addSystemCommand(&.{ wayland_scanner, "private-code" });
    gen_xdg_output_code.addArg(xdg_output_xml);
    const xdg_output_c = gen_xdg_output_code.addOutputFileArg("xdg-output-unstable-v1.c");

    const lib = b.addLibrary(.{
        .name = "rgfw",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    lib.linkLibC();
    lib.addIncludePath(rgfw_dep.path(""));

    if (enable_webgpu) {
        const wgpu_native = b.lazyDependency("wgpu_linux_x86_64_debug", .{}) orelse @panic("wgpu_linux_x86_64_debug dependency not found");
        lib.addIncludePath(wgpu_native.path("include"));
        lib.addLibraryPath(wgpu_native.path("lib"));
    }

    lib.addIncludePath(xdg_shell_h.dirname());
    lib.addIncludePath(toplevel_icon_h.dirname());
    lib.addIncludePath(xdg_decoration_h.dirname());
    lib.addIncludePath(relative_pointer_h.dirname());
    lib.addIncludePath(pointer_constraints_h.dirname());
    lib.addIncludePath(xdg_output_h.dirname());

    const rgfw_c_source = b.fmt(
        \\#define RGFW_UNIX
        \\#define RGFW_X11
        \\{s}{s}#define RGFW_IMPLEMENTATION
        \\#include <RGFW.h>
        \\
    , .{
        if (enable_wayland) "#define RGFW_WAYLAND\n" else "",
        if (enable_webgpu) "#define RGFW_WEBGPU\n" else "",
    });

    lib.addCSourceFile(.{
        .file = b.addWriteFiles().add("rgfw.c", rgfw_c_source),
    });

    if (enable_wayland) {
        lib.addCSourceFile(.{ .file = xdg_shell_c });
        lib.addCSourceFile(.{ .file = toplevel_icon_c });
        lib.addCSourceFile(.{ .file = xdg_decoration_c });
        lib.addCSourceFile(.{ .file = relative_pointer_c });
        lib.addCSourceFile(.{ .file = pointer_constraints_c });
        lib.addCSourceFile(.{ .file = xdg_output_c });
    }

    if (b.graph.env_map.get("LD_LIBRARY_PATH")) |lib_path| {
        var it = std.mem.tokenizeScalar(u8, lib_path, ':');
        while (it.next()) |path| {
            lib.addLibraryPath(.{ .cwd_relative = path });
        }
    }

    if (b.graph.env_map.get("C_INCLUDE_PATH")) |inc_path| {
        var it = std.mem.tokenizeScalar(u8, inc_path, ':');
        while (it.next()) |path| {
            lib.addSystemIncludePath(.{ .cwd_relative = path });
        }
    }

    const mod = b.addModule("rgfw", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    mod.linkLibrary(lib);

    mod.linkSystemLibrary("X11", .{});
    mod.linkSystemLibrary("Xi", .{});
    mod.linkSystemLibrary("Xinerama", .{});
    mod.linkSystemLibrary("Xrandr", .{});
    mod.linkSystemLibrary("Xcursor", .{});
    mod.linkSystemLibrary("GL", .{});

    if (enable_wayland) {
        mod.linkSystemLibrary("wayland-client", .{});
        mod.linkSystemLibrary("wayland-cursor", .{});
        mod.linkSystemLibrary("wayland-egl", .{});
        mod.linkSystemLibrary("decor-0", .{});
        mod.linkSystemLibrary("xkbcommon", .{});
    }

    if (enable_webgpu) {
        const wgpu_native = b.lazyDependency("wgpu_linux_x86_64_debug", .{}) orelse @panic("wgpu_linux_x86_64_debug dependency not found");
        mod.addLibraryPath(wgpu_native.path("lib"));
        mod.linkSystemLibrary("wgpu_native", .{});
    }

    if (b.graph.env_map.get("LD_LIBRARY_PATH")) |lib_path| {
        var it = std.mem.tokenizeScalar(u8, lib_path, ':');
        while (it.next()) |path| {
            mod.addLibraryPath(.{ .cwd_relative = path });
        }
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    const basic_example = b.addExecutable(.{
        .name = "basic",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/basic.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "rgfw", .module = mod },
            },
        }),
    });

    const install_basic = b.addInstallArtifact(basic_example, .{});
    b.getInstallStep().dependOn(&install_basic.step);

    const example_step = b.step("example", "Build and run basic example");
    const run_basic = b.addRunArtifact(basic_example);
    run_basic.step.dependOn(&install_basic.step);
    example_step.dependOn(&run_basic.step);
}
