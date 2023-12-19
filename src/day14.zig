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

const data = @embedFile("data/day14.txt");

fn tilt(grid: []u8, base: usize, across_delta: usize, across_num: usize, along_delta: isize, along_num: usize) void {
    var line_base = base;
    for (0..across_num) |_| {
        line_base += across_delta;
        var index = line_base;
        assert(grid[index] == '#');
        var last_square_pos = index;
        for (0..along_num) |_| {
            index = @intCast(@as(isize, @intCast(index)) + along_delta);
            if (grid[index] == 'O') {
                var sp: usize = @intCast(@as(isize, @intCast(last_square_pos)) + along_delta);
                while (sp != index) : (sp = @intCast(@as(isize, @intCast(sp)) + along_delta)) {
                    if (grid[sp] == '.') {
                        grid[sp] = 'O';
                        grid[index] = '.';
                        break;
                    }
                }
            } else if (grid[index] == '#') {
                last_square_pos = index;
            }
        }
    }
}

fn spin(g: Grid) void {
    // Move the rocks north
    tilt(g.cells, 0, 1, g.width, @intCast(g.pitch), g.height);
    // west
    tilt(g.cells, 0, g.pitch, g.height, 1, g.width);
    // south
    tilt(g.cells, g.cells.len - g.pitch, 1, g.width, -@as(isize, @intCast(g.pitch)), g.height);
    // east
    tilt(g.cells, g.width + 1, g.pitch, g.height, -1, g.width);
}

fn calcWeight(g: Grid) usize {
    var total: usize = 0;
    for (g.cells, 0..) |c, i| {
        if (c == 'O') {
            const weight = g.height + 1 - i / g.pitch;
            total += weight;
        }
    }
    return total;
}

pub fn main() !void {
    const g = try Grid.load(data, 1, '#');

    const gp1 = g.dupe();
    tilt(gp1.cells, 0, 1, gp1.width, @intCast(gp1.pitch), gp1.height);
    const p1 = calcWeight(gp1);

    var known_states = StrMap(usize).init(gpa);
    var num_spins: usize = 0;

    const from, const to = while (true) {
        spin(g);
        num_spins += 1;
        const copy = try gpa.dupe(u8, g.cells);
        const gop = try known_states.getOrPut(copy);
        if (gop.found_existing) {
            break .{ gop.value_ptr.*, num_spins };
        } else {
            gop.value_ptr.* = num_spins;
        }
    };

    const end = (1000000000 - from) % (to - from) + from;

    var it = known_states.iterator();
    const final_grid = while (it.next()) |ent| {
        if (ent.value_ptr.* == end) {
            break ent.key_ptr.*;
        }
    } else unreachable;

    var gp2 = g;
    gp2.cells = util.constCast(final_grid);
    const p2 = calcWeight(gp2);

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
