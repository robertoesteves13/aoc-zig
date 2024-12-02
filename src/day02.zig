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
        if (try is_solvable(list) == true) {
            valid_reports += 1;
        } else {
            for (0..list.items.len) |i| {
                var new_list = List(i32).init(gpa);
                for (0..list.items.len) |j| {
                    if (i != j) {
                        try new_list.append(list.items[j]);
                    }
                }

                if (try is_solvable(new_list) == true) {
                    valid_reports += 1;
                    break;
                }
            }
        }
    }

    print("Valid Reports: {}\n", .{valid_reports});
}

fn is_solvable(list: List(i32)) !bool {
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

    return errors.items.len == 0;
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
