const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");

pub fn main() !void {
    var lines = splitSca(u8, data, '\n');
    const width = indexOf(u8, data, '\n').?;
    var coords = List([2]usize).init(gpa);
    var height: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var base: usize = 0;
        while (indexOf(u8, line[base..], '#')) |offset| {
            try coords.append(.{ base + offset, height });
            base += offset + 1;
        }

        height += 1;
    }

    var used_x = try BitSet.initEmpty(gpa, width);
    var used_y = try BitSet.initEmpty(gpa, height);
    for (coords.items) |coord| {
        used_x.set(coord[0]);
        used_y.set(coord[1]);
    }

    const p1_map_x = try mapValues(used_x, 2);
    const p1_map_y = try mapValues(used_y, 2);
    const p2_map_x = try mapValues(used_x, 1000000);
    const p2_map_y = try mapValues(used_y, 1000000);

    var p1: usize = 0;
    var p2: usize = 0;
    for (coords.items[0 .. coords.items.len - 1], 0..) |a, i| {
        for (coords.items[i + 1 ..]) |b| {
            p1 += absDiff(p1_map_x[a[0]], p1_map_x[b[0]]) + absDiff(p1_map_y[a[1]], p1_map_y[b[1]]);
            p2 += absDiff(p2_map_x[a[0]], p2_map_x[b[0]]) + absDiff(p2_map_y[a[1]], p2_map_y[b[1]]);
        }
    }

    print("p1: {}, p2: {}\n", .{ p1, p2 });
}

fn mapValues(used: BitSet, expansion: usize) ![]usize {
    const map = try gpa.alloc(usize, used.unmanaged.bit_length);
    var mapped: usize = 0;
    for (map, 0..) |*c, i| {
        if (!used.isSet(i)) {
            mapped += expansion - 1;
        }
        c.* = mapped;
        mapped += 1;
    }
    return map;
}

fn absDiff(a: usize, b: usize) usize {
    return @intCast(@abs(@as(isize, @intCast(a)) - @as(isize, @intCast(b))));
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
