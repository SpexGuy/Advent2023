const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const times = [_]usize{ 41968894 };
const dists = [_]usize{ 214178911271055 };
// const times = [_]usize{ 7, 15, 30};
// const dists = [_]usize{ 9, 40, 200 };

pub fn main() !void {
    var p1: usize = 1; _ = &p1;
    var p2: usize = 0; _ = &p2;

    for (times, dists, 0..) |time, dist, i| {
        _ = i;
        //std.debug.print("race {}\n", .{i});

        // var min: usize = 0;
        // var max = time / 2;
        // while (true) {
        //     const mid = (max - min) / 2 + min;
        //     if (mid == min) break;
        //     const total_dist = (time - mid) * mid;
        //     if (total_dist > dist) {
        //         max = mid;
        //     } else {
        //         min = mid;
        //     }
        // }
        // assert(min + 1 == max);
        // const first_win = max;

        // min = time / 2;
        // max = time;
        // while (true) {
        //     const mid = (max - min) / 2 + min;
        //     if (mid == min) break;
        //     const total_dist = (time - mid) * mid;
        //     if (total_dist < dist) {
        //         max = mid;
        //     } else {
        //         min = mid;
        //     }
        // }
        // assert(min + 1 == max);
        // const first_lose = max;

        // p2 = first_lose - first_win;


        var cnt: usize = 0;
        for (1..@intCast(time)) |speed| {
            const total_dist = (time - speed) * speed;
            if (total_dist > dist) {
                //print("win with speed {} : {}\n", .{speed, total_dist});
                cnt += 1;
            }
        }
        p1 *= cnt;
    }

    print("p1: {}, p2: {}\n", .{p1, p2});
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
