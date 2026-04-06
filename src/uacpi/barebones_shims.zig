const uacpi = @import("uacpi.zig");
const std = @import("std");

const log = std.log.scoped(.uacpi);

export fn uacpi_kernel_log(level: uacpi.log_level, string: [*:0]const u8) callconv(.c) void {
    const str = std.mem.span(string);
    switch (level) {
        .debug, .trace => log.debug("{s}", .{str}),
        .info => log.info("{s}", .{str}),
        .warn => log.warn("{s}", .{str}),
        .err => log.err("{s}", .{str}),
    }
}
