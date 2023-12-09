const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    var p1: i64 = 0; _ = &p1;
    var p2: i64 = 0; _ = &p2;
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = tokenizeSca(u8, line, ' ');
        var sequence = List(i64).init(gpa);
        while (parts.next()) |part| {
            const num = parseDec(part);
            sequence.append(num) catch unreachable;
        }
        const prevnext = extrapolate(sequence.items);
        p1 += prevnext[1];
        p2 += prevnext[0];
    }

    print("p1: {}, p2: {}\n", .{p1, p2});
}

fn extrapolate(sequence: []const i64) [2]i64 {
    assert(sequence.len > 0);
    const deltas = gpa.alloc(i64, sequence.len - 1) catch unreachable;
    defer gpa.free(deltas);
    var has_nonzero = false;
    for (0..sequence.len-1) |i| {
        deltas[i] = sequence[i+1] - sequence[i];
        if (deltas[i] != 0) has_nonzero = true;
    }
    if (!has_nonzero) return .{sequence[0], sequence[sequence.len-1]};
    const prevnext = extrapolate(deltas);
    return .{
        sequence[0] - prevnext[0],
        sequence[sequence.len-1] + prevnext[1],
    };
}

fn parseDec(val: []const u8) i64 {
    return parseInt(i64, val, 10) catch |err| {
        print("Not a decimal number: '{s}' ({})\n", .{val, err});
        unreachable;
    };
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
