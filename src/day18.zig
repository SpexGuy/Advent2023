const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;
const Dir = util.Dir;

const data = @embedFile("data/day18.txt");

pub fn main() !void {
    var p1_ac = util.AreaCounter{};
    var p2_ac = util.AreaCounter{};

    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = tokenizeAny(u8, line, " (#)");
        const dir1: u2 = @intCast(indexOf(u8, "RULD", parts.next().?[0]).?);
        const dist1 = parseDec(parts.next().?);
        const color = parts.next().?;
        const dir2: u2 = @intCast(indexOf(u8, "0321", color[color.len - 1]).?);
        const dist2 = try parseInt(usize, color[0 .. color.len - 1], 16);

        p1_ac.edge(dir1, dist1);
        p2_ac.edge(dir2, dist2);
    }

    const p1 = p1_ac.areaInclusive();
    const p2 = p2_ac.areaInclusive();

    print("p1: {}, p2: {}\n", .{ p1, p2 });
}

fn parseDec(val: []const u8) usize {
    return parseInt(usize, val, 10) catch unreachable;
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
