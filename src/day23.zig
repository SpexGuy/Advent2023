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

const data = @embedFile("data/day23.txt");

const gates = ">^<v";

const Edge = struct {
    len: usize,
    end: usize,
    reverse: bool = false,
};

const Junction = struct {
    edges: std.ArrayListUnmanaged(Edge) = .{},
    longest: ?usize = null,
};

const Graph = std.AutoArrayHashMap(usize, Junction);

fn followEdge(g: *Grid, in_pos: usize, in_dir: u2) struct { len: usize, pos: usize, dir: u2 } {
    var pos = in_pos;
    var dir = in_dir;
    var len: usize = 1;
    while (true) {
        len += 1;
        for ([_]u2{ dir, Dir.ccw(dir), Dir.cw(dir) }) |d| {
            const np = g.step(pos, d);
            switch (g.cells[np]) {
                '#' => {},
                '.' => {
                    pos = np;
                    dir = d;
                    break;
                },
                'E' => {
                    return .{
                        .len = len,
                        .pos = np,
                        .dir = d,
                    };
                },
                else => |c| {
                    assert(c == gates[d]);
                    return .{
                        .len = len + 1,
                        .pos = g.step(np, d),
                        .dir = d,
                    };
                },
            }
        } else unreachable;
    }
}

fn exploreMap(g: *Grid, graph: *Graph, pos: usize) usize {
    const gop = graph.getOrPut(pos) catch unreachable;
    if (gop.found_existing) {
        return gop.index;
    }
    gop.value_ptr.* = .{};
    for (0..4) |dir| {
        const indir = g.step(pos, @intCast(dir));
        if (g.cells[indir] == gates[dir]) {
            const info = followEdge(g, indir, @intCast(dir));
            const node = exploreMap(g, graph, info.pos);
            graph.values()[gop.index].edges.append(
                gpa,
                .{ .len = info.len, .end = node },
            ) catch unreachable;
            graph.values()[node].edges.append(
                gpa,
                .{ .len = info.len, .end = gop.index, .reverse = true },
            ) catch unreachable;
        }
    }

    return gop.index;
}

fn findLongestPath(vals: []Junction, node: usize) usize {
    if (vals[node].longest) |len| return len;

    var len: usize = 0;
    for (vals[node].edges.items) |edge| {
        if (!edge.reverse) {
            len = @max(len, findLongestPath(vals, edge.end) + edge.len);
        }
    }
    assert(len != 0);
    vals[node].longest = len;
    return len;
}

fn bit(node: usize) u64 {
    return @as(u64, 1) << @intCast(node);
}

fn findLongestPath2(vals: []Junction, node: usize, in_visited: u64) ?usize {
    if (node == 1) return 0;
    if (in_visited & bit(node) != 0) return null;
    const visited = in_visited | bit(node);
    var max: ?usize = null;
    for (vals[node].edges.items) |edge| {
        if (findLongestPath2(vals, edge.end, visited)) |len| {
            max = @max(max orelse 0, edge.len + len);
        }
    }
    return max;
}

pub fn main() !void {
    var g = try Grid.load(data, 1, '#');
    const start = g.topLeft() + 1;
    const end = g.botRight() - 1;
    g.cells[start] = 'v';
    g.cells[end] = 'E';

    var graph = Graph.init(gpa);
    graph.put(start, .{}) catch unreachable;
    graph.put(end, .{ .longest = 0 }) catch unreachable;
    const info = followEdge(&g, start + g.pitch, Dir.down);
    const node = exploreMap(&g, &graph, info.pos);
    graph.values()[0].edges.append(
        gpa,
        .{ .len = info.len, .end = node },
    ) catch unreachable;
    graph.values()[node].edges.append(
        gpa,
        .{ .len = info.len, .end = 0, .reverse = true },
    ) catch unreachable;

    const p1 = findLongestPath(graph.values(), 0);
    const p2 = findLongestPath2(graph.values(), 0, 0).?;
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
