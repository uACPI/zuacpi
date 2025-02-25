pub const uacpi = @import("uacpi/uacpi.zig");

pub const sdt = @import("sdt.zig");
pub const madt = @import("madt.zig");
pub const mcfg = @import("mcfg.zig");
pub const hpet = @import("hpet.zig");
pub const fadt = @import("fadt.zig");

pub const Gas = @import("gas.zig").Gas;

const std = @import("std");

comptime {
    _ = @import("uacpi/shims.zig");
}

pub const Options = struct {
    allocator: std.mem.Allocator = std.heap.smp_allocator,
};

const root = @import("root");

pub const options: Options = if (@hasDecl(root, "zuacpi_options")) root.zuacpi_options else .{};