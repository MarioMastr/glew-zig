const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glew = b.addLibrary(.{
        .name = "glew",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    const glewinfo = b.addExecutable(.{
        .name = "glewinfo",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    const visualinfo = b.addExecutable(.{
        .name = "visualinfo",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    glew.addCSourceFiles(.{
        .files = &.{
            "src/glew.c",
        },
        .flags = &.{
            "-std=c11",
        },
    });

    glewinfo.addCSourceFiles(.{
        .files = &.{
            "src/glewinfo.c",
        },
        .flags = &.{
            "-std=c11",
        },
    });

    visualinfo.addCSourceFiles(.{
        .files = &.{
            "src/visualinfo.c",
        },
        .flags = &.{
            "-std=c11",
        },
    });

    glewinfo.linkLibrary(glew);
    visualinfo.linkLibrary(glew);

    if (target.result.os.tag == .macos) {
        glewinfo.root_module.linkFramework("OpenGL", .{
            .needed = true,
        });
        visualinfo.root_module.linkFramework("OpenGL", .{
            .needed = true,
        });
    }

    // Link C files
    glew.linkLibC();
    glewinfo.linkLibC();
    visualinfo.linkLibC();

    // Include "include/"
    glew.addIncludePath(b.path("include"));
    glewinfo.addIncludePath(b.path("include"));
    visualinfo.addIncludePath(b.path("include"));

    // Enable static library mode
    glew.root_module.addCMacro("GLEW_STATIC", "1");

    glew.installHeadersDirectory(b.path("include/GL"), "GL", .{ .include_extensions = &.{"h"} });

    b.installArtifact(glew);
    b.installArtifact(glewinfo);
    b.installArtifact(visualinfo);
}
