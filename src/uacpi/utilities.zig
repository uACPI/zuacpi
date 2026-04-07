const uacpi = @import("uacpi.zig");
const namespace = uacpi.namespace;
const std = @import("std");

pub const InterruptModel = enum(u32) {
    pic = 0,
    ioapic = 1,
    iosapic = 2,
    platform_specific = 3,
    gic = 4,
    lpic = 5,
    rintc = 6,
};

extern fn uacpi_set_interrupt_model(InterruptModel) callconv(.c) uacpi.uacpi_status;

pub fn set_interrupt_model(model: InterruptModel) !void {
    try uacpi_set_interrupt_model(model).err();
}
