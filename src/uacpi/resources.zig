const uacpi = @import("uacpi.zig");
const namespace = @import("namespace.zig");

pub const ResourceType = enum(u32) {
    irq,
    extended_irq,

    dma,
    fixed_dma,

    io,
    fixed_io,

    addr16,
    addr32,
    addr64,
    addr64_extended,

    mem24,
    mem32,
    fixed_mem32,

    start_dependent,
    end_dependent,

    vendor_small,
    vendor_large,

    generic_register,
    gpio_connection,

    serial_i2c,
    serial_spi,
    serial_uart,
    serial_cs12,

    pin_function,
    pin_configuration,
    pin_group,
    pin_group_function,
    pin_group_configuration,

    clock_input,

    end_tag,
};

pub const LengthKind = enum(u8) {
    dont_care,
    one_less,
    full,
};
pub const Triggering = enum(u8) {
    level_triggered,
    edge_triggered,
};
pub const Polarity = enum(u8) {
    active_high,
    active_low,
    active_both,
};
pub const Sharing = enum(u8) {
    exclusive,
    shared,
};
pub const WakeCapability = enum(u8) {
    not_wake_capable,
    wake_capable,
};
pub const ResoruceSource = extern struct {
    index: u8,
    index_present: bool,
    length: u16,
    string: [*:0]u8,
};
pub const Irq = extern struct {
    length_kind: LengthKind align(@alignOf(usize)),
    trigger: Triggering,
    polarity: Polarity,
    sharing: Sharing,
    wake_capability: WakeCapability,
    num_irqs: u8,
    pub fn irqs(self: *align(1) Irq) []u8 {
        return @as([*]u8, @ptrCast(self))[@sizeOf(Irq)..][0..self.num_irqs];
    }
};
pub const ExtendedIrq = extern struct {
    direction: u8 align(@alignOf(usize)),
    trigger: Triggering,
    polarity: Polarity,
    sharing: Sharing,
    wake_capability: WakeCapability,
    num_irqs: u8,
    source: ResoruceSource,
    pub fn irqs(self: *ExtendedIrq) []u32 {
        return @as([*]u32, @ptrCast(@as([*]align(4) u8, @ptrCast(self))[@sizeOf(ExtendedIrq)..]))[0..self.num_irqs];
    }
};
pub const TransferType = enum(u8) {
    eight_bit,
    eight_and_sixteen_bit,
    sixteen_bit,
};
pub const ChannelSpeed = enum(u8) {
    compatibility,
    type_a,
    type_b,
    type_f,
};
pub const TransferWidth = enum(u8) {
    @"8",
    @"16",
    @"32",
    @"64",
    @"128",
    @"256",
};
pub const Dma = extern struct {
    transfer_type: TransferType align(@alignOf(usize)),
    bus_master_status: bool,
    channel_speed: ChannelSpeed,
    num_channels: u8,

    pub fn channels(self: *Dma) []u8 {
        return @as([*]u8, @ptrCast(self))[@sizeOf(Dma)..][0..self.num_irqs];
    }
};
pub const FixedDma = extern struct {
    request_line: u16 align(@alignOf(usize)),
    channel: u16,
    transfer_width: TransferWidth,
};
pub const IoDecodeType = enum(u8) {
    decode_10,
    decode_16,
};
pub const Io = extern struct {
    decode_type: IoDecodeType align(@alignOf(usize)),
    minimum: u16,
    maximum: u16,
    alignment: u8,
    length: u8,
};
pub const FixedIo = extern struct {
    address: u16 align(@alignOf(usize)),
    length: u8,
};

pub const Caching = enum(u8) {
    non_cacheable,
    cacheable,
    write_combining,
    prefetchable,
};

pub const RangeType = enum(u8) {
    memory,
    reserved,
    acpi,
    nvs,
};

pub const MemTranslation = enum(u8) {
    static,
    translation,
};

pub const TranslationType = enum(u8) {
    dense,
    sparse,
};

pub const Direction = enum(u8) {
    producer,
    consumer,
};

pub const AddrDecodeType = enum(u8) {
    positive,
    subtractive,
};

pub const AddressAttribute = extern union {
    memory: extern struct {
        writeable: bool,
        caching: Caching,
        range_type: RangeType,
        translation: MemTranslation,
    },
    io: extern struct {
        range_type: RangeType,
        translation: MemTranslation,
        translation_type: TranslationType,
    },
    vendor_specific: u8,
};

pub const AddressCommon = extern struct {
    attribute: AddressAttribute,
    typ: enum(u8) {
        memory,
        io,
        bus,
        _,
    },
    direction: Direction,
    decode_type: AddrDecodeType,
    fixed_min_address: bool,
    fixed_max_address: bool,
};

pub inline fn Address(I: type) type {
    return extern struct {
        common: AddressCommon align(@alignOf(usize)),
        granularity: I,
        minimum: I,
        maximum: I,
        translation_offset: I,
        address_length: I,
        source: ResoruceSource,
    };
}

pub const Addr64Extended = extern struct {
    common: AddressCommon align(@alignOf(usize)),
    revision_id: u8,
    granularity: u64,
    minimum: u64,
    maximum: u64,
    translation_offset: u64,
    address_length: u64,
    attributes: u64,
};

pub const FixedMem32 = extern struct {
    write_status: packed struct(u8) {
        writeable: bool,
        _: u7 = 0,
    } align(@alignOf(usize)),
    addr: u32,
    length: u32,
};

pub const Resource = union(ResourceType) {
    irq: *Irq,
    extended_irq: *ExtendedIrq,

    dma: *Dma,
    fixed_dma: *FixedDma,

    io: *Io,
    fixed_io: *FixedIo,

    addr16: *Address(u16),
    addr32: *Address(u32),
    addr64: *Address(u64),
    addr64_extended: *Addr64Extended,
    mem24,
    mem32,
    fixed_mem32: *FixedMem32,
    start_dependent,
    end_dependent,
    vendor_small,
    vendor_large,
    generic_register,
    gpio_connection,
    serial_i2c,
    serial_spi,
    serial_uart,
    serial_cs12,
    pin_function,
    pin_configuration,
    pin_group,
    pin_group_function,
    pin_group_configuration,
    clock_input,
    end_tag,
};

const ResourceNativeUnion: type = @Type(.{ .@"union" = .{
    .layout = .@"extern",
    .tag_type = null,
    .decls = &.{},
    .fields = b: {
        const f = @typeInfo(Resource).@"union".fields;
        var f2: [f.len]@import("std").builtin.Type.UnionField = undefined;
        for (0..f.len) |i| {
            const T = switch (@typeInfo(f[i].type)) {
                .pointer => |p| p.child,
                .void => *struct {},
                else => unreachable,
            };
            f2[i] = .{
                .name = f[i].name,
                .alignment = @alignOf(usize),
                .type = T,
            };
        }

        const f3 = f2;
        break :b &f3;
    },
} });

pub const ResourceNative = extern struct {
    typ: ResourceType align(@alignOf(usize)),
    length: u32,
    resource: ResourceNativeUnion,

    pub fn tagged(self: *ResourceNative) Resource {
        switch (self.typ) {
            .end_tag => unreachable,
            inline else => |t| return if (@FieldType(Resource, @tagName(t)) == void) @unionInit(Resource, @tagName(t), {}) else @unionInit(Resource, @tagName(t), &@field(self.resource, @tagName(t))),
        }
    }
};

pub const Resources = extern struct {
    length: usize,
    entries: [*] align(@alignOf(usize)) u8, // actually a [*]ResourceNative but fucked up window struct indexer things apply

    pub const Iterator = struct {
        remain_len: usize,
        ptr: [*] align(@alignOf(usize)) u8,

        pub fn next(self: *Iterator) ?Resource {
            const native: *ResourceNative = @ptrCast(self.ptr);
            if (native.typ == .end_tag or self.remain_len == 0) return null;
            self.ptr = @alignCast(self.ptr + native.length);
            self.remain_len -|= native.length;
            return native.tagged();
        }
    };

    pub fn iterator(self: *const Resources) Iterator {
        return .{
            .remain_len = self.length,
            .ptr = self.entries,
        };
    }

    extern fn uacpi_free_resources(r: *Resources) callconv(.c) void;
    pub const deinit = uacpi_free_resources;
};

extern fn uacpi_get_current_resources(n: *namespace.NamespaceNode, out_resources: **Resources) callconv(.c) uacpi.uacpi_status;
pub fn get_current_resources(node: *namespace.NamespaceNode) !?*Resources {
    var r: *Resources = undefined;
    uacpi_get_current_resources(node, &r).err() catch |err| switch (err) {
        error.NotFound => return null,
        else => return err,
    };
    return r;
}

comptime {
    @import("std").testing.refAllDeclsRecursive(@This());
}
