const uacpi = @import("uacpi.zig");
const std = @import("std");
const resources = @import("resources.zig");

pub const NamespaceNode = opaque {
    pub const IterationDecision = enum(u32) {
        @"continue" = 0,
        @"break",
        next_peer,
    };

    pub const IterationCallback = fn (user: ?*anyopaque, node: *NamespaceNode, depth: u32) callconv(.c) IterationDecision;

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

    extern fn uacpi_namespace_node_name(node: *const NamespaceNode) callconv(.c) u32;
    pub fn name(node: *const NamespaceNode) [4]u8 {
        return @bitCast(uacpi_namespace_node_name(node));
    }

    extern fn uacpi_namespace_node_generate_absolute_path(node: *const NamespaceNode) callconv(.c) ?[*:0]const u8;
    pub fn generate_absolute_path(node: *const NamespaceNode) error{OutOfMemory}![:0]const u8 {
        return std.mem.span(uacpi_namespace_node_generate_absolute_path(node) orelse return error.OutOfMemory);
    }

    extern fn uacpi_namespace_node_type(node: *const NamespaceNode, out_type: *uacpi.ObjectType) callconv(.c) uacpi.uacpi_status;
    pub fn node_type(node: *const NamespaceNode) !uacpi.ObjectType {
        var typ: uacpi.ObjectType = undefined;
        try uacpi_namespace_node_type(node, &typ).err();
        return typ;
    }

    extern fn uacpi_namespace_node_get_object(node: *const NamespaceNode) callconv(.c) ?*uacpi.Object;
    pub const get_object = uacpi_namespace_node_get_object;

    extern fn uacpi_namespace_node_parent(node: *NamespaceNode) callconv(.c) ?*NamespaceNode;
    pub const get_parent = uacpi_namespace_node_parent;

    pub const IdString = extern struct {
        size: u32,
        value: [*]u8,

        pub fn str(self: *IdString) [:0]u8 {
            return self.value[0..(self.size - 1) :0];
        }

        pub fn str_const(self: *const IdString) [:0]const u8 {
            return self.value[0..(self.size - 1) :0];
        }
    };

    pub const PnpIdList = extern struct {
        count: u32,
        size: u32,
        pub fn ids(self: *PnpIdList) []IdString {
            return @as([*]IdString, @ptrCast(@as([*]u8, @ptrCast(self)) + @sizeOf(PnpIdList)))[0..self.count];
        }
        pub fn ids_const(self: *const PnpIdList) []const IdString {
            return @as([*]const IdString, @ptrCast(@alignCast(@as([*]const u8, @ptrCast(self)) + @sizeOf(PnpIdList))))[0..self.count];
        }
        pub fn dupe(self: *const PnpIdList, alloc: std.mem.Allocator) ![]const []const u8 {
            const slc = try alloc.alloc([]const u8, self.count);
            for (self.ids_const(), 0..) |s, i| {
                slc[i] = try alloc.dupe(u8, s.str_const());
            }
            return slc;
        }
    };

    pub const InfoFlags = packed struct(u8) {
        has_adr: bool,
        has_hid: bool,
        has_uid: bool,
        has_cid: bool,
        has_cls: bool,
        has_sxd: bool,
        has_sxw: bool,
        _: u1 = 0,
    };

    pub const Info = extern struct {
        size: u32,
        name: [4]u8,
        typ: uacpi.Object.Type,
        params: u8,
        flags: InfoFlags,
        sxd: [4]u8,
        sxw: [5]u8,
        adr: u64,
        hid: IdString,
        uid: IdString,
        cls: IdString,
        cid: PnpIdList,

        extern fn uacpi_free_namespace_node_info(info: *Info) callconv(.c) void;
        pub const free_namespace_node_info = uacpi_free_namespace_node_info;
    };

    extern fn uacpi_get_namespace_node_info(node: *NamespaceNode, out_info: **Info) callconv(.c) uacpi.uacpi_status;
    pub fn get_namespace_node_info(node: *NamespaceNode) error{OutOfMemory}!*Info {
        var info: *Info = undefined;
        try @as(error{OutOfMemory}!void, @errorCast(uacpi_get_namespace_node_info(node, &info).err()));
        return info;
    }

    pub const PciRoutingTableEntry = extern struct {
        address: u32,
        index: u32,
        source: ?*NamespaceNode,
        pin: u8,
    };

    pub const PciRoutingTable = extern struct {
        count: usize,

        pub fn entries(self: *const PciRoutingTable) []const PciRoutingTableEntry {
            return @as([*]PciRoutingTableEntry, @ptrCast(@as([*]align(8) u8, @ptrCast(self)) + @sizeOf(usize)))[0..self.count];
        }

        extern fn uacpi_free_pci_routing_table(table: *const PciRoutingTable) callconv(.c) void;
        pub const deinit = uacpi_free_pci_routing_table;
    };

    extern fn uacpi_get_pci_routing_table(parent: *NamespaceNode, out_table: **PciRoutingTable) uacpi.uacpi_status;
    pub fn get_pci_routing_table(bus: *NamespaceNode) !*PciRoutingTable {
        var tbl: *PciRoutingTable = undefined;
        try uacpi_get_pci_routing_table(bus, &tbl).err();
        return tbl;
    }

    extern fn uacpi_namespace_node_next(parent: *NamespaceNode, iter: *?*NamespaceNode) callconv(.c) uacpi.uacpi_status;
    pub fn next_child(parent: *NamespaceNode, iter: *?*NamespaceNode) !?*NamespaceNode {
        uacpi_namespace_node_next(parent, iter).err() catch |err| switch (err) {
            error.NotFound => return null,
            else => return err,
        };
        return iter.*;
    }

    extern fn uacpi_namespace_node_next_typed(parent: *NamespaceNode, iter: *?*NamespaceNode, types: u32) callconv(.c) uacpi.uacpi_status;
    pub fn next_child_typed(parent: *NamespaceNode, iter: *?*NamespaceNode, types: uacpi.Object.TypeSet) !?*NamespaceNode {
        uacpi_namespace_node_next_typed(parent, iter, types.bits.mask).err() catch |err| switch (err) {
            error.NotFound => return null,
            else => return err,
        };
        return iter.*;
    }

    pub const PredefinedNamespace = enum(u32) { root, gpe, pr, sb, si, tz, gl, os, osi, rev };

    extern fn uacpi_namespace_get_predefined(ns: PredefinedNamespace) callconv(.c) *NamespaceNode;
    pub const predefined = uacpi_namespace_get_predefined;

    extern fn uacpi_namespace_root() callconv(.c) *NamespaceNode;
    pub const root = uacpi_namespace_root;

    extern fn uacpi_eval_simple_integer(parent: *NamespaceNode, path: [*:0]const u8, out_value: *u64) callconv(.c) uacpi.uacpi_status;
    pub fn eval_simple_integer(parent: *NamespaceNode, path: [:0]const u8) !u64 {
        var out: u64 = undefined;
        try uacpi_eval_simple_integer(parent, path.ptr, &out).err();
        return out;
    }

    pub fn eval_simple_integer_optional(parent: *NamespaceNode, path: [:0]const u8) !?u64 {
        return eval_simple_integer(parent, path) catch |err| switch (err) {
            error.NotFound => return null,
            else => return err,
        };
    }

    extern fn uacpi_eval_simple_string(parent: *NamespaceNode, path: [*:0]const u8, out: **uacpi.Object) callconv(.c) uacpi.uacpi_status;
    pub fn eval_simple_string(parent: *NamespaceNode, path: [:0]const u8) !*uacpi.Object {
        var handle: *uacpi.Object = undefined;
        try uacpi_eval_simple_string(parent, path.ptr, &handle).err();
        return handle;
    }

    pub fn eval_simple_string_optional(parent: *NamespaceNode, path: [:0]const u8) !?*uacpi.Object {
        return eval_simple_string(parent, path) catch |err| switch (err) {
            error.NotFound => return null,
            error.InvalidArgument => return null,
            else => return err,
        };
    }

    extern fn uacpi_eval_simple_buffer_or_string(parent: *NamespaceNode, path: [*:0]const u8, out: **uacpi.Object) callconv(.c) uacpi.uacpi_status;
    pub fn eval_simple_buffer_or_string(parent: *NamespaceNode, path: [:0]const u8) !*uacpi.Object {
        var handle: *uacpi.Object = undefined;
        try uacpi_eval_simple_buffer_or_string(parent, path.ptr, &handle).err();
        return handle;
    }

    pub fn eval_simple_buffer_or_string_optional(parent: *NamespaceNode, path: [:0]const u8) !?*uacpi.Object {
        return eval_simple_buffer_or_string(parent, path) catch |err| switch (err) {
            error.NotFound => return null,
            else => return err,
        };
    }

    extern fn uacpi_get_current_resources(n: *NamespaceNode, out_resources: **resources.Resources) callconv(.c) uacpi.uacpi_status;
    pub fn get_current_resources(node: *NamespaceNode) !?*resources.Resources {
        var r: *resources.Resources = undefined;
        uacpi_get_current_resources(node, &r).err() catch |err| switch (err) {
            error.NotFound => return null,
            else => return err,
        };
        return r;
    }

    extern fn uacpi_get_possible_resources(n: *NamespaceNode, out_resources: **resources.Resources) callconv(.c) uacpi.uacpi_status;
    pub fn get_possible_resources(node: *NamespaceNode) !?*resources.Resources {
        var r: *resources.Resources = undefined;
        uacpi_get_possible_resources(node, &r).err() catch |err| switch (err) {
            error.NotFound => return null,
            else => return err,
        };
        return r;
    }
};

extern fn uacpi_free_absolute_path(path: [*:0]const u8) callconv(.c) void;
pub const free_absolute_path = uacpi_free_absolute_path;
