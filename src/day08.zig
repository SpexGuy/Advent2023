const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const State = [3]u8;

const data2 =
\\LR
\\
\\11A = (11B, XXX)
\\11B = (XXX, 11Z)
\\11Z = (11B, XXX)
\\22A = (22B, XXX)
\\22B = (22C, 22C)
\\22C = (22Z, 22Z)
\\22Z = (22B, 22B)
\\XXX = (XXX, XXX)
;

const Iterator = struct {
    phase: usize,
    period: usize,
    offsets: []const usize,
};

const IterState = struct {
    state: State,
    move: u32,
};

fn setupIterator(it: *Iterator, start_state: State, moves: []const u8, map: Map(State, [2]State)) void {
    var seen = Map(IterState, usize).init(gpa);
    defer seen.deinit();
    
    var steps: usize = 0;
    var state = start_state;
    var move: u32 = 0;
    while (true) {
        steps += 1;
        const dir = moves[move];
        move += 1; if (move == moves.len) move = 0;
        const idx: usize = if (dir == 'L') 0 else 1;
        const pair = map.get(state).?;
        state = pair[idx];

        if (state[2] == 'Z') {
            const gop = seen.getOrPut(.{ .state = state, .move = move }) catch unreachable;
            if (!gop.found_existing) {
                gop.value_ptr.* = steps;
            } else {
                const phase = gop.value_ptr.*;
                const period = steps - phase;
                var offsets = List(usize).init(gpa);
                var sit = seen.valueIterator();
                while (sit.next()) |value_ptr| {
                    if (value_ptr.* >= phase) {
                        offsets.append(value_ptr.*) catch unreachable;
                    }
                }
                sort(usize, offsets.items, {}, std.sort.asc(usize));
                for (0..offsets.items.len-1) |i| {
                    offsets.items[i] = offsets.items[i+1] - offsets.items[i];
                }
                offsets.items[offsets.items.len-1] = steps - offsets.items[offsets.items.len-1];
                it.phase = phase;
                it.period = period;
                it.offsets = offsets.toOwnedSlice() catch unreachable;
                print("Iterator for {s} set up with phase {}, period {}, {} offsets\n", .{start_state, it.phase, it.period, it.offsets.len});
                return;
            }
        }
    }
}

pub fn main() !void {
    var map = Map(State, [2]State).init(gpa);

    var p1: i64 = 0; _ = &p1;
    var lines = tokenizeSca(u8, data, '\n');
    const moves = lines.next().?;
    var states = List(State).init(gpa);

    while (lines.next()) |line| {
        const from = line[0..3].*;
        const left = line[7..10].*;
        const right = line[12..15].*;
        assert(line.len == 16);
        try map.put(from, .{left, right});
        if (from[2] == 'A') try states.append(from);
    }

    var p2: usize = 1;
    const iters = try gpa.alloc(Iterator, states.items.len);
    for (iters, states.items) |*it, state| {
        setupIterator(it, state, moves, map);
        p2 = util.lcm(p2, it.period);
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
