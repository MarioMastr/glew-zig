const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glew = b.addLibrary(.{
        .name = "glew",
        .linkage = if (target.result.os.tag == .windows) .dynamic else .static, // windows sucks
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

    switch (target.result.os.tag) {
        .windows => {
            glew.root_module.linkSystemLibrary("opengl32", .{ .needed = true, });
            glewinfo.root_module.linkSystemLibrary("opengl32", .{ .needed = true, });
            visualinfo.root_module.linkSystemLibrary("opengl32", .{ .needed = true, });

            glew.root_module.linkSystemLibrary("gdi32", .{ .needed = true, });
            glewinfo.root_module.linkSystemLibrary("gdi32", .{ .needed = true, });
            visualinfo.root_module.linkSystemLibrary("gdi32", .{ .needed = true, });

            glew.root_module.linkSystemLibrary("glu32", .{ .needed = true, });
            glewinfo.root_module.linkSystemLibrary("glu32", .{ .needed = true, });
            visualinfo.root_module.linkSystemLibrary("glu32", .{ .needed = true, });
        },
        .linux => {
            glew.root_module.addSystemIncludePath(.{.cwd_relative = "/usr/include"});
            glew.root_module.linkSystemLibrary("EGL", .{ .needed = true, });
        },
        .macos => {
            glew.root_module.linkFramework("OpenGL", .{ .needed = true, });
        },
        else => {},
    }

    // Link glew
    glewinfo.root_module.linkLibrary(glew);
    visualinfo.root_module.linkLibrary(glew);

    // Link C files
    glew.linkLibC();
    glewinfo.linkLibC();
    visualinfo.linkLibC();

    // Include "include/"
    glew.addIncludePath(b.path("include"));
    glewinfo.addIncludePath(b.path("include"));
    visualinfo.addIncludePath(b.path("include"));

    // Enable static library mode
    if (glew.linkage == .static)
        glew.root_module.addCMacro("GLEW_STATIC", "1");

    glew.installHeadersDirectory(b.path("include/GL"), "GL", .{});

    b.installArtifact(glew);
    b.installArtifact(glewinfo);
    b.installArtifact(visualinfo);
}
