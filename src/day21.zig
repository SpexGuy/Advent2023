const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;
const abs = util.abs;
const Grid = util.Grid;
const Dir = util.Dir;
const NeighborCollector = util.NeighborCollector;

const data = @embedFile("data/day21.txt");

const State = struct {
    pos: usize,
};

const Context = struct {
    g: *const Grid,
    distance: usize,

    pub fn isTerminal(c: *@This(), s: State) bool {
        _ = c;
        _ = s;
        return false;
    }
    pub fn expand(c: *@This(), nc: NeighborCollector(State)) void {
        if (nc.cost >= c.distance) return;
        for ([_]usize{
            nc.state.pos + 1,
            nc.state.pos - 1,
            nc.state.pos + c.g.pitch,
            nc.state.pos - c.g.pitch,
        }) |pos| {
            if (c.g.cells[pos] == '.') {
                nc.add(.{ .pos = pos }, 1);
            }
        }
    }
};

fn countSpots(g: *const Grid, start: usize, distance: usize) [2]usize {
    assert(g.cells[start] == '.');
    var ctx = Context{ .g = g, .distance = distance };
    const res = util.search(State, Context, &ctx, .{ .pos = start });
    var totals = [2]usize{ 0, 0 };
    for (res.states.values()) |info| {
        totals[info.cost & 1] += 1;
    }
    return totals;
}

pub fn main() !void {
    const g = try Grid.load(data, 1, '#');
    const pos = indexOf(u8, g.cells, 'S').?;
    g.cells[pos] = '.';
    const posxy = g.factor(pos);
    assert(posxy[0] == posxy[1]);
    assert(g.width == g.height);
    assert(g.width & 1 == 1);
    assert(posxy[0] == g.width / 2);
    const bigdist = 26501365;

    const p1 = countSpots(&g, pos, 64)[0];

    const out_parity = 1;
    const in_parity = 0;
    const end_parity = 0;
    const inside = (bigdist - posxy[0] - 1) % g.width;
    const incorner = inside - posxy[0] - 1;
    const outcorner = incorner + g.width;
    const gridlen = (bigdist - posxy[0] - 1) / g.width;

    assert(incorner & 1 == in_parity);
    assert(outcorner & 1 == out_parity);
    assert(inside & 1 == end_parity);
    const full = countSpots(&g, pos, 1000000000);
    const left = countSpots(&g, g.index(g.width - 1, posxy[1]), inside);
    const right = countSpots(&g, g.index(0, posxy[1]), inside);
    const up = countSpots(&g, g.index(posxy[0], 0), inside);
    const down = countSpots(&g, g.index(posxy[0], g.height - 1), inside);
    const tl_in = countSpots(&g, g.botRight(), incorner);
    const tl_out = countSpots(&g, g.botRight(), outcorner);
    const tr_in = countSpots(&g, g.botLeft(), incorner);
    const tr_out = countSpots(&g, g.botLeft(), outcorner);
    const bl_in = countSpots(&g, g.topRight(), incorner);
    const bl_out = countSpots(&g, g.topRight(), outcorner);
    const br_in = countSpots(&g, g.topLeft(), incorner);
    const br_out = countSpots(&g, g.topLeft(), outcorner);

    assert(gridlen & 1 == 1);

    var p2: usize = 0;
    const outer_parity_fulls = (gridlen + 1) * (gridlen + 1);
    const inner_parity_fulls = (gridlen * gridlen);
    p2 += outer_parity_fulls * full[0] + inner_parity_fulls * full[1];
    p2 += right[end_parity] + left[end_parity] + up[end_parity] + down[end_parity];
    p2 += (tl_out[out_parity] + bl_out[out_parity] + tr_out[out_parity] + br_out[out_parity]) * (gridlen);
    p2 += (tl_in[in_parity] + bl_in[in_parity] + tr_in[in_parity] + br_in[in_parity]) * (gridlen + 1);

    print("p1: {}, p2: {}\n", .{ p1, p2 });
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
