const std = @import("std");
const sdt = @import("sdt.zig");
const Gas = @import("gas.zig").Gas;

pub const HpetCapabilities = packed struct(u32) {
    hardware_rev_id: u8,
    first_block_comparators: u5,
    count_size_cap_size: bool,
    _: u1 = 0,
    legacy_replacement_irq_routing: bool,
    first_block_pci_vendor_id: u16,
};

pub const Hpet = extern struct {
    header: sdt.SystemDescriptorTableHeader,
    block_id: HpetCapabilities,
    base_address: Gas,
    hpet_number: u8,
    minimum_clock_ticks_periodic_mode: u16 align(1),
    page_protect: packed struct(u8) {
        page_protect: enum(u4) {
            none = 0,
            @"4k" = 1,
            @"64k" = 2,
            _,
        },
        oem_reserved: u4,
    },
};
