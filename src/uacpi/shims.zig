const uacpi = @import("uacpi.zig");
const std = @import("std");
const zuacpi = @import("../zuacpi.zig");

const log = std.log.scoped(.uacpi);

export fn uacpi_kernel_alloc(size: usize) callconv(.c) ?[*]align(16) u8 {
    const ret = zuacpi.options.allocator.alignedAlloc(u8, .@"16", size) catch return null;
    return ret.ptr;
}

export fn uacpi_kernel_free(address: [*]align(16) u8, size: usize) callconv(.c) void {
    zuacpi.options.allocator.free(address[0..size]);
}
