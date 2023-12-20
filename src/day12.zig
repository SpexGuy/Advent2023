const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data2 = @embedFile("data/day12.txt");
const data =
\\???.### 1,1,3
\\.??..??...?##. 1,1,3
\\?#?#?#?#?#?#?#? 1,3,1,6
\\????.#...#... 4,1,1
\\????.######..#####. 1,6,5
\\?###???????? 3,2,1
;

fn countPermutations(in_line: []u8, in_numbers: []const usize) usize {
    var line = in_line;
    var numbers = in_numbers;
    while (true) {
        // Trim leading and trailing '.'
        line = trim(u8, line, ".");

        // Pidgeonhole
        if (numbers.len == 0) return @intFromBool(indexOf(u8, line, '#') == null);
        const min_len = sum(numbers) + numbers.len - 1;
        if (min_len < line.len) return 0;
        if (min_len == line.len) return 1;
        
        // Check for value against wall
        if (line[0] == '#') {
            line = line[numbers[0] + 1..];
            numbers = numbers[1..];
            continue;
        }
        if (line[line.len-1] == '#') {
            line.len -= numbers[numbers.len - 1] + 1;
            numbers.len -= 1;
            continue;
        }

        // Check for value that won't fit
        if (lastIndexOf(u8, line[0..numbers[0]], '.')) |dot| {
            line = line[dot+1..];
            continue;
        }
        if (indexOf(u8, line[line.len - numbers[numbers.len-1]..], '.')) |dot| {
            line = line[0..dot];
            continue;
        }

        // At this point, the first and last [numbers] are both all ? and #
        const start_pin = indexOf(u8, line[0..numbers[0]], '#');
        _ = start_pin;
    }
}

//f(1, 3) => 4
//f(2, 3) => f(1, 3) + f(1, 2) + f(1, 1) + f(1, 0)
//f(3, 3) => f(2, 3) + f(2, 2) + f(2, 1) + f(2, 0)
fn triangleCount(num_groups: usize, free: usize) usize {
    print("simplex({}, {}) = {}", .{num_groups, free, free+1});
    var count: usize = free + 1;
    for (1..num_groups) |g| {
        count *= (free + 1 + g);
        count = @divExact(count, g + 1);
        print(" * {} / {}", .{free + 1 + g, g + 1});
    }
    print(" = {}\n", .{count});
    return count;
}

fn countWithBits(in_unknowns: u128, in_fills: u128, numbers: []const usize, in_indent: usize) usize {
    if (numbers.len == 0) {
        return @intFromBool((in_fills & ~in_unknowns) == 0);
    }

    const total = sum(numbers);
    if (@popCount(in_unknowns | in_fills) < total) return 0;

    const tz = @ctz(in_unknowns | in_fills);
    const unknowns = in_unknowns >> @intCast(tz);
    const fills = in_fills >> @intCast(tz);
    const indent = in_indent + tz;

    var count: usize = 0;
    const len: usize = @as(usize, 128 - @clz(unknowns | fills));
    const need = total + numbers.len - 1;
    if (need > len) return 0;

    // If we start with a run of question marks followed by ., process that in bulk
    const leading_qs: usize = @ctz(~unknowns);
    const first_nonq: u128 = @as(u128, 1) << @intCast(leading_qs);
    if (leading_qs > numbers[0] and first_nonq & in_fills == 0) {
        var part_sum = numbers[0];
        var i: usize = 1;
        const inner_unknowns = unknowns >> @intCast(leading_qs + 1);
        const inner_fills = fills >> @intCast(leading_qs + 1);
        const inner_indent = indent + leading_qs + 1;
        while (part_sum <= leading_qs) {
            const free = leading_qs - part_sum;
            const combos = triangleCount(i, free);

            const sub_count = countWithBits(inner_unknowns, inner_fills, numbers[i..], inner_indent);
            printPattern(inner_unknowns, inner_fills, numbers[i..], inner_indent, mask(leading_qs) << @intCast(indent), '*', numbers[0..i], sub_count, combos);
            count += combos * sub_count;

            if (i >= numbers.len) break;
            part_sum += numbers[i] + 1;
            i += 1;
        }
        return count;
    }

    const max_idx = @min(len - need, @ctz(fills & ~unknowns));
    for (0..max_idx+1) |shift| {
        var mc = mask(numbers[0] + 1) << @intCast(shift);
        const m = (mc >> 1);
        mc &= ~unknowns;
        if (m & mc == fills & mc) {
            const inner_unknowns = unknowns >> @intCast(shift + numbers[0] + 1);
            const inner_fills = fills >> @intCast(shift + numbers[0] + 1);
            const inner_indent = indent + shift + numbers[0] + 1;
            const sub_count = countWithBits(inner_unknowns, inner_fills, numbers[1..], inner_indent);
            printPattern(inner_unknowns, inner_fills, numbers[1..], inner_indent, (m & mc) << @intCast(indent), 'X', numbers[0..1], sub_count, null);
            //if (sub_count == 0 and numbers.len > 1) return count;
            count += sub_count;
        }
    }


    return count;
}

fn printPattern(unknowns: u128, fills: u128, items: []const usize, indent: usize, highlight: u128, hl_byte: u8, hl_nums: []const usize, count: usize, multiplier: ?usize) void {
    var buf = std.io.bufferedWriter(std.io.getStdErr().writer());
    for (0..indent) |off| {
        const bit = @as(u128, 1) << @intCast(off);
        if (highlight & bit != 0) {
            buf.writer().writeByte(hl_byte) catch unreachable;
        } else {
            buf.writer().writeByte('_') catch unreachable;
        }
    }
    var len: usize = 128-@clz(unknowns | fills);
    if (unknowns|fills != 0) len += 1;
    for (0..len) |i| {
        const bit = @as(u128, 1) << @intCast(i);
        const abs_bit = bit << @intCast(indent);
        if (highlight & abs_bit != 0) {
            buf.writer().writeByte(hl_byte) catch unreachable;
        } else if (unknowns & bit != 0) {
            buf.writer().writeByte('?') catch unreachable;
        } else if (fills & bit != 0) {
            buf.writer().writeByte('#') catch unreachable;
        } else {
            buf.writer().writeByte('.') catch unreachable;
        }
    }
    buf.writer().writeAll("    ") catch unreachable;
    buf.writer().print("{}", .{count}) catch unreachable;
    if (multiplier) |m| {
        buf.writer().print(" x{}", .{m}) catch unreachable;
    }
    buf.writer().writeAll("    ") catch unreachable;
    if (hl_nums.len > 0) {
        buf.writer().writeByte('[') catch unreachable;
        for (hl_nums, 0..) |it, i| {
            if (i != 0) {
                buf.writer().writeByte(',') catch unreachable;
            }
            buf.writer().print("{}", .{it}) catch unreachable;
        }
        buf.writer().writeByte(']') catch unreachable;
    }
    if (items.len > 0) {
        for (items, 0..) |it, i| {
            if (i != 0) {
                buf.writer().writeByte(',') catch unreachable;
            }
            buf.writer().print("{}", .{it}) catch unreachable;
        }
    }
    buf.writer().writeByte('\n') catch unreachable;
    buf.flush() catch unreachable;
}

fn mask(x: u128) u128 {
    return (@as(u128, 1) << @intCast(x)) - 1;
}

pub fn main() !void {
    var p1: usize = 0;
    var p2: usize = 0; _ = &p2;
    var lines = tokenizeSca(u8, data, '\n');
    var nums = List(usize).init(gpa);
    while (lines.next()) |line| {
        nums.items.len = 0;
        var parts = tokenizeAny(u8, line, " ,");
        const vis = parts.next().?;
        while (parts.next()) |group| {
            try nums.append(@intCast(parseDec(group)));
        }
        const parti = 1;
        try nums.ensureTotalCapacity(nums.items.len * parti);
        p2 = @max(p2, vis.len * 5 + 4);
        var unknowns: u128 = 0;
        var fills: u128 = 0;
        var i: usize = 0;
        for (0..parti) |j| {
            for (vis, i..) |c, ii| {
                if (c == '?') unknowns |= @as(u128, 1) << @intCast(ii);
                if (c == '#') fills |= @as(u128, 1) << @intCast(ii);
            }
            if (j != parti-1) {
                unknowns |= @as(u128, 1) << @intCast(i + vis.len);
            }
            i += vis.len + 1;
        }

        const orig_len = nums.items.len;
        for (1..parti) |_| {
            nums.appendSliceAssumeCapacity(nums.items[0..orig_len]);
        }
        const sub_cnt = countWithBits(unknowns, fills, nums.items, 0);
        printPattern(unknowns, fills, nums.items, 0, 0, 0, &.{}, sub_cnt, null);
        //const sub_cnt = countPermutations(vis, nums.items);
        p1 += sub_cnt;
        print("{s}: ", .{line});
        print("{d}\n", .{sub_cnt});
    }

    print("p1: {}, p2: {}\n", .{p1, p2});
}

fn sum(nums: []const usize) usize {
    var s: usize = 0;
    for (nums) |n| s += n;
    return s;
}

fn fac(x: usize) usize {
    var i = x;
    var prod: usize = 1;
    while (i > 1) {
        prod *= i;
        i -= 1;
    }
    return prod;
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
