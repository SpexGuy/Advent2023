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

const data = @embedFile("data/day17.txt");

const State = struct {
    pos: usize,
    dir: u2,
    moves: u8,
};

const Context = struct {
    g: Grid,
    min_moves: u8,
    max_moves: u8,

    pub fn isTerminal(c: *@This(), s: State) bool {
        return s.pos == c.g.botRight();
    }
    pub fn expand(c: *@This(), nc: NeighborCollector(State)) void {
        c.walkCrucible(nc, Dir.cw(nc.state.dir), c.min_moves, c.max_moves - c.min_moves);
        c.walkCrucible(nc, Dir.ccw(nc.state.dir), c.min_moves, c.max_moves - c.min_moves);
        if (nc.state.moves != 0) {
            c.walkCrucible(nc, nc.state.dir, 1, nc.state.moves - 1);
        }
    }

    fn walkCrucible(c: *@This(), nc: NeighborCollector(State), dir: u2, num_steps: u8, new_moves: u8) void {
        var pos = nc.state.pos;
        var cost: usize = 0;
        for (0..num_steps) |_| {
            pos = c.g.step(pos, dir);
            if (c.g.cells[pos] == '#') return;
            cost += (c.g.cells[pos] - '0');
        }
        nc.add(.{ .pos = pos, .dir = dir, .moves = new_moves }, cost);
    }
};

fn findBestPath(g: Grid, min_moves: u8, max_moves: u8) usize {
    var ctx: Context = .{ .g = g, .min_moves = min_moves, .max_moves = max_moves };
    const start_state: State = .{ .pos = g.topLeft(), .dir = Dir.right, .moves = max_moves };
    const result = util.search(State, Context, &ctx, start_state);
    return result.found_state.?.cost;
}

pub fn main() !void {
    const g = try Grid.load(data, 1, '#');

    const p1 = findBestPath(g, 1, 3);
    const p2 = findBestPath(g, 4, 10);

    print("p1: {}, p2: {}\n", .{ p1, p2 });
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
