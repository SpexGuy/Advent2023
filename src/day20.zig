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

const data = @embedFile("data/day20.txt");

const Level = enum(u1) { low, high };

const Pulse = struct {
    level: Level,
    source: u16,
    target: u16,
};

const Pred = struct {
    node: u16,
    state: Level = .low,
};

const Node = struct {
    ty: enum { ff, conj } = undefined,
    state_idx: usize = undefined,
    preds: std.BoundedArray(u16, 16) = .{},
    followers: std.BoundedArray(u16, 8) = .{},

    pub fn process(self: @This(), states: *BitSet, level: Level, source: u16) ?Level {
        switch (self.ty) {
            .ff => {
                if (level == .low) {
                    states.toggle(self.state_idx);
                    return if (states.isSet(self.state_idx)) Level.high else Level.low;
                }
                return null;
            },
            .conj => {
                const pi = indexOf(u16, self.preds.slice(), source).?;
                states.setValue(self.state_idx + pi, level == .high);
                for (0..self.preds.len) |i| {
                    if (!states.isSet(self.state_idx + i)) return Level.high;
                }
                return Level.low;
            },
        }
    }
};

fn addPred(nodes: *std.AutoArrayHashMap(u16, Node), pred: u16, dest: u16) void {
    const gop = nodes.getOrPut(dest) catch unreachable;
    if (!gop.found_existing) gop.value_ptr.* = .{};
    if (indexOf(u16, gop.value_ptr.preds.slice(), pred) == null) {
        gop.value_ptr.preds.append(pred) catch unreachable;
    }
}

const broadcast_no = nameof("!!");

pub fn main() !void {
    var lines = splitSca(u8, data, '\n');
    var nodes = std.AutoArrayHashMap(u16, Node).init(gpa);
    var broadcast = List(u16).init(gpa);
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var parts = tokenizeAny(u8, line, " ->,");
        const name = parts.next().?;
        if (std.mem.eql(u8, name, "broadcaster")) {
            while (parts.next()) |s| {
                const dest = nameof(s);
                try broadcast.append(dest);
                addPred(&nodes, broadcast_no, dest);
            }
        } else {
            const src = nameof(name[1..]);
            const idx = blk: {
                const gop = try nodes.getOrPut(src);
                if (!gop.found_existing) gop.value_ptr.* = .{};
                gop.value_ptr.ty = switch (name[0]) {
                    '%' => .ff,
                    '&' => .conj,
                    else => unreachable,
                };
                break :blk gop.index;
            };
            while (parts.next()) |s| {
                const dest = nameof(s);
                nodes.values()[idx].followers.append(dest) catch unreachable;
                addPred(&nodes, src, dest);
            }
        }
    }

    // Now assign slots
    var total_bits: usize = 0;
    for (nodes.values()) |*node| {
        node.state_idx = total_bits;
        total_bits += switch (node.ty) {
            .ff => 1,
            .conj => node.preds.len,
        };
    }

    var state = try BitSet.initEmpty(gpa, total_bits);
    var pulses = List(Pulse).init(gpa);
    var lows: usize = 0;
    var highs: usize = 0;
    for (0..4000) |_| {
        lows += 1; // button
        for (broadcast.items) |b| {
            try pulses.append(.{ .level = .low, .source = broadcast_no, .target = b });
        }
        var i: usize = 0;
        while (i < pulses.items.len) : (i += 1) {
            const pulse = pulses.items[i];
            if (pulse.level == .low) lows += 1 else highs += 1;
            const node: *Node = nodes.getPtr(pulse.target).?;
            if (node.process(&state, pulse.level, pulse.source)) |send| {
                for (node.followers.slice()) |f| {
                    if (f == nameof("rx")) break;
                    try pulses.append(.{ .level = send, .source = pulse.target, .target = f });
                }
            }
        }
        pulses.items.len = 0;
    }
    const p1 = lows * highs;

    // We're going to make some assumptions about the graph structure
    // Each child of the broadcaster node is the start of a unique chain of flip flops.
    // A chain of flip-flops behaves like a ripple-carry incrementing register.
    // For each chain of flip flops, there is one conj node which observes some of the
    // bits in the chain. When this conj node fires, it triggers each of the nodes in
    // the chain which are *not* observed, as well as the first node in the chain.
    // What this does, in effect, is set the entire chain to 1 and then add 1 to it,
    // which resets it back to zero. So the conj node fires low once every N presses,
    // where N is the sum of the observed bits. Each of these conj nodes is connected
    // to a second conj node, which only observes its parent. This functions as a not
    // gate, and fires high once every N presses. Each of those is then connected to
    // a conj gate which fires rx, the node under inspection.
    // So the rx node will receive a low signal when all chains overlap, the lcm of the Ns.
    var p2: usize = 1;
    for (broadcast.items) |root| {
        var bit: usize = 1;
        var num: usize = 0;
        var curr = root;
        while (true) {
            var next: ?u16 = null;
            for (nodes.getPtr(curr).?.followers.slice()) |f| {
                switch (nodes.getPtr(f).?.ty) {
                    .ff => next = f,
                    .conj => num |= bit,
                }
            }
            if (next == null) break;
            curr = next.?;
            bit = bit << 1;
        }
        p2 = util.lcm(p2, num);
    }

    print("p1: {}, p2: {}\n", .{ p1, p2 });
}

fn nameof(str: []const u8) u16 {
    assert(str.len == 2);
    return @bitCast(str[0..2].*);
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
