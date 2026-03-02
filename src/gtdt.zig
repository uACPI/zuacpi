const std = @import("std");
const sdt = @import("sdt.zig");

pub const Gtdt = extern struct {
    pub const Trigger = enum(u1) {
        level,
        edge,
    };

    pub const Polarity = enum(u1) {
        high,
        low,
    };

    pub const Flags = packed struct(u32) {
        trigger: Trigger,
        polarity: Polarity,
        always_on: bool,
        _: u29 = 0,
    };

    header: sdt.SystemDescriptorTableHeader,
    cntcontrolbase: u64 align(4),
    _: u32 = 0,
    secure_el1_gsi: u32,
    secure_el1_flags: Flags,
    nonsecure_el1_gsi: u32,
    nonsecure_el1_flags: Flags,
    virtual_el1_gsi: u32,
    virtual_el1_flags: Flags,
    el2_gsi: u32,
    el2_flags: Flags,
    cntreadbase: u64,
    platform_timer_count: u32,
    platform_timer_offset: u32,
    virtual_el2_gsi: u32,
    virtual_el2_flags: Flags,

    pub const PlatformTimerType = enum(u8) {
        gt,
        generic_watchdog,
    };

    pub const GtBlock = extern struct {
        type: PlatformTimerType = .gt,
        length: u16 align(1),
        _0: u8,
        cntctlbase: u64 align(4),
        timer_count: u32,
        timers_offset: u32,

        pub const GtTimer = extern struct {
            pub const GtFlags = packed struct(u32) {
                trigger: Trigger,
                polarity: Polarity,
                _: u30 = 0,
            };

            frame: u8,
            _: [3]u8,
            cntbase: u64 align(4),
            cntel0base: u64 align(4),
            phys_gsi: u32,
            phys_flags: GtFlags,
            virt_gsi: u32,
            virt_flags: GtFlags,
            common: packed struct(u32) {
                secure: bool,
                always_on: bool,
                _: u30 = 0,
            },
        };
    };

    pub const GenericWatchdog = extern struct {
        type: PlatformTimerType = .generic_watchdog,
        length: u16 align(1),
        _: u8 = 0,
        refreshframe: u64 align(4),
        controlframe: u64 align(4),
        gsi: u32,
        flags: packed struct(u32) {
            trigger: Trigger,
            polarity: Polarity,
            secure: bool,
            _: u29 = 0,
        },
    };
};
