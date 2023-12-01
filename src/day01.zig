const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

const numbers = [_][]const u8 { "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn main() !void {
    var lines = tokenizeAny(u8, data, "\r\n");
    var p1_sum: i64 = 0;
    var p2_sum: i64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var first_idx: ?usize = null;
        var first_val: ?i64 = null;
        var last_idx: ?usize = null;
        var last_val: ?i64 = null;
        for (line, 0..) |char, i| {
            if (char >= '0' and char <= '9') {
                if (first_idx == null) {
                    first_idx = i;
                    first_val = char - '0';
                }
                last_idx = i;
                last_val = char - '0';
            }
        }
        p1_sum += first_val.? * 10 + last_val.?;

        for (numbers, 1..) |str, i| {
            if (std.mem.indexOf(u8, line, str)) |idx| {
                if (idx < first_idx.?) {
                    first_idx = idx;
                    first_val = @intCast(i);
                }
                const last = std.mem.lastIndexOf(u8, line, str).?;
                if (last > last_idx.?) {
                    last_idx = last;
                    last_val = @intCast(i);
                }
            }
        }
        p2_sum += first_val.? * 10 + last_val.?;
    }
    std.debug.print("part1: {}, part2: {}\n", .{p1_sum, p2_sum});
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
