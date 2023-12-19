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
const NeighborCollector = util.NeighborCollector;

const data = @embedFile("data/day21.txt");

const State = struct {

};

const Context = struct {

    pub fn isTerminal(c: *@This(), s: State) bool {
        _ = c;
        _ = s;
        return false;
    }
    pub fn expand(c: *@This(), nc: NeighborCollector(State)) void {
        _ = c;
        _ = nc;
    }
};

pub fn main() !void {
    var p1: usize = 0; _ = &p1;
    var p2: usize = 0; _ = &p2;
    // const g = try Grid.load(data, 1, '#');
    var lines = splitSca(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;

    }

    print("p1: {}, p2: {}\n", .{p1, p2});
}

fn parseDec(comptime T: type, val: []const u8) T {
    return parseInt(T, val, 10) catch unreachable;
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
