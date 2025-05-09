pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const clap_mod = b.addModule("clap", .{
        .root_source_file = b.path("clap.zig"),
        .target = target,
        .optimize = optimize,
    });

    const example_step = b.step("examples", "Build examples");
    for ([_][]const u8{
        "help",
        "simple",
        "simple-ex",
        "streaming-clap",
        "subcommands",
        "usage",
    }) |example_name| {
        const example = b.addExecutable(.{
            .name = example_name,
            .root_source_file = b.path(b.fmt("example/{s}.zig", .{example_name})),
            .target = target,
            .optimize = optimize,
        });
        const install_example = b.addInstallArtifact(example, .{});
        example.root_module.addImport("clap", clap_mod);
        example_step.dependOn(&example.step);
        example_step.dependOn(&install_example.step);
    }

    const all_step = b.step("all", "Build everything and runs all tests");
    all_step.dependOn(example_step);

    b.default_step.dependOn(all_step);
}

const std = @import("std");
