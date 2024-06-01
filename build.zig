const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .abi = .gnuabi64,
            // DL2100 is Intel Atom C2350 based, which is "formerly Avoton"[1]
            // which is of the Silvermont microarch[2].
            // [1] https://www.intel.com/content/www/us/en/products/sku/77977/intel-atom-processor-c2350-1m-cache-1-70-ghz/specifications.html
            // [2] https://en.wikipedia.org/wiki/Silvermont
            .cpu_model = .{ .explicit = &std.Target.x86.cpu.silvermont },
            .os_tag = .linux,
        },
    });

    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSafe });

    const exe = b.addExecutable(.{
        .name = "wd-dl2100-exporter",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });

    const serial = b.dependency("serial", .{
        .target = target,
        .optimize = optimize,
    });

    const serial_mod = b.addModule("serial", .{
        .root_source_file = serial.path("src/serial.zig"),
    });

    exe.root_module.addImport("httpz", httpz.module("httpz"));
    exe.root_module.addImport("serial", serial_mod);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Selected with `zig build run`
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
