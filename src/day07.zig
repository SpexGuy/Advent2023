const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");

const num_cards = 13;

fn cardOrdinal(has_jokers: bool, card: u8) u8 {
    return switch (card) {
        '2'...'9' => |c| (c - '2') + @intFromBool(has_jokers),
        'T' => @as(u8, 8) + @intFromBool(has_jokers),
        'J' => if (has_jokers) 0 else 9,
        'Q' => 10,
        'K' => 11,
        'A' => 12,
        else => unreachable,
    };
}

const Rank = enum {
    high_card,
    one_pair,
    two_pair,
    three_kind,
    full_house,
    four_kind,
    five_kind,
};

fn rankHand(has_jokers: bool, hand: [5]u8) Rank {
    // Count the number of each card
    var counts = [_]u8{0} ** num_cards;
    for (hand) |c| counts[c] += 1;
    // Count the number of pairs, triplets, fours, etc. (not including jokers)
    var combos = [_]u8{0} ** 6;
    const non_joker_counts = counts[@intFromBool(has_jokers)..];
    for (non_joker_counts) |c| combos[c] += 1;

    if (has_jokers) {
        // Convert jokers to cards, one at a time.
        var num_jokers = counts[0];
        while (num_jokers > 0) {
            num_jokers -= 1;
            // Always add a joker to the card that is most numerous.
            // sets of 4 become 5, 3 becomes 4, etc.
            var inspect: usize = 5;
            while (inspect > 0) {
                inspect -= 1;
                if (combos[inspect] > 0) {
                    combos[inspect] -= 1;
                    combos[inspect + 1] += 1;
                    break;
                }
            } else unreachable;
        }
    }

    // Determine the hand rank
    if (combos[5] > 0) return .five_kind;
    if (combos[4] > 0) return .four_kind;
    if (combos[3] > 0 and combos[2] > 0) return .full_house;
    if (combos[3] > 0) return .three_kind;
    if (combos[2] >= 2) return .two_pair;
    if (combos[2] > 0) return .one_pair;
    return .high_card;
}

const RankedHand = struct {
    hand: [5]u8,
    rank: Rank,
    bet: usize,

    fn ascSort(_: void, a: RankedHand, b: RankedHand) bool {
        // Primary sort by rank
        if (a.rank != b.rank) {
            return @intFromEnum(a.rank) < @intFromEnum(b.rank);
        }

        // Secondary lexical sort by hand
        for (a.hand, b.hand) |ac, bc| {
            if (ac != bc) return ac < bc;
        }

        unreachable; // Puzzles do not contain duplicate hands
    }
};

fn solve(has_jokers: bool) usize {
    var lines = tokenizeSca(u8, data, '\n');
    var hands = List(RankedHand).init(gpa);
    defer hands.deinit();
    while (lines.next()) |line| {
        var hand: [5]u8 = undefined;
        for (line[0..5], &hand) |c, *h| {
            h.* = cardOrdinal(has_jokers, c);
        }
        const bet = parseInt(usize, line[6..], 10) catch unreachable;

        hands.append(.{
            .hand = hand,
            .rank = rankHand(has_jokers, hand),
            .bet = bet,
        }) catch unreachable;
    }

    sort(RankedHand, hands.items, {}, RankedHand.ascSort);

    var result: usize = 0;
    for (hands.items, 1..) |hand, idx| {
        result += idx * hand.bet;
    }
    return result;
}

pub fn main() !void {
    const p1 = solve(false);
    const p2 = solve(true);
    print("p1: {}, p2: {}\n", .{ p1, p2 });
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
