const uacpi = @import("uacpi.zig");
const namespace = @import("namespace.zig");

extern fn uacpi_eval_simple_integer(parent: *namespace.NamespaceNode, path: [*:0]const u8, out_value: *u64) callconv(.c) uacpi.uacpi_status;
pub fn eval_simple_integer(parent: *namespace.NamespaceNode, name: [:0]const u8) !u64 {
    var out: u64 = undefined;
    try uacpi_eval_simple_integer(parent, name.ptr, &out).err();
    return out;
}

pub fn eval_simple_integer_optional(parent: *namespace.NamespaceNode, name: [:0]const u8) !?u64 {
    return eval_simple_integer(parent, name) catch |err| switch (err) {
        error.NotFound => return null,
        else => return err,
    };
}
