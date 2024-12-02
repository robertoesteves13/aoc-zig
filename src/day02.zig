const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

const order = enum { asc, desc, unset };

fn print_list(list: List(i32), distances: List(i32)) void {
    print("{any}\n", .{list.items});
    print("{any}\n", .{distances.items});
    print("\n", .{});
}

pub fn main() !void {
    var number_matrix = List(List(i32)).init(gpa);

    var lines = tokenizeAny(u8, data, "\n");
    while (lines.peek() != null) {
        var numbers = tokenizeAny(u8, lines.next().?, " ");
        var list = List(i32).init(gpa);
        while (numbers.peek() != null) {
            try list.append(try parseInt(i32, numbers.next().?, 10));
        }
        try number_matrix.append(list);
    }

    var valid_reports: u64 = 0;
    for (0..number_matrix.items.len) |u| {
        const list = number_matrix.items[u];
        var distances = List(i32).init(gpa);
        var sum: i32 = 0;
        for (1..list.items.len) |i| {
            const num = list.items[i - 1] - list.items[i];
            try distances.append(num);
            sum += num;
        }

        if (sum < 0) {
            for (0..distances.items.len) |i| {
                distances.items[i] *= -1;
            }
            sum *= -1;
        }

        var errors = List(usize).init(gpa);
        for (0..distances.items.len) |i| {
            if (distances.items[i] > 3 or distances.items[i] <= 0) try errors.append(i);
        }

        if (errors.items.len == 0) {
            valid_reports += 1;
        } else {
            if (errors.items.len == 1) {
                const idx = errors.items[0];
                const distance = distances.items[idx];

                if (distance > 0) {
                    if (idx == 0 or idx == distances.items.len - 1) valid_reports += 1;
                } else {
                    if (distance == 0) valid_reports += 1 else {
                        if (idx == 0 or idx == distances.items.len - 1) valid_reports += 1 else {
                            const val = distance + distances.items[idx + 1];
                            if (val <= 3 or val > 0) valid_reports += 1;
                        }
                    }
                }
            }
            if (errors.items.len == 2) {
                const idx_mean = errors.items[1] - errors.items[0];
                if (idx_mean == 1) {
                    const val = distances.items[errors.items[1]] + distances.items[errors.items[0]];
                    if (val <= 3 and val > 0) {
                        valid_reports += 1;
                    }
                }
            }
        }
    }

    print("Valid Reports: {}\n", .{valid_reports});
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
