const std = @import("std");
const sdt = @import("sdt.zig");
const Gas = @import("gas.zig").Gas;

pub const Fadt = extern struct {
    header: sdt.SystemDescriptorTableHeader,
    firmware_ctrl: u32,
    dsdt: u32,
    _1: u8 = 0,
    preferred_pm_profile: enum(u8) {
        unspecified,
        desktop,
        mobile,
        workstation,
        enterprise_server,
        soho_server,
        appliance_pc,
        performance_server,
        tablet,
    },
    sci_int: u16,
    smi_cmd: u32,
    acpi_enable: u8,
    acpi_disable: u8,
    s4bios_req: u8,
    pstate_cnt: u8,
    pm1a_evt_blk: u32,
    pm1b_evt_blk: u32,
    pm1a_cnt_blk: u32,
    pm1b_cnt_blk: u32,
    pm2_cnt_blk: u32,
    pm_tmr_blk: u32,
    gpe0_blk: u32,
    gpe1_blk: u32,
    pm1_evt_len: u8,
    pm1_cnt_len: u8,
    pm2_cnt_len: u8,
    pm_tmr_len: u8,
    gpe0_blk_len: u8,
    gpe1_blk_len: u8,
    gpe1_base: u8,
    cst_cnt: u8,
    p_lvl2_lat: u16,
    p_lvl3_lat: u16,
    flush_size: u16,
    flush_stride: u16,
    duty_offset: u8,
    duty_width: u8,
    day_alrm: u8,
    mon_alrm: u8,
    century: u8,
    iapc_boot_arch: u8,
    _2: u8 = 0,
    flags: u32,
    reset_reg: Gas,
    reset_value: u8,
    arm_boot_arch: u16 align(1),
    fadt_minor_version: u8,
    x_firmware_ctrl: u64,
    x_dsdt: u64,
    x_pm1a_evt_blk: Gas,
    x_pm1b_evt_blk: Gas,
    x_pm1a_cnt_blk: Gas,
    x_pm1b_cnt_blk: Gas,
    x_pm2_cnt_blk: Gas,
    x_pm_tmr_blk: Gas,
    x_gpe0_blk: Gas,
    x_gpe1_blk: Gas,
    sleep_control_reg: Gas,
    sleep_status_reg: Gas,
    hv_vendor_identity: [8]u8,
};
