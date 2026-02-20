const sdt = @import("sdt.zig");

const std = @import("std");

pub const MadtFlags = packed struct(u32) {
    pcat_compat: bool,
    _: u31,
};

pub const Madt = extern struct {
    header: sdt.SystemDescriptorTableHeader,
    lapic_addr: u32,
    flags: MadtFlags,
    _: u0 = 0,

    pub fn iterator(self: *align(1) const Madt) Iterator {
        return .{ .madt = self, .offset = @offsetOf(Madt, "_") };
    }

    pub const Iterator = struct {
        madt: *align(1) const Madt,
        offset: usize,

        pub fn next_raw(self: *Iterator) ?*align(1) const MadtEntryHeader {
            if (self.offset >= self.madt.header.length) return null;
            const bytes: [*]const u8 = @ptrCast(self.madt);
            const hdr: *align(1) const MadtEntryHeader = @ptrCast(bytes + self.offset);
            self.offset += hdr.length;
            return hdr;
        }
        pub fn next(self: *Iterator) ?MadtEntry {
            const hdr = next_raw(self) orelse return null;
            switch (hdr.type) {
                _ => return .{ .unknown = hdr },
                inline else => |tag| return @unionInit(MadtEntry, @tagName(tag), @ptrCast(hdr)),
            }
        }
    };
};

pub const MadtEntryType = enum(u8) {
    local_apic = 0x0,
    io_apic = 0x1,
    interrupt_source_override = 0x2,
    nmi_source = 0x3,
    lapic_nmi = 0x4,
    local_apic_addr_override = 0x5,
    io_sapic = 0x6,
    local_sapic = 0x7,
    platform_interrupt_sources = 0x8,
    proc_local_x2apic = 0x9,
    local_x2apic_nmi = 0xA,
    gic_cpu_interface = 0xB,
    gic_distributor = 0xC,
    gic_msi_frame = 0xD,
    gic_redistributor = 0xE,
    gic_interrupt_translation_service = 0xF,
    multiprocessor_wakeup = 0x10,
    _,
};

pub const MadtEntryHeader = extern struct {
    type: MadtEntryType align(1),
    length: u8 align(1),
};

pub const AcpiPolarity = enum(u2) {
    default,
    active_high,
    reserved,
    active_low,
};
pub const AcpiTrigger = enum(u2) {
    default,
    edge_triggered,
    reserved,
    level_triggered,
};
pub const GiccInterruptMode = enum(u1) {
    level,
    edge,
};

pub const MadtInterruptSourceFlags = packed struct(u16) {
    polarity: AcpiPolarity,
    trigger: AcpiTrigger,
    _: u12 = 0,
};

pub const MadtEntry = b: {
    const tags = std.enums.values(MadtEntryType);
    const count = tags.len + 1;
    var names: [count][]const u8 = undefined;
    var enum_vals: [count]u16 = undefined;
    var types: [count]type = undefined;
    const attrs: [count]std.builtin.Type.UnionField.Attributes = @splat(.{});
    names[0] = "unknown";
    types[0] = *align(1) const MadtEntryHeader;
    enum_vals[0] = std.math.maxInt(u16);
    for (tags, 1..) |tag, i| {
        names[i] = @tagName(tag);
        types[i] = *align(1) const MadtEntryPayload(tag);
        enum_vals[i] = @intFromEnum(tag);
    }
    const Tag = @Enum(u16, .exhaustive, &names, &enum_vals);
    break :b @Union(.auto, Tag, &names, &types, &attrs);
};

pub fn MadtEntryPayload(comptime t: MadtEntryType) type {
    return switch (t) {
        .local_apic => extern struct {
            header: MadtEntryHeader,
            processor_uid: u8,
            local_apic_id: u8,
            flags: packed struct(u32) {
                enabled: bool,
                online_capable: bool,
                _: u30,
            },
        },
        .lapic_nmi => extern struct {
            header: MadtEntryHeader align(4),
            processor_uid: u8,
            flags: MadtInterruptSourceFlags align(1),
            pin: u8,
        },
        .local_apic_addr_override => extern struct {
            header: MadtEntryHeader align(4),
            lapic_addr: usize align(4),
        },
        .io_apic => extern struct {
            header: MadtEntryHeader,
            ioapic_id: u8,
            ioapic_addr: u32 align(4),
            gsi_base: u32 align(4),
        },
        .interrupt_source_override => extern struct {
            header: MadtEntryHeader,
            bus: u8,
            source: u8,
            gsi: u32,
            flags: MadtInterruptSourceFlags align(1),
        },
        .gic_cpu_interface => extern struct {
            header: MadtEntryHeader,
            gic_cpu_iface_number: u32,
            processor_uid: u32,
            flags: packed struct(u32) {
                enabled: bool,
                perf_interrupt_mode: GiccInterruptMode,
                vgic_maintenance_interrupt_mode: GiccInterruptMode,
                online_capable: bool,
                gicr_non_coherent: bool,
                _: u27 = 0,
            },
            parking_proto_version: u32,
            perf_interrupt_gsi: u32,
            parked_address: u64,
            physical_base_address: u64,
            gicv_registers: u64,
            gich_registers: u64,
            vgic_maintenance_interrupt: u32,
            gicr_base_address: u64 align(4),
            mpidr: u64 align(4),
            power_eff_class: u8,
            _: u8 = 0,
            spe_ovflw_interrupt: u16,
            trbe_interrupt: u16,
        },
        .gic_distributor => extern struct {
            header: MadtEntryHeader,
            gicd_id: u32,
            base_addr: u64,
            sys_vector_base: u32 = 0,
            gic_version: u8,
        },
        .gic_redistributor => extern struct {
            header: MadtEntryHeader,
            flags: packed struct(u8) {
                non_coherent: bool,
                _: u7 = 0,
            } align(1),
            discovery_base_addr: u64 align(4),
            discovery_length: u32,
        },
        else => extern struct {
            header: MadtEntryHeader,
        },
    };
}