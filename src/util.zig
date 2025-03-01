const std = @import("std");

pub inline fn EnumMask(comptime Enum: type) type {
    const enum_info: std.builtin.Type.Enum = @typeInfo(Enum).@"enum";
    const max = enum_info.fields[enum_info.fields.len - 1].value;
    const len = comptime @max(32, std.math.ceilPowerOfTwoAssert(usize, max));
    comptime var fields: [len]std.builtin.Type.StructField = undefined;
    inline for (0..len) |i| {
        fields[i] = .{
            .name = std.fmt.comptimePrint("_{d}", .{i}),
            .type = u1,
            .default_value_ptr = &@as(u1, 0),
            .is_comptime = false,
            .alignment = 0,
        };
        inline for (enum_info.fields) |f| {
            if (f.value == i) {
                fields[i] = .{
                    .name = f.name,
                    .type = bool,
                    .default_value_ptr = &false,
                    .is_comptime = false,
                    .alignment = 0,
                };
            }
        }
    }
    return @Type(.{ .@"struct" = std.builtin.Type.Struct{
        .backing_integer = std.meta.Int(.unsigned, len),
        .fields = &fields,
        .layout = .@"packed",
        .decls = &.{},
        .is_tuple = false,
    } });
}

const testing = std.testing;

test EnumMask {
    const E = enum(u8) {
        a = 0,
        b = 2,
        c = 3,
    };
    const Mask = EnumMask(E);
    try testing.expectEqual(0, @bitOffsetOf(Mask, "a"));
    try testing.expectEqual(2, @bitOffsetOf(Mask, "b"));
    try testing.expectEqual(3, @bitOffsetOf(Mask, "c"));
    try testing.expectEqual(32, @bitSizeOf(Mask));
}