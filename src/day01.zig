const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var tokenizer = tokenizeAny(u8, data, " \n");

    var numbers1 = List(u32).init(gpa);
    var numbers2 = List(u32).init(gpa);

    while (tokenizer.peek() != null) {
        const number1 = tokenizer.next().?;
        const number2 = tokenizer.next().?;
        try numbers1.append(try parseInt(u32, number1, 10));
        try numbers2.append(try parseInt(u32, number2, 10));
    }

    sort(u32, numbers1.items, {}, asc(u32));
    sort(u32, numbers2.items, {}, asc(u32));

    var sum: u64 = 0;
    for (0..numbers1.items.len) |i| {
        if (numbers1.items[i] < numbers2.items[i]) {
            sum += @abs(numbers2.items[i] - numbers1.items[i]);
        } else {
            sum += @abs(numbers1.items[i] - numbers2.items[i]);
        }
    }
    print("{}\n", .{sum});

    var score: u64 = 0;
    var number_map = Map(u32, u32).init(gpa);
    for (numbers1.items) |number1| {
        if (number_map.contains(number1)) {
            score += number1 * number_map.get(number1).?;
        } else {
            var count: u32 = 0;
            for (numbers2.items) |number2| {
                if (number2 == number1) {
                    count += 1;
                }
            }

            score += number1 * count;
            try number_map.put(number1, count);
        }
    }
    print("{}\n", .{score});
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
