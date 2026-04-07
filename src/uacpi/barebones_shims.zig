const uacpi = @import("uacpi.zig");
const std = @import("std");

const log = std.log.scoped(.uacpi);

export fn uacpi_kernel_log(level: uacpi.log_level, string: [*:0]const u8) callconv(.c) void {
    switch (level) {
        .debug, .trace => log.debug("{s}", .{string}),
        .info => log.info("{s}", .{string}),
        .warn => log.warn("{s}", .{string}),
        .err => log.err("{s}", .{string}),
    }
}
