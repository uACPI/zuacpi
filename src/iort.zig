const std = @import("std");
const sdt = @import("sdt.zig");

pub const Iort = extern struct {
    header: sdt.SystemDescriptorTableHeader,
    nodes_count: u32,
    nodes_offset: u32,
    _: u32 = 0,

    pub fn iterator(self: *const Iort) Iterator {
        return .{ .bytes = @ptrCast(self), .length = self.header.length, .offset = self.nodes_offset };
    }

    pub const Iterator = struct {
        bytes: [*]const u8,
        offset: u32,
        length: u32,

        pub fn at(self: *const Iterator, offset: u32) *const Node {
            return @ptrCast(@alignCast(self.bytes + offset));
        }

        pub fn next(self: *Iterator) ?*const Node {
            if (self.offset >= self.length) return null;
            const node = at(self, self.offset);
            self.offset += node.length;
            return node;
        }
    };

    pub const Node = extern struct {
        pub const Type = enum(u8) {
            its,
            named_component,
            root_complex,
            smmu12,
            smmu3,
            pmcg,
            memory_range,
            iwb,
            _,
        };

        // pub const Data = union(Type) {
        //
        // };

        type: Type,
        length: u16 align(1),
        revision: u8,
        identifier: u32,
        ids_count: u32,
        ids_offset: u32,

        pub const ITS = extern struct {
            node: Node,
            _: u32 = 1,
            its_id: u32,
        };

        pub const PciRootComplex = extern struct {
            node: Node,
            memory_properties: u64 align(4),
            ats_attribute: u32,
            pci_segment: u32,
            address_size_limit: u8,
            pasid: u16 align(1),
            _: u8 = 0,
            flags: u32,
        };

        pub fn ids(self: *const Node) []const Id {
            if (self.ids_count == 0) return &.{};
            const bytes: [*]const u8 = @ptrCast(self);
            const ids_ptr: [*]const Id = @ptrCast(@alignCast(bytes + self.ids_offset));
            return ids_ptr[0..self.ids_count];
        }

        pub const Id = extern struct {
            input_base: u32,
            count: u32,
            output_base: u32,
            output_reference: u32,
            flags: packed struct(u32) {
                singleton: bool,
                _: u31 = 0,
            },
        };
    };
};
