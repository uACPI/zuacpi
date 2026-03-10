const uacpi = @import("uacpi.zig");

pub const HostInterfaceFeature = enum(u32) {
    module_device = 1,
    processor_device,
    @"3.0_thermal_model",
    @"3.0_scp_extensions",
    processor_aggregator,
};

extern fn uacpi_enable_host_interface(iface: HostInterfaceFeature) callconv(.c) uacpi.uacpi_status;
pub fn enable_host_interface(iface: HostInterfaceFeature) !void {
    return try uacpi_enable_host_interface(iface).err();
}

extern fn uacpi_disable_host_interface(iface: HostInterfaceFeature) callconv(.c) uacpi.uacpi_status;
pub fn disable_host_interface(iface: HostInterfaceFeature) !void {
    return try uacpi_disable_host_interface(iface).err();
}
