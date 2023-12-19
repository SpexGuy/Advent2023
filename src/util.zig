const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

// Add utility functions here
pub const Grid = struct {
    cells: []u8,
    pitch: usize,
    width: usize,
    height: usize,
    padding: usize,

    pub fn load(data: []const u8, padding: usize, pad_char: u8) !Grid {
        const width = indexOf(u8, data, '\n').?;
        const data_pitch = width + 1;
        const height = @divFloor(data.len + 1, data_pitch);
        const pitch = width + 2 * padding + 1;
        const cells = try gpa.alloc(u8, pitch * (height + 2 * padding));
        @memset(cells, pad_char);
        for (0..height) |y| {
            @memcpy(cells[(y + padding) * pitch ..][padding..][0..width], data[y * data_pitch ..][0..width]);
            cells[(y + padding) * pitch ..][padding + width + padding] = '\n';
        }
        for (0..padding) |i| {
            cells[i * pitch + padding + width + padding] = '\n';
            cells[cells.len - i * pitch - 1] = '\n';
        }

        return .{
            .cells = cells,
            .pitch = pitch,
            .width = width,
            .height = height,
            .padding = padding,
        };
    }

    pub fn topLeft(g: *const Grid) usize {
        return g.padding * g.pitch + g.padding;
    }
    pub fn topRight(g: *const Grid) usize {
        return g.topLeft() + g.width - 1;
    }
    pub fn botLeft(g: *const Grid) usize {
        return g.pitch * (g.padding + g.height - 1) + g.padding;
    }
    pub fn botRight(g: *const Grid) usize {
        return g.botLeft() + g.width - 1;
    }

    pub fn step(g: *const Grid, pos: usize, dir: u2) usize {
        return g.walk(pos, dir, 1);
    }
    pub fn walk(g: *const Grid, pos: usize, dir: u2, steps: usize) usize {
        return switch (dir) {
            Dir.right => pos + steps,
            Dir.up => pos - g.pitch * steps,
            Dir.left => pos - steps,
            Dir.down => pos + g.pitch * steps,
        };
    }
};

pub const Dir = opaque {
    pub const right: u2 = 0;
    pub const up: u2 = 1;
    pub const left: u2 = 2;
    pub const down: u2 = 3;

    pub const east: u2 = right;
    pub const north: u2 = up;
    pub const west: u2 = left;
    pub const south: u2 = down;

    pub fn flip(dir: u2) u2 {
        return dir +% 2;
    }
    pub fn cw(dir: u2) u2 {
        return dir +% 3;
    }
    pub fn ccw(dir: u2) u2 {
        return dir +% 1;
    }
};

test "Grid" {
    var g = try Grid.load(
        \\v.<
        \\...
        \\>.^
    , 2, '#');
    try std.testing.expectEqualStrings(
        \\#######
        \\#######
        \\##v.<##
        \\##...##
        \\##>.^##
        \\#######
        \\#######
        \\
    , g.cells);
    try std.testing.expectEqual(@as(usize, 3), g.width);
    try std.testing.expectEqual(@as(usize, 3), g.height);
    try std.testing.expectEqual(@as(u8, 'v'), g.cells[g.topLeft()]);
    try std.testing.expectEqual(@as(u8, '<'), g.cells[g.topRight()]);
    try std.testing.expectEqual(@as(u8, '>'), g.cells[g.botLeft()]);
    try std.testing.expectEqual(@as(u8, '^'), g.cells[g.botRight()]);
}

pub const StateInfo = struct {
    cost: usize,
    prev: usize,
};

pub const StateCost = struct {
    id: usize,
    cost: usize,

    pub fn order(_: void, a: StateCost, b: StateCost) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

pub const OpenQueue = std.PriorityQueue(StateCost, void, StateCost.order);

pub fn SearchResult(comptime State: type) type {
    return struct {
        states: std.AutoArrayHashMap(State, StateInfo),
        found_state: ?StateCost,

        pub fn shortestPathTo(self: @This(), end: usize) []usize {
            var arr = List(usize).init(gpa);
            arr.append(end) catch unreachable;
            var state = end;
            while (state != 0) {
                state = self.states.values()[state].prev;
                arr.append(state) catch unreachable;
            }
            std.mem.reverse(usize, arr.items);
            return arr.toOwnedSlice() catch unreachable;
        }
    };
}

pub fn NeighborCollector(comptime State: type) type {
    return struct {
        state: State,
        id: usize,
        cost: usize,
        states: *std.AutoArrayHashMap(State, StateInfo),
        open: *OpenQueue,

        pub fn add(nc: *const @This(), successor: State, addl_cost: usize) void {
            const cost = nc.cost + addl_cost;
            const gop = nc.states.getOrPut(successor) catch unreachable;
            if (!gop.found_existing or cost < gop.value_ptr.cost) {
                gop.value_ptr.* = .{ .cost = cost, .prev = nc.id };
                nc.open.add(.{ .id = gop.index, .cost = cost }) catch unreachable;
            }
        }
    };
}

const ExampleContext = struct {
    target: i64 = 47,

    pub fn expand(_: *@This(), nc: NeighborCollector(i64)) void {
        nc.add(nc.state + 10, 3);
        nc.add(nc.state + 1, 1);
        nc.add(nc.state - 4, 2);
    }

    pub fn isTerminal(ctx: *@This(), state: i64) bool {
        return state == ctx.target;
    }
};

pub fn search(comptime State: type, comptime Context: type, ctx: *Context, start: State) SearchResult(State) {
    var open = OpenQueue.init(gpa, {});
    var states = std.AutoArrayHashMap(State, StateInfo).init(gpa);
    states.put(start, .{ .cost = 0, .prev = 0 }) catch unreachable;
    open.add(.{ .id = 0, .cost = 0 }) catch unreachable;
    const found_state: ?StateCost = while (open.removeOrNull()) |state_id| {
        const state = states.keys()[state_id.id];
        const cost = states.values()[state_id.id].cost;
        if (cost != state_id.cost) continue; // dummy entry
        if (ctx.isTerminal(state)) break state_id;

        const nc: NeighborCollector(State) = .{
            .state = state,
            .id = state_id.id,
            .cost = cost,
            .states = &states,
            .open = &open,
        };
        ctx.expand(nc);
    } else null;

    return .{
        .states = states,
        .found_state = found_state,
    };
}

test "search" {
    var ctx = ExampleContext{ .target = 47 };
    var result = search(i64, ExampleContext, &ctx, 0);
    try std.testing.expect(result.found_state != null);
    try std.testing.expectEqual(@as(i64, 47), result.states.keys()[result.found_state.?.id]);
    try std.testing.expectEqual(@as(usize, 18), result.found_state.?.cost);
    // print("\n[", .{});
    // for (result.shortestPathTo(result.found_state.?.id)) |id| {
    //     if (id != 0) print(",", .{});
    //     print("({}, {})", .{result.states.keys()[id], result.states.values()[id].cost});
    // }
    // print("]\n", .{});
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
