const std = @import("std");
const sdt = @import("sdt.zig");

pub const Srat = extern struct {
    header: sdt.SystemDescriptorTableHeader,
    _res0: [3]u32 = @splat(0),

    pub fn iterator(self: *align(1) const Srat) Iterator {
        var iter: Iterator = .{
            .bytes = @ptrCast(self),
            .remaining = self.header.length,
        };
        iter.bytes += 48;
        iter.remaining -= 48;
        return iter;
    }

    pub const AllocationHeader = extern struct {
        pub const Type = enum(u8) {
            lapic = 0,
            memory = 1,
            x2apic = 2,
            gicc = 3,
            gic_its = 4,
            generic_initiator = 5,
            generic_port = 6,
            rintc = 7,
        };

        type: Type,
        length: u8,
    };
    pub const Allocation = extern union {
        header: AllocationHeader,
        lapic: extern struct {
            header: AllocationHeader,
            prox_domain_low: u8,
            apic_id: u8,
            flags: packed struct(u32) {
                enabled: bool,
                _res0: u31 = 0,
            },
            sapic_eid: u8,
            prox_domain_high: [3]u8,
            clock_domain: u32,

            pub fn prox_domain(self: *align(1) const @This()) u32 {
                const block: [4]u8 = [1]u8{self.prox_domain_low} ++ self.prox_domain_high;
                return std.mem.bytesToValue(u32, &block);
            }
        },
        memory: extern struct {
            header: AllocationHeader,
            prox_domain: u32 align(2),
            _res0: u16 = 0,
            base_address: u64,
            length: u64,
            _res1: u32 = 0,
            flags: packed struct(u32) {
                enabled: bool,
                hot_pluggable: bool,
                non_volatile: bool,
                specific_purpose: u29,
            },
            _res2: u64 = 0,
        },
        x2apic: extern struct {
            header: AllocationHeader,
            _res0: u16 = 0,
            prox_domain: u32,
            x2apic_id: u32,
            flags: packed struct(u32) {
                enabled: bool,
                _res0: u31 = 0,
            },
            clock_domain: u32,
            _res1: u32 = 0,
        },
        gicc: extern struct {
            header: AllocationHeader,
            prox_domain: u32 align(2),
            processor_uid: u32 align(2),
            flags: packed struct(u32) {
                enabled: bool,
                _res0: u31 = 0,
            } align(2),
            clock_domain: u32 align(2),
        },
        gic_its: extern struct {
            header: AllocationHeader,
            prox_domain: u32 align(2),
            _res0: u16 = 0,
            its_id: u32,
        },
    };

    pub const Iterator = struct {
        remaining: u32,
        bytes: [*]const u8,

        pub fn next(self: *Iterator) ?*align(1) const Allocation {
            if (self.remaining < 2) return null;
            const alloc: *align(1) const Allocation = @ptrCast(self.bytes);
            self.remaining -= alloc.header.length;
            self.bytes += alloc.header.length;
            return alloc;
        }
    };
};
