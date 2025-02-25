const std = @import("std");
const sdt = @import("sdt.zig");

pub const Mcfg = extern struct {
    header: sdt.SystemDescriptorTableHeader,
    _: [8]u8 align(1) = [_]u8{0} ** 8,

    pub fn bridges(self: *align(1) const Mcfg) []align(1) const RawPciHostBridge {
        return std.mem.bytesAsSlice(RawPciHostBridge, @as([*]const u8, @ptrCast(self))[@sizeOf(Mcfg)..self.header.length]);
    }
};

const RawPciHostBridge = extern struct {
    base: u64,
    segment_group: u16,
    bus_start: u8,
    bus_end: u8,
    _: u32 = 0,
};