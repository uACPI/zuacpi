const uacpi = @import("uacpi/uacpi.zig");

const std = @import("std");
const log = std.log.scoped(.zuacpi);

comptime {
    _ = @import("uacpi/shims.zig");
}

pub const Options = struct {
    allocator: std.mem.Allocator = std.heap.smp_allocator,
};

const root = @import("root");

pub const options: Options = if (@hasDecl(root, "zuacpi_options")) root.zuacpi_options else .{};