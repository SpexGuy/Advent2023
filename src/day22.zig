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

const data = @embedFile("data/day22.txt");

const Brick = struct {
    min_end: [3]usize,
    axis: usize,
    len: usize,
    resting_z: usize = 0,
    supported_by: std.ArrayListUnmanaged(usize) = .{},
};

const default_slice = [_][10]u16{[_]u16{0xffff} ** 10} ** 10;
pub fn main() !void {
    var bricks = List(Brick).init(gpa);
    var tower = List([10][10]u16).init(gpa);
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        var parts = tokenizeAny(u8, line, ",~");
        const a: [3]usize = .{
            parseDec(usize, parts.next().?),
            parseDec(usize, parts.next().?),
            parseDec(usize, parts.next().?),
        };
        const b: [3]usize = .{
            parseDec(usize, parts.next().?),
            parseDec(usize, parts.next().?),
            parseDec(usize, parts.next().?),
        };
        const axis: usize = for (0..3) |i| {
            if (a[i] != b[i]) break i;
        } else 0;
        const len = util.absDiff(a[axis], b[axis]) + 1;
        bricks.append(.{
            .min_end = .{
                @min(a[0], b[0]),
                @min(a[1], b[1]),
                @min(a[2], b[2]),
            },
            .axis = axis,
            .len = len,
        }) catch unreachable;
    }

    const brick_order = try gpa.alloc(u16, bricks.items.len);
    for (brick_order, 0..) |*bo, i| bo.* = @intCast(i);
    const SortContext = struct {
        bricks: []const Brick,

        fn sortAsc(ctx: @This(), a: u16, b: u16) bool {
            return ctx.bricks[a].min_end[2] < ctx.bricks[b].min_end[2];
        }
    };
    const ctx = SortContext{ .bricks = bricks.items };
    sort(u16, brick_order, ctx, SortContext.sortAsc);
    for (brick_order) |bid| {
        const brick = &bricks.items[bid];
        var z = @min(tower.items.len, brick.min_end[2]);
        while (z > 0) : (z -= 1) {
            const below = z - 1;
            const axis: usize, const len: usize =
                if (brick.axis == 2) .{ 0, 1 } else .{ brick.axis, brick.len };
            var pos: [2]usize = .{ brick.min_end[0], brick.min_end[1] };
            const slice = &tower.items[below];
            var resting: bool = false;
            for (0..len) |_| {
                const cell = slice[pos[1]][pos[0]];
                if (cell != 0xffff) {
                    resting = true;
                    if (brick.supported_by.items.len == 0 or brick.supported_by.items[brick.supported_by.items.len - 1] != cell) {
                        brick.supported_by.append(gpa, cell) catch unreachable;
                    }
                }
                pos[axis] += 1;
            }
            if (resting) break;
        }
        brick.resting_z = z;
        var pos = brick.min_end;
        pos[2] = z;
        for (0..brick.len) |_| {
            if (pos[2] == tower.items.len) {
                tower.append(default_slice) catch unreachable;
            }
            assert(tower.items.len > pos[2]);
            tower.items[pos[2]][pos[1]][pos[0]] = bid;
            pos[brick.axis] += 1;
        }
    }

    var p1: usize = 0;
    var p2: usize = 0;
    var falling = try std.DynamicBitSet.initEmpty(gpa, bricks.items.len);
    for (0..bricks.items.len) |bid| {
        falling.unmanaged.unsetAll();
        assert(falling.count() == 0);
        falling.set(bid);
        var progress = true;
        while (progress) {
            progress = false;
            for (0..bricks.items.len) |cid| {
                if (falling.isSet(cid)) continue;
                for (bricks.items[cid].supported_by.items) |support| {
                    if (!falling.isSet(support)) {
                        break;
                    }
                } else if (bricks.items[cid].supported_by.items.len > 0) {
                    falling.set(cid);
                    progress = true;
                }
            }
        }
        const num = falling.count();
        if (num == 1) {
            p1 += 1;
        } else {
            p2 += num - 1;
        }
    }

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
