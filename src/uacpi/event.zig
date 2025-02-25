const uacpi = @import("uacpi.zig");

extern fn uacpi_finalize_gpe_initialization() callconv(.c) uacpi.uacpi_status;
pub fn finalize_gpe_initialization() uacpi.Error!void {
    return uacpi_finalize_gpe_initialization().err();
}

pub const FixedEvent = enum(u32) {
    timer_status = 1,
    power_button,
    sleep_button,
    rtc,
};

extern fn uacpi_install_fixed_event_handler(event: FixedEvent, handler: uacpi.InterruptHandler, context: ?*anyopaque)callconv(.c)  uacpi.uacpi_status;

pub fn install_fixed_event_handler(event: FixedEvent, handler: uacpi.InterruptHandler, context: ?*anyopaque) !void {
    try uacpi_install_fixed_event_handler(event, handler, context).err();
}
