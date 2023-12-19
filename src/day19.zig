const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day19.txt");

const Rule = struct {
    channel: u2,
    op: u8, // >, <, ! for accept all
    number: usize,
    dest: []const u8,

    fn match(r: Rule, val: [4]usize) bool {
        return switch (r.op) {
            '!' => true,
            '>' => val[r.channel] > r.number,
            '<' => val[r.channel] < r.number,
            else => unreachable,
        };
    }

    fn partition(r: Rule, d: Range) [2]Range {
        if (r.op == '!') return .{ d, Range.invalid };
        var pass = d;
        var fail = d;
        if (r.op == '<') {
            pass.max = @min(pass.max, r.number - 1);
            fail.min = @max(fail.min, r.number);
        } else if (r.op == '>') {
            pass.min = @max(pass.min, r.number + 1);
            fail.max = @min(fail.max, r.number);
        } else unreachable;
        return .{ pass, fail };
    }
};

const Range = struct {
    min: usize,
    max: usize,

    pub const invalid = Range{ .min = 2, .max = 1 };

    pub fn isValid(r: Range) bool {
        return r.min <= r.max;
    }

    pub fn length(r: Range) usize {
        return if (r.isValid()) r.max + 1 - r.min else 0;
    }
};

const Domain = [4]Range;

fn countCombos(workflows: StrMap([]const Rule), workflow: []const u8, in_domain: Domain) usize {
    if (std.mem.eql(u8, workflow, "A")) {
        var total: usize = 1;
        for (in_domain) |axis| total *= axis.length();
        return total;
    }
    if (std.mem.eql(u8, workflow, "R")) {
        return 0;
    }
    var domain = in_domain;
    const rules = workflows.get(workflow).?;
    var total: usize = 0;
    for (rules) |rule| {
        const pass, const fail = rule.partition(domain[rule.channel]);
        if (pass.isValid()) {
            domain[rule.channel] = pass;
            total += countCombos(workflows, rule.dest, domain);
        }
        if (!fail.isValid()) break;
        domain[rule.channel] = fail;
    } else unreachable;
    return total;
}

pub fn main() !void {
    var p1: usize = 0;
    var lines = splitSca(u8, data, '\n');
    var workflows = StrMap([]const Rule).init(gpa);
    while (lines.next()) |line| {
        if (line.len == 0) break;
        var rules = tokenizeAny(u8, line, "{},");
        const name = rules.next().?;
        var arr = List(Rule).init(gpa);
        while (rules.next()) |rstr| {
            if (indexOf(u8, rstr, ':')) |col| {
                const channel = indexOf(u8, "xmas", rstr[0]).?;
                arr.append(.{
                    .channel = @intCast(channel),
                    .op = rstr[1],
                    .number = parseDec(rstr[2..col]),
                    .dest = rstr[col + 1 ..],
                }) catch unreachable;
            } else {
                arr.append(.{
                    .channel = 0,
                    .op = '!',
                    .number = 0,
                    .dest = rstr,
                }) catch unreachable;
            }
        }
        workflows.put(name, arr.toOwnedSlice() catch unreachable) catch unreachable;
    }

    while (lines.next()) |line| {
        if (line.len == 0) break;
        var nums = tokenizeAny(u8, line, "{}xmas=,");
        const item = [4]usize{
            parseDec(nums.next().?),
            parseDec(nums.next().?),
            parseDec(nums.next().?),
            parseDec(nums.next().?),
        };

        var workflow: []const u8 = "in";
        while (true) {
            if (std.mem.eql(u8, workflow, "A")) {
                p1 += item[0] + item[1] + item[2] + item[3];
                break;
            }
            if (std.mem.eql(u8, workflow, "R")) {
                break;
            }
            const rules = workflows.get(workflow).?;
            workflow = for (rules) |rule| {
                if (rule.match(item)) {
                    break rule.dest;
                }
            } else unreachable;
        }
    }

    const all: Domain = [_]Range{.{ .min = 1, .max = 4000 }} ** 4;
    const p2 = countCombos(workflows, "in", all);

    print("p1: {}, p2: {}\n", .{ p1, p2 });
}

fn parseDec(val: []const u8) usize {
    return parseInt(usize, val, 10) catch unreachable;
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
