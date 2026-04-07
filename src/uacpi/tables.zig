const zuacpi = @import("../zuacpi.zig");
const uacpi = zuacpi.uacpi;
const sdt = zuacpi.sdt;
const fadt = zuacpi.fadt;

pub const Table = extern struct {
    location: extern union {
        virt_addr: u64,
        ptr: *align(1) anyopaque,
        hdr: *align(1) const sdt.SystemDescriptorTableHeader,
    },
    index: usize,

    extern fn uacpi_table_find_by_signature(signature: *const [4]u8, out_table: *Table) callconv(.c) uacpi.uacpi_status;
    pub fn find_table_by_signature(signature: sdt.Signature) !Table {
        var t: Table = undefined;
        try uacpi_table_find_by_signature(&signature.to_string(), &t).err();
        return t;
    }

    extern fn uacpi_table_ref(*Table) callconv(.c) uacpi.uacpi_status;
    extern fn uacpi_table_unref(*Table) callconv(.c) uacpi.uacpi_status;

    pub fn unref(tbl: *Table) !void {
        return uacpi_table_unref(tbl).err();
    }

    pub fn ref(tbl: *Table) !void {
        return uacpi_table_ref(tbl).err();
    }
};

pub const TableInstallationDisposition = enum(u32) {
    allow = 0,
    deny,
    virtual_override,
    physical_override,
};

pub const TableInstallationHandler = *const fn (hdr: *align(1) sdt.SystemDescriptorTableHeader, out_override_address: *u64) callconv(.c) TableInstallationDisposition;
extern fn uacpi_set_table_installation_handler(handler: TableInstallationHandler) callconv(.c) uacpi.uacpi_status;

pub fn set_table_installation_handler(handler: TableInstallationHandler) !void {
    return uacpi_set_table_installation_handler(handler).err();
}

extern fn uacpi_table_fadt(tbl: **fadt.Fadt) callconv(.c) uacpi.uacpi_status;
pub fn table_fadt() !*fadt.Fadt {
    var ptr: *fadt.Fadt = undefined;
    try uacpi_table_fadt(&ptr).err();
    return ptr;
}
