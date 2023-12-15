const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day15.txt");

fn hash(str: []const u8) usize {
    var h: usize = 0;
    for (str) |c| {
        h = ((h + c) * 17) & 0xFF;
    }
    return h;
}

pub fn main() !void {
    var p1: usize = 0;
    var p2: usize = 0;
    var lines = tokenizeAny(u8, data, ",\n");
    var lenses = std.StringArrayHashMap(usize).init(gpa);
    while (lines.next()) |line| {
        p1 += hash(line);
        if (line[line.len - 1] == '-') {
            const label = line[0 .. line.len - 1];
            _ = lenses.orderedRemove(label);
        } else {
            const sp = indexOf(u8, line, '=').?;
            const name = line[0..sp];
            const amt = parseDec(line[sp + 1 ..]);
            try lenses.put(name, amt);
        }
    }

    var positions = [_]usize{0} ** 256;
    for (lenses.keys(), lenses.values()) |name, foc| {
        const box = hash(name);
        const pos = positions[box];
        positions[box] += 1;
        p2 += (box + 1) * (pos + 1) * foc;
    }

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
