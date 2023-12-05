const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

pub fn main() !void {
    var p1: usize = 0;
    var p2: usize = 0;
    var lines = tokenizeSca(u8, data, '\n');
    var cards = List(usize).init(gpa);
    while (lines.next()) |line| {
        var numbers = tokenizeAny(u8, line[4..], ": ");
        const id = parseInt(usize, numbers.next().?, 10) catch unreachable;
        _ = id;
        var items = std.BoundedArray(usize, 32){};
        while (numbers.next()) |nstr| {
            if (nstr[0] == '|') break;
            items.append(parseInt(usize, nstr, 10) catch unreachable) catch unreachable;
        }
        var matches: usize = 0;
        while (numbers.next()) |yourstr| {
            const yournum = parseInt(usize, yourstr, 10) catch unreachable;
            if (indexOf(usize, items.slice(), yournum)) |idx| {
                _ = items.swapRemove(idx);
                matches += 1;
            }
        }
        cards.append(matches) catch unreachable;
        if (matches > 0) {
            p1 += @as(usize, 1) << @intCast(matches-1);
        }
    }

    const copies = gpa.alloc(usize, cards.items.len) catch unreachable;
    @memset(copies, 1);
    for (cards.items, 0..) |score, i| {
        for (i+1..score+i+1) |j| {
            if (j >= copies.len) break;
            copies[j] += copies[i];
        }
    }

    for (copies) |num| {
        p2 += num;
    }

    std.debug.print("p1: {}, p2: {}\n", .{p1, p2});
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
