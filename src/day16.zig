const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day16.txt");
const data2 =
    \\.|...\....
    \\|.-.\.....
    \\.....|-...
    \\........|.
    \\..........
    \\.........\
    \\..../.\\..
    \\.-.-/..|..
    \\.|....-|.\
    \\..//.|....
;

const right = 0;
const up = 1;
const left = 2;
const down = 3;

fn step(pos: usize, dir: u2, pitch: usize) usize {
    return switch (dir) {
        right => pos + 1,
        up => pos - pitch,
        left => pos - 1,
        down => pos + pitch,
    };
}

fn walkBeam(grid: []const u8, light: []u8, pitch: usize, in_pos: usize, in_dir: u2) void {
    var pos = in_pos;
    var dir = in_dir;
    while (true) {
        // Check if we already walked this path
        const bit = @as(u8, 1) << @intCast(dir);
        if (light[pos] & bit != 0 or grid[pos] == '#') return;
        light[pos] |= bit;

        const cell = grid[pos];
        switch (cell) {
            '/' => {
                dir = switch (dir) {
                    right => up,
                    up => right,
                    down => left,
                    left => down,
                };
            },
            '\\' => {
                dir = switch (dir) {
                    right => down,
                    down => right,
                    left => up,
                    up => left,
                };
            },
            '|' => {
                if (dir == left or dir == right) {
                    dir = up;
                    walkBeam(grid, light, pitch, pos + pitch, down);
                }
            },
            '-' => {
                if (dir == up or dir == down) {
                    dir = left;
                    walkBeam(grid, light, pitch, pos + 1, right);
                }
            },
            '.' => {},
            else => unreachable,
        }
        pos = step(pos, dir, pitch);
    }
}

fn countEnergized(light: []const u8) i64 {
    var num: i64 = 0;
    for (light) |dirs| {
        if (dirs != 0) num += 1;
    }
    return num;
}

pub fn main() !void {
    var p1: i64 = 0;
    var p2: i64 = 0;
    const width = indexOf(u8, data, '\n').?;
    const data_pitch = width + 1;
    const height = @divFloor(data.len + 1, data_pitch);
    const pitch = width + 3;
    const grid = try gpa.alloc(u8, pitch * (height + 2));
    @memset(grid, '#');
    for (0..height) |y| {
        @memcpy(grid[(y + 1) * pitch ..][1..][0..width], data[y * data_pitch ..][0..width]);
        grid[(y + 1) * pitch ..][width + 2] = '\n';
    }
    grid[width + 2] = '\n';
    grid[grid.len - 1] = '\n';

    const light = try gpa.alloc(u8, grid.len);

    for (0..height) |y| {
        @memset(light, 0);
        walkBeam(grid, light, pitch, (y + 1) * pitch + 1, right);
        const count = countEnergized(light);
        p2 = @max(p2, count);
        if (y == 0) p1 = count;

        @memset(light, 0);
        walkBeam(grid, light, pitch, (y + 1) * pitch + width, left);
        p2 = @max(p2, countEnergized(light));
    }
    for (0..width) |x| {
        @memset(light, 0);
        walkBeam(grid, light, pitch, pitch + 1 + x, down);
        p2 = @max(p2, countEnergized(light));

        @memset(light, 0);
        walkBeam(grid, light, pitch, grid.len - 2 * pitch + 1 + x, up);
        p2 = @max(p2, countEnergized(light));
    }

    print("p1: {}, p2: {}\n", .{ p1, p2 });
}

fn parseDec(val: []const u8) i64 {
    return parseInt(i64, val, 10) catch unreachable;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
