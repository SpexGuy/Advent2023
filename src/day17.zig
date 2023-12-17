const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day17.txt");

const right = 0;
const up = 1;
const left = 2;
const down = 3;

fn step(pos: usize, dir: u2, pitch: usize) usize {
    return switch (dir) {
        right => pos + 1,
        up => pos - pitch,
        left => pos - 1,
        down => pos + pitch,
    };
}

const State = struct {
    pos: usize,
    dir: u2,
    moves: u8,
};
const StateInfo = struct {
    cost: usize,
    prev: usize,
};

const StateCost = struct {
    state: State,
    cost: usize,
};

const IdCost = struct {
    id: usize,
    cost: usize,
};

const StateCosts = std.AutoArrayHashMap(State, StateInfo);
fn orderStates(_: void, a: IdCost, b: IdCost) std.math.Order {
    return std.math.order(a.cost, b.cost);
}

fn findBestPath(grid: []const u8, pitch: usize, min_moves: u8, max_moves: u8) !usize {
    const target_pos = grid.len - pitch - 3;
    var open = std.PriorityQueue(IdCost, void, orderStates).init(gpa, {});
    var states = StateCosts.init(gpa);
    try states.put(.{ .pos = pitch + 1, .dir = right, .moves = max_moves }, .{ .cost = 0, .prev = 0 });
    try open.add(.{ .id = 0, .cost = 0 });
    const best_state = while (true) {
        const state_id = open.remove();
        const state = states.keys()[state_id.id];
        const cost = states.values()[state_id.id].cost;
        if (cost != state_id.cost) continue; // dummy entry
        if (state.pos == target_pos) {
            break state_id.id;
        }

        var succs = std.BoundedArray(StateCost, 3){};
        if (walkCrucible(grid, pitch, state.pos, state.dir +% 1, min_moves, cost, max_moves - min_moves)) |succ| succs.append(succ) catch unreachable;
        if (walkCrucible(grid, pitch, state.pos, state.dir +% 3, min_moves, cost, max_moves - min_moves)) |succ| succs.append(succ) catch unreachable;
        if (state.moves != 0) {
            if (walkCrucible(grid, pitch, state.pos, state.dir, 1, cost, state.moves - 1)) |succ| succs.append(succ) catch unreachable;
        }

        for (succs.slice()) |ss| {
            const gop = try states.getOrPut(ss.state);
            if (!gop.found_existing or ss.cost < gop.value_ptr.cost) {
                gop.value_ptr.* = .{ .cost = ss.cost, .prev = state_id.id };
                try open.add(.{ .id = gop.index, .cost = ss.cost });
            }
        }
    };

    return states.values()[best_state].cost;
}

fn walkCrucible(grid: []const u8, pitch: usize, start_pos: usize, dir: u2, num_steps: usize, base_cost: usize, new_moves: u8) ?StateCost {
    var pos = start_pos;
    var cost = base_cost;
    for (0..num_steps) |_| {
        pos = step(pos, dir, pitch);
        if (grid[pos] == '#') return null;
        cost += (grid[pos] - '0');
    }
    return .{ .state = .{
        .pos = pos,
        .dir = dir,
        .moves = new_moves,
    }, .cost = cost };
}

pub fn main() !void {
    const width = indexOf(u8, data, '\n').?;
    const data_pitch = width + 1;
    const height = @divFloor(data.len + 1, data_pitch);
    const pitch = width + 3;
    const grid = try gpa.alloc(u8, pitch * (height + 2));
    @memset(grid, '#');
    for (0..height) |y| {
        @memcpy(grid[(y + 1) * pitch ..][1..][0..width], data[y * data_pitch ..][0..width]);
        grid[(y + 1) * pitch ..][width + 2] = '\n';
    }
    grid[width + 2] = '\n';
    grid[grid.len - 1] = '\n';

    const p1 = try findBestPath(grid, pitch, 1, 3);
    const p2 = try findBestPath(grid, pitch, 4, 10);

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
