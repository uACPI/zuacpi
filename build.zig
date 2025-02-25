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

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uacpi_log_level = b.option(UacpiLogLevel, "log_level", "uACPI log level") orelse .info;

    const uacpi = b.dependency("uacpi", .{});

    const module = b.addModule("zuacpi", .{
        .root_source_file = b.path("src/zuacpi.zig"),
        .target = target,
        .optimize = optimize,
    });

    const uacpi_flags: []const []const u8 = &.{
        "-ffreestanding",
        "-nostdlib",
        "-DUACPI_SIZED_FREES",
        "-DUACPI_OVERRIDE_ARCH_HELPERS",
        b.fmt("-DUACPI_DEFAULT_LOG_LEVEL=UACPI_LOG_{s}", .{std.ascii.toUpper(@tagName(uacpi_log_level))}),
    };

    module.addIncludePath(uacpi.path("include"));
    module.addCSourceFiles(.{
        .files = uacpi_src,
        .flags = uacpi_flags,
        .root = uacpi.path("source"),
    });
}
