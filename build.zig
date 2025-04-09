const std = @import("std");
const log = std.log;
const Target = std.Target;
const Build = std.Build;
const LazyPath = Build.LazyPath;

const uacpi_src: []const []const u8 = &.{
    "tables.c",
    "types.c",
    "uacpi.c",
    "utilities.c",
    "interpreter.c",
    "opcodes.c",
    "namespace.c",
    "stdlib.c",
    "shareable.c",
    "opregion.c",
    "default_handlers.c",
    "io.c",
    "notify.c",
    "sleep.c",
    "registers.c",
    "resources.c",
    "event.c",
    "mutex.c",
    "osi.c",
};

pub const UacpiLogLevel = enum {
    trace,
    debug,
    info,
    warn,
    @"error",
};

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uacpi_log_level = b.option(UacpiLogLevel, "log_level", "uACPI log level") orelse .info;
    const override_arch_helpers = b.option(bool, "override_arch_helpers", "defines UACPI_OVERRIDE_ARCH_HELPERS. the kernel must provide uacpi_arch_helpers.h") orelse false;

    const uacpi = b.dependency("uacpi", .{});

    const module = b.addModule("zuacpi", .{
        .root_source_file = b.path("src/zuacpi.zig"),
        .target = target,
        .optimize = optimize,
    });

    var flags_list: std.ArrayList([]const u8) = std.ArrayList([]const u8).initCapacity(b.allocator, 6) catch @panic("OOM");

    flags_list.appendSliceAssumeCapacity(&.{
        "-ffreestanding",
        "-nostdlib",
        "-DUACPI_SIZED_FREES",
        b.fmt("-DUACPI_DEFAULT_LOG_LEVEL=UACPI_LOG_{s}", .{std.ascii.allocUpperString(b.allocator, @tagName(uacpi_log_level)) catch @panic("OOM")}),
    });

    if (override_arch_helpers) {
        flags_list.appendAssumeCapacity("-DUACPI_OVERRIDE_ARCH_HELPERS");
    }

    module.addIncludePath(uacpi.path("include"));
    module.addCSourceFiles(.{
        .files = uacpi_src,
        .flags = b.dupeStrings(flags_list.items),
        .root = uacpi.path("source"),
    });

    const opts = b.addOptions();
    opts.addOption(bool, "barebones", false);

    module.addOptions("opts", opts);

    flags_list.appendAssumeCapacity("-DUACPI_BAREBONES_MODE");

    const bare_module = b.addModule("zuacpi_barebones", .{
        .root_source_file = b.path("src/zuacpi.zig"),
        .target = target,
        .optimize = optimize,
    });

    const bb_opts = b.addOptions();
    bb_opts.addOption(bool, "barebones", true);

    bare_module.addOptions("opts", bb_opts);

    bare_module.addIncludePath(uacpi.path("include"));
    bare_module.addCSourceFiles(.{
        .files = uacpi_src,
        .flags = b.dupeStrings(flags_list.items),
        .root = uacpi.path("source"),
    });
}
