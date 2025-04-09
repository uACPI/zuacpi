const uacpi = @import("uacpi.zig");
const std = @import("std");

const log = std.log.scoped(.uacpi);

export fn uacpi_kernel_log(level: uacpi.log_level, string: [*:0]const u8) callconv(.c) void {
    const str = std.mem.span(string);
    const s = std.mem.trim(u8, str, " \n\r\t");
    switch (level) {
        .debug, .trace => log.debug("{s}", .{s}),
        .info => log.info("{s}", .{s}),
        .warn => log.warn("{s}", .{s}),
        .err => log.err("{s}", .{s}),
    }
}