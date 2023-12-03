const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");
const test_data =
\\..........
\\467..114..
\\...*......
\\..35..633.
\\......#...
\\617*......
\\.....+.58.
\\..592.....
\\.......755
\\...$..*...
\\.664.598..
\\
;
pub fn main() !void {
    var gear_map = Map(usize, usize).init(gpa);
    var p1: usize = 0;
    var p2: usize = 0;
    std.debug.print("pitch={}\n", .{pitch});
    //const width = if (data[pitch-1] == '\r') pitch-1 else pitch;
    var val: ?i64 = null;
    var val_start: ?usize = null;
    for (data, 0..) |char, i| {
        if (std.ascii.isDigit(char)) {
            if (val_start == null) val_start = i;
            val = (if (val) |v| v * 10 else 0) + (char - '0');
        } else if (val_start) |start| {
            var symbol: ?usize = null;
            for (start-1..i+1) |j| {
                const above = if (j >= pitch) j - pitch else j;
                const along = j;
                const below = if (j + pitch < data.len) j + pitch else j;
                if (data[above] != '.' and data[above] != '\n' and data[above] != '\r' and !std.ascii.isDigit(data[above])) {
                    symbol = above;
                    break;
                }
                if (data[along] != '.' and data[along] != '\n' and data[along] != '\r' and !std.ascii.isDigit(data[along])) {
                    symbol = along;
                    break;
                }
                if (data[below] != '.' and data[below] != '\n' and data[below] != '\r' and !std.ascii.isDigit(data[below])) {
                    symbol = below;
                    break;
                }
            }
            if (symbol) |s| {
                const newval = parseInt(usize, data[start..i], 10) catch unreachable;
                p1 += newval;
                if (data[s] == '*') {
                    const gop = try gear_map.getOrPut(s);
                    if (gop.found_existing) {
                        p2 += gop.value_ptr.* * newval;
                        _ = gear_map.remove(s);
                    } else {
                        gop.value_ptr.* = newval;
                    }
                }
            }
            val_start = null;
            val = null;
        }
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
