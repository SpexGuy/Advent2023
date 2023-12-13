const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");

pub fn main() !void {
    var p1: usize = 0;
    var p2: usize = 0;
    var grids = splitSeq(u8, data, "\n\n");
    while (grids.next()) |grid| {
        const width = indexOf(u8, grid, '\n').?;
        const pitch = width + 1;
        const height = @divFloor(grid.len + 1, pitch);
        for (0..height - 1) |y| {
            var errs: usize = 0;
            match: for (0..@min(y + 1, height - 1 - y)) |offset| {
                for (0..width) |x| {
                    if (grid[(y - offset) * pitch + x] != grid[(y + 1 + offset) * pitch + x]) {
                        errs += 1;
                        if (errs > 1) break :match;
                    }
                }
            } else {
                if (errs == 0) p1 += (y + 1) * 100;
                if (errs == 1) p2 += (y + 1) * 100;
            }
        }
        for (0..width - 1) |x| {
            var errs: usize = 0;
            match: for (0..@min(x + 1, width - 1 - x)) |offset| {
                for (0..height) |y| {
                    if (grid[y * pitch + x - offset] != grid[y * pitch + x + 1 + offset]) {
                        errs += 1;
                        if (errs > 1) break :match;
                    }
                }
            } else {
                if (errs == 0) p1 += (x + 1);
                if (errs == 1) p2 += (x + 1);
            }
        }
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
