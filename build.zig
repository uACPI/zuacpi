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

    var flags_list: std.ArrayList([]const u8) = std.ArrayList([]const u8).initCapacity(b.allocator, 5) catch @panic("OOM");

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
        .flags = flags_list.toOwnedSlice() catch @panic("OOM"),
        .root = uacpi.path("source"),
    });
}
