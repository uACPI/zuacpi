const uacpi = @import("uacpi.zig");
const std = @import("std");

pub const Object = opaque {
    pub const Type = enum(u32) {
        uninitialized,
        integer,
        string,
        buffer,
        package,
        field_unit,
        device,
        event,
        method,
        mutex,
        operation_region,
        power_resource,
        processor,
        thermal_zone,
        buffer_field,
        debug = 16,
        reference = 20,
        buffer_index = 21,
    };

    pub const TypeIndexer = std.enums.EnumIndexer(Type);
    pub const TypeSet = std.EnumSet(Type);
    pub const TypeBits = @TypeOf(TypeSet.initEmpty().bits);

    extern fn uacpi_object_unref(obj: *Object) callconv(.c) void;
    pub const unref = uacpi_object_unref;

    extern fn uacpi_object_get_type(obj: *Object) callconv(.c) Type;
    pub const get_type = uacpi_object_get_type;

    pub const ProcessorInfo = extern struct {
        id: u8,
        block_address: u32,
        block_length: u8,
    };

    pub const DataView = extern struct {
        data: [*]u8,
        length: usize,
    };

    extern fn uacpi_object_get_processor_info(object: *Object, out: *ProcessorInfo) callconv(.c) uacpi.uacpi_status;
    pub fn get_processor_info(object: *Object) !ProcessorInfo {
        var info: ProcessorInfo = undefined;
        try uacpi_object_get_processor_info(object, &info).err();
        return info;
    }

    extern fn uacpi_object_get_string(object: *Object, out: *DataView) callconv(.c) uacpi.uacpi_status;
    pub fn get_string(object: *Object) ![]u8 {
        var dv: DataView = undefined;
        switch (uacpi_object_get_string(object, &dv)) {
            .ok => {},
            .invalid_argument => return error.InvalidArgument,
            else => unreachable,
        }
        return dv.data[0..dv.length];
    }

    extern fn uacpi_object_get_string_or_buffer(object: *Object, out: *DataView) callconv(.c) uacpi.uacpi_status;
    pub fn get_string_or_buffer(object: *Object) ![]u8 {
        var dv: DataView = undefined;
        switch (uacpi_object_get_string_or_buffer(object, &dv)) {
            .ok => {},
            .invalid_argument => return error.InvalidArgument,
            else => unreachable,
        }
        return dv.data[0..dv.length];
    }

    extern fn uacpi_object_get_buffer(object: *Object, out: *DataView) callconv(.c) uacpi.uacpi_status;
    pub fn get_buffer(object: *uacpi.Object) ![]u8 {
        var dv: DataView = undefined;
        switch (uacpi_object_get_buffer(object, &dv)) {
            .ok => {},
            .invalid_argument => return error.InvalidArgument,
            else => unreachable,
        }
        return dv.data[0..dv.length];
    }
};
