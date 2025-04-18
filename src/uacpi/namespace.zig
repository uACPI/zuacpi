const uacpi = @import("uacpi.zig");

pub const IterationDecision = enum(u32) {
    @"continue" = 0,
    @"break",
    next_peer,
};

pub const IterationCallback = fn (user: ?*anyopaque, node: *NamespaceNode, depth: u32) callconv(.c) IterationDecision;

pub const NamespaceNode = opaque {
    extern fn uacpi_namespace_for_each_child_simple(parent: *NamespaceNode, cb: *const IterationCallback, user: ?*anyopaque) callconv(.c) uacpi.uacpi_status;
    pub fn for_each_child_simple(parent: *NamespaceNode, cb: *const IterationCallback, user: ?*anyopaque) !void {
        try uacpi_namespace_for_each_child_simple(parent, cb, user).err();
    }

    extern fn uacpi_namespace_for_each_child(
        parent: *NamespaceNode,
        descending_cb: *const IterationCallback,
        ascending_cb: *const IterationCallback,
        types: uacpi.ObjectTypeBits,
        max_depth: u32,
        user: ?*anyopaque,
    ) callconv(.c) uacpi.uacpi_status;
    pub fn for_each_child(parent: *NamespaceNode, descending_cb: *const IterationCallback, ascending_cb: *const IterationCallback, types: uacpi.ObjectTypeBits, max_depth: u32, user: ?*anyopaque) !void {
        try uacpi_namespace_for_each_child(parent, descending_cb, ascending_cb, types, max_depth, user).err();
    }

    extern fn uacpi_namespace_node_name(node: *const NamespaceNode) callconv(.c) [4]u8;
    pub const name = uacpi_namespace_node_name;

    extern fn uacpi_namespace_node_generate_absolute_path(node: *const NamespaceNode) callconv(.c) ?[*:0]const u8;
    pub const generate_absolute_path = uacpi_namespace_node_generate_absolute_path;

    extern fn uacpi_namespace_node_type(node: *const NamespaceNode, out_type: *uacpi.ObjectType) callconv(.c) uacpi.uacpi_status;
    pub fn node_type(node: *const NamespaceNode) !uacpi.ObjectType {
        var typ: uacpi.ObjectType = undefined;
        try uacpi_namespace_node_type(node, &typ).err();
        return typ;
    }

    extern fn uacpi_namespace_node_get_object(node: *const NamespaceNode) callconv(.c) ?*uacpi.Object;
    pub const get_object = uacpi_namespace_node_get_object;
};

extern fn uacpi_namespace_node_next(parent: *NamespaceNode, iter: *?*NamespaceNode) callconv(.c) uacpi.uacpi_status;
pub fn node_next(parent: *NamespaceNode, iter: *?*NamespaceNode) !?*NamespaceNode {
    uacpi_namespace_node_next(parent, iter).err() catch |err| switch(err) {
        error.NotFound => return null,
        else => return err,
    };
    return iter.*;
}

extern fn uacpi_namespace_node_next_typed(parent: *NamespaceNode, iter: *?*NamespaceNode, types: uacpi.ObjectTypeBits) callconv(.c) uacpi.uacpi_status;
pub fn node_next_typed(parent: *NamespaceNode, iter: *?*NamespaceNode, types: uacpi.ObjectTypeBits) !?*NamespaceNode {
    uacpi_namespace_node_next_typed(parent, iter, types).err() catch |err| switch(err) {
        error.NotFound => return null,
        else => return err,
    };
    return iter.*;
}

pub const PredefinedNamespace = enum(u32) { root, gpe, pr, sb, si, tz, gl, os, osi, rev };

extern fn uacpi_namespace_get_predefined(ns: PredefinedNamespace) callconv(.c) *NamespaceNode;
pub const get_predefined = uacpi_namespace_get_predefined;
extern fn uacpi_namespace_root() callconv(.c) *NamespaceNode;
pub const get_root = uacpi_namespace_root;

extern fn uacpi_free_absolute_path(path: [*:0]const u8) callconv(.c) void;
pub const free_absolute_path = uacpi_free_absolute_path;
