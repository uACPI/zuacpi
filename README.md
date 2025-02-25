# zuacpi

zuacpi is bindings for [uACPI](https://github.com/uACPI/uACPI), adopted from
[imaginarium](https://github.com/Khitiara/imaginarium) under the terms specified
[here](https://github.com/Khitiara/imaginarium/blob/62783b526c2e1e66a376d4357eabd08cad753fca/src/krnl/hal/acpi/uacpi/LICENSE)

To use zuacpi, add it to your `build.zig.zon` manually or use `zig fetch`:

`zig fetch --add=zuacpi git+https://github.com/Khitiara/zuacpi.git#master`

And add its module to your `build.zig`:

```zig
const zuacpi = b.dependency("zuacpi", .{
    .uacpi_log_level = .info, 
    .override_arch_helpers = false,
});

const zuacpi_module = zuacpi.module("zuacpi");

zuacpi_module.addIncludePath(my_freestanding_c_headers_dir);
// uncomment if override_arch_helpers is true:
// zuacpi_module.addIncludePath(my_uacpi_arch_headers_dir);

kernel.addImport("zuacpi", zuacpi_module);
```

Note that this is a work in progress and a number of uACPI functions are not 
yet bouund in zuacpi - feel free to open a pull request if a function you need
is missing!