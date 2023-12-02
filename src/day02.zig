const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() !void {
    var p1: i64 = 0;
    var p2: i64 = 0;
    var lines = tokenizeAny(u8, data, "\r\n");
    while (lines.next()) |line| {
        var red: i64 = 0;
        var green: i64 = 0;
        var blue: i64 = 0;
        var toks = tokenizeAny(u8, line[5..], ": ,;");
        const id = try parseInt(i64, toks.next().?, 10);
        while (toks.next()) |num_s| {
            const num = try parseInt(i64, num_s, 10);
            const color = toks.next().?;
            if (std.mem.eql(u8, color, "red")) {
                red = @max(red, num);
            } else if (std.mem.eql(u8, color, "green")) {
                green = @max(green, num);
            } else if (std.mem.eql(u8, color, "blue")) {
                blue = @max(blue, num);
            }
        }
        if (red <= 12 and green <= 13 and blue <= 14) {
            p1 += id;
        }
        p2 += red * blue * green;
    }
    std.debug.print("part1: {}, part2: {}\n", .{p1, p2});
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
