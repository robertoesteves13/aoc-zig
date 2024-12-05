const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const Parser = struct {
    input: [][]const u8,
    alloc: std.mem.Allocator,
    count: u64,

    const Self = @This();

    fn init(input: [][]const u8, alloc: std.mem.Allocator) Self {
        return Self{
            .input = input,
            .alloc = alloc,
            .count = 0,
        };
    }

    fn count_window(self: *Self, window: [4][4]u8) void {
        const diag_backslash = diag_backslash: {
            var line = [_]u8{0} ** 4;
            inline for (0..4) |i| {
                line[i] = window[i][i];
            }

            break :diag_backslash line;
        };

        if (std.mem.eql(u8, &diag_backslash, "XMAS")) {
            self.count += 1;
        } else if (std.mem.eql(u8, &diag_backslash, "SAMX")) {
            self.count += 1;
        }

        const diag_slash = diag_slash: {
            var line = [_]u8{0} ** 4;
            inline for (0..4) |i| {
                line[i] = window[i][3 - i];
            }

            break :diag_slash line;
        };

        if (std.mem.eql(u8, &diag_slash, "XMAS")) {
            self.count += 1;
        } else if (std.mem.eql(u8, &diag_slash, "SAMX")) {
            self.count += 1;
        }
    }

    fn parse_part_2(self: *Self) void {
        // Get the dimensions of the input
        const rows = self.input.len;
        const cols = if (rows > 0) self.input[0].len else 0;

        // Window size
        const window_size = 3;

        // Make sure we don't go out of bounds
        const max_row = if (rows >= window_size) rows - window_size + 1 else 0;
        const max_col = if (cols >= window_size) cols - window_size + 1 else 0;

        for (0..max_row) |i| {
            for (0..max_col) |j| {
                // Create a temporary array to store the window
                var window: [window_size][window_size]u8 = undefined;

                // Copy the window contents
                for (0..window_size) |wi| {
                    for (0..window_size) |wj| {
                        window[wi][wj] = self.input[i + wi][j + wj];
                    }
                }

                const pattern1 = window[0][0] == 'M' and window[0][2] == 'S' and window[1][1] == 'A' and window[2][0] == 'M' and window[2][2] == 'S';
                const pattern2 = window[0][0] == 'M' and window[0][2] == 'M' and window[1][1] == 'A' and window[2][0] == 'S' and window[2][2] == 'S';
                const pattern3 = window[0][0] == 'S' and window[0][2] == 'S' and window[1][1] == 'A' and window[2][0] == 'M' and window[2][2] == 'M';
                const pattern4 = window[0][0] == 'S' and window[0][2] == 'M' and window[1][1] == 'A' and window[2][0] == 'S' and window[2][2] == 'M';

                if (pattern1 or pattern2 or pattern3 or pattern4) {
                    self.count += 1;
                }
            }
        }
    }

    fn parse(self: *Self) void {
        // Get the dimensions of the input
        const rows = self.input.len;
        const cols = if (rows > 0) self.input[0].len else 0;

        // Window size
        const window_size = 4;

        // Make sure we don't go out of bounds
        const max_row = if (rows >= window_size) rows - window_size + 1 else 0;
        const max_col = if (cols >= window_size) cols - window_size + 1 else 0;

        for (0..max_row) |i| {
            for (0..max_col) |j| {
                // Create a temporary array to store the window
                var window: [window_size][window_size]u8 = undefined;

                // Copy the window contents
                for (0..window_size) |wi| {
                    for (0..window_size) |wj| {
                        window[wi][wj] = self.input[i + wi][j + wj];
                    }
                }

                // Process the window
                self.count_window(window);
            }
        }

        for (self.input) |line| {
            for (0..137) |i| {
                if (std.mem.eql(u8, line[i .. i + 4], "XMAS")) {
                    self.count += 1;
                } else if (std.mem.eql(u8, line[i .. i + 4], "SAMX")) {
                    self.count += 1;
                }
            }
        }

        for (0..140) |i| {
            for (0..137) |j| {
                var line = [_]u8{0} ** 4;
                line[0] = self.input[j][i];
                line[1] = self.input[j + 1][i];
                line[2] = self.input[j + 2][i];
                line[3] = self.input[j + 3][i];

                if (std.mem.eql(u8, &line, "XMAS")) {
                    self.count += 1;
                } else if (std.mem.eql(u8, &line, "SAMX")) {
                    self.count += 1;
                }
            }
        }
    }
};

pub fn main() !void {
    var lines = List([]const u8).init(gpa);
    const data = @embedFile("data/day04.txt");
    var iter = tokenizeSca(u8, data, '\n');
    while (iter.peek() != null) {
        try lines.append(iter.next().?);
    }

    var parser = Parser.init(lines.items, gpa);
    parser.parse();

    print("Total: {}\n", .{parser.count});

    parser.count = 0;
    parser.parse_part_2();
    print("Total: {}\n", .{parser.count});
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
