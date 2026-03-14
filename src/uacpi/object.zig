const uacpi = @import("uacpi.zig");

pub const ProcessorInfo = extern struct {
    id: u8,
    block_address: u32,
    block_length: u8,
};

pub const DataView = extern struct {
    data: [*]u8,
    length: usize,
};

extern fn uacpi_object_get_processor_info(object: *uacpi.Object, out: *ProcessorInfo) callconv(.c) uacpi.uacpi_status;
pub fn get_processor_info(object: *uacpi.Object) !ProcessorInfo {
    var info: ProcessorInfo = undefined;
    try uacpi_object_get_processor_info(object, &info).err();
    return info;
}

extern fn uacpi_object_get_string(object: *uacpi.Object, out: *DataView) callconv(.c) uacpi.uacpi_status;
pub fn get_string(object: *uacpi.Object) ![]u8 {
    var dv: DataView = undefined;
    switch (uacpi_object_get_string(object, &dv)) {
        .ok => {},
        .invalid_argument => return error.InvalidArgument,
        else => unreachable,
    }
    return dv.data[0..dv.length];
}

extern fn uacpi_object_get_string_or_buffer(object: *uacpi.Object, out: *DataView) callconv(.c) uacpi.uacpi_status;
pub fn get_string_or_buffer(object: *uacpi.Object) ![]u8 {
    var dv: DataView = undefined;
    switch (uacpi_object_get_string_or_buffer(object, &dv)) {
        .ok => {},
        .invalid_argument => return error.InvalidArgument,
        else => unreachable,
    }
    return dv.data[0..dv.length];
}

extern fn uacpi_object_get_buffer(object: *uacpi.Object, out: *DataView) callconv(.c) uacpi.uacpi_status;
pub fn get_buffer(object: *uacpi.Object) ![]u8 {
    var dv: DataView = undefined;
    switch (uacpi_object_get_buffer(object, &dv)) {
        .ok => {},
        .invalid_argument => return error.InvalidArgument,
        else => unreachable,
    }
    return dv.data[0..dv.length];
}
