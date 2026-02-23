const uacpi = @import("uacpi.zig");

pub const SleepState = enum(u32) {
    s0,
    s1,
    s2,
    s3,
    s4,
    s5,
};

extern fn uacpi_prepare_for_sleep_state(SleepState) callconv(.c) uacpi.uacpi_status;
pub inline fn prepare_for_sleep_state(state: SleepState) !void {
    return try uacpi_prepare_for_sleep_state(state).err();
}

extern fn uacpi_enter_sleep_state(SleepState) callconv(.c) uacpi.uacpi_status;
pub inline fn enter_sleep_state(state: SleepState) !void {
    return try uacpi_enter_sleep_state(state).err();
}