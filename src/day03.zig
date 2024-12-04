const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

const MulParserState = enum {
    start,
    m,
    u,
    l,
    open,
    digit,
    comma,
    close,
    invalid,
    d,
    o,
    n,
    apost,
    t,

    const Self = @This();

    fn get_state(char: u8) Self {
        return switch (char) {
            'd' => .d,
            'o' => .o,
            'n' => .n,
            '\'' => .apost,
            't' => .t,
            'm' => .m,
            'u' => .u,
            'l' => .l,
            '(' => .open,
            ',' => .comma,
            ')' => .close,
            '0' => .digit,
            '1' => .digit,
            '2' => .digit,
            '3' => .digit,
            '4' => .digit,
            '5' => .digit,
            '6' => .digit,
            '7' => .digit,
            '8' => .digit,
            '9' => .digit,
            else => .invalid,
        };
    }

    fn should_expect(self: *Self, next: *const Self) bool {
        return switch (self.*) {
            Self.start => next.* == Self.m or next.* == Self.d,
            Self.m => next.* == Self.u,
            Self.u => next.* == Self.l,
            Self.l => next.* == Self.open,
            Self.open => next.* == Self.digit or next.* == Self.close,
            Self.digit => next.* == Self.digit or next.* == Self.comma or next.* == Self.close,
            Self.comma => next.* == Self.digit,
            Self.close => next.* == Self.start,
            Self.invalid => false,

            Self.d => next.* == Self.o,
            Self.o => next.* == Self.n or next.* == Self.open,
            Self.n => next.* == Self.apost,
            Self.apost => next.* == Self.t,
            Self.t => next.* == Self.open,
        };
    }
};

const MulParser = struct {
    input: []const u8,
    numbers: List(u32),
    alloc: std.mem.Allocator,

    const Self = @This();

    fn init(input: []const u8, alloc: std.mem.Allocator) Self {
        return Self{
            .input = input,
            .numbers = List(u32).init(alloc),
            .alloc = alloc,
        };
    }

    fn parse(self: *Self) !void {
        var past_state = MulParserState.start;
        var start: usize = 0;
        var end: usize = 0;

        var is_enabled = true;

        for (self.input) |char| {
            var state = MulParserState.get_state(char);
            if (past_state.should_expect(&state) == true) {
                if (state == MulParserState.close) {
                    const slice = self.input[start .. end + 1];
                    if (std.mem.eql(u8, slice, "do()") == true) {
                        is_enabled = true;
                    } else if (std.mem.eql(u8, slice, "don't()") == true) {
                        is_enabled = false;
                    } else if (is_enabled == true) {
                        var tokenizer = tokenizeAny(u8, slice, "mul(,)");
                        const num1 = try parseInt(u32, tokenizer.next().?, 10);
                        const num2 = try parseInt(u32, tokenizer.next().?, 10);

                        try self.numbers.append(num1);
                        try self.numbers.append(num2);
                    }

                    start = end + 1;
                    state = MulParserState.start;
                }
            } else {
                start = end + 1;
                state = MulParserState.start;
            }

            past_state = state;
            end += 1;
        }
    }

    fn multiply_total(self: *Self) u32 {
        var acc: u32 = 0;
        var i: usize = 1;
        while (i < self.numbers.items.len) {
            acc += self.numbers.items[i - 1] * self.numbers.items[i];
            i += 2;
        }

        return acc;
    }
};

pub fn main() !void {
    var parser = MulParser.init(data, gpa);
    try parser.parse();

    const total = parser.multiply_total();
    print("Total: {}\n", .{total});
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
