const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

const Range = struct {
    offset: i64,
    src_start: i64,
    src_end: i64,
};

fn ascBySrcStart(_: void, a: Range, b: Range) bool {
    return a.src_start < b.src_start;
}

fn minFromRange(maps: *List(List(Range)), start: i64, end: i64, index: usize) i64 {
    assert(start < end);
    if (index >= maps.items.len) return start;

    var min: i64 = std.math.maxInt(i64);
    var i: usize = 0;
    const map = maps.items[index].items;
    while (i < map.len and map[i].src_end <= start) {
        i += 1;
    }

    var proc_start = start;
    while (i < map.len and proc_start < end) : (i += 1) {
        if (map[i].src_start > proc_start) {
            const range_end = @min(end, map[i].src_start);
            min = @min(min, minFromRange(maps, proc_start, range_end, index+1));
            proc_start = range_end;
        }
        if (map[i].src_start >= end) break;
        const overlap_start = @max(proc_start, map[i].src_start);
        const overlap_end = @min(end, map[i].src_end);
        assert(overlap_start < overlap_end);
        const dst_start = overlap_start + map[i].offset;
        const dst_end = overlap_end + map[i].offset;
        min = @min(min, minFromRange(maps, dst_start, dst_end, index+1));
        proc_start = overlap_end;
    } else {
        if (proc_start < end) {
            min = @min(min, minFromRange(maps, proc_start, end, index+1));
        }
    }
    
    assert(min != std.math.maxInt(i64));
    return min;
}

pub fn main() !void {
    var lines = splitSca(u8, data, '\n');
    var p1: i64 = std.math.maxInt(i64);
    var p2: i64 = std.math.maxInt(i64);
    var maps = List(List(Range)).init(gpa);
    const seeds_line = lines.next().?;
    _ = lines.next().?; // blank
    _ = lines.next().?; // seed-to-soil map
    maps.append(List(Range).init(gpa)) catch unreachable;
    while (lines.next()) |line| {
        if (line.len == 0) {
            if (lines.next()) |_| {
                maps.append(List(Range).init(gpa)) catch unreachable;
            }
            continue;
        }
        var parts = splitSca(u8, line, ' ');
        const dst_start = parseDec(parts.next().?);
        const src_start = parseDec(parts.next().?);
        const range = parseDec(parts.next().?);
        maps.items[maps.items.len-1].append(.{
            .offset = dst_start - src_start,
            .src_start = src_start,
            .src_end = src_start + range,
        }) catch unreachable;
    }

    for (maps.items) |*map| {
        sort(Range, map.items, {}, ascBySrcStart);
    }

    {
        var seeds_it = splitSca(u8, seeds_line, ' ');
        _ = seeds_it.next(); // "seeds:"
        while (seeds_it.next()) |seed_str| {
            var value = parseDec(seed_str);
            for (maps.items) |*map| {
                for (map.items) |range| {
                    if (range.src_start <= value and value < range.src_end) {
                        const orig = value;
                        value = orig + range.offset;
                        break;
                    }
                }
            }
            p1 = @min(p1, value);
        }
    }
    {
        var seeds_it = splitSca(u8, seeds_line, ' ');
        _ = seeds_it.next(); // "seeds:"
        while (seeds_it.next()) |seed_str| {
            const start = parseDec(seed_str);
            const len = parseDec(seeds_it.next().?);
            p2 = @min(p2, minFromRange(&maps, start, start + len, 0));
        }
    }

    print("p1: {}, p2: {}\n", .{p1, p2});
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
