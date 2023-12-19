const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;
const Grid = util.Grid;
const Dir = util.Dir;

const data = @embedFile("data/day10.txt");

fn offset(pos: usize, dir: usize, pitch: usize) usize {
    return switch (dir) {
        .right => pos + 1,
        .up => pos - pitch,
        .left => pos - 1,
        .down => pos + pitch,
        else => unreachable,
    };
}

const starters = [_][3]u8{
    "7-J".*,
    "F|7".*,
    "L-F".*,
    "J|L".*,
};

pub fn main() !void {
    const g = try Grid.load(data, 1, '.');

    const start = indexOf(u8, g.cells, 'S').?;
    var pos = start;
    var dir: u2 = for (0..4) |d| {
        const moved = g.step(start, @intCast(d));
        if (indexOf(u8, &starters[d], g.cells[moved]) != null) {
            pos = moved;
            break @intCast(d);
        }
    } else unreachable;

    var ac = util.AreaCounter{};
    ac.edge(dir, 1);

    while (g.cells[pos] != 'S') {
        const bend = indexOf(u8, &starters[dir], g.cells[pos]).?;
        dir = @truncate(dir + bend + 3);
        pos = g.step(pos, dir);
        ac.edge(dir, 1);
    }

    const p1 = @divExact(ac.perimeter, 2);
    const p2 = ac.areaExclusive();

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
