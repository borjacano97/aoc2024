const std = @import("std");
const sort = std.sort;
const testing = std.testing;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

fn read_input(path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    return try file.readToEndAlloc(alloc, 1 << 31);
}

const Input = struct {
    left: std.ArrayList(i32),
    right: std.ArrayList(i32),

    fn init() !Input {
        var self: Input = undefined;
        self.left = std.ArrayList(i32).init(alloc);
        self.right = std.ArrayList(i32).init(alloc);
        return self;
    }

    fn deinit(self: *Input) void {
        self.left.deinit();
        self.right.deinit();
    }
};

fn process_input(input_text: []const u8) !Input {
    std.debug.print("Processing input...\n", .{});
    var lines = std.mem.split(u8, input_text, "\r\n");
    var input = try Input.init();
    while (lines.next()) |line| {
        var parts = std.mem.split(u8, line, "   ");
        var a = parts.next() orelse return error.invalid_input;
        a = std.mem.trim(u8, a, " \r\n");
        var b = parts.next() orelse return error.invalid_input;
        b = std.mem.trim(u8, b, " \r\n");
        const left = std.fmt.parseInt(i32, a, 10) catch |e| {
            std.debug.print("Error parsing {s}: {any}", .{ a, e });
            return error.invalid_input;
        };
        const right = std.fmt.parseInt(i32, b, 10) catch |e| {
            std.debug.print("Error parsing {s} : {any}", .{ b, e });
            return error.invalid_input;
        };

        try input.left.append(left);
        try input.right.append(right);
    }
    return input;
}

fn solve(input: Input) i64 {
    var score: i64 = 0;
    for (input.left.items) |left| {
        var count: i64 = 0;
        for (input.right.items) |right| {
            if (left == right) {
                count += 1;
            }
        }
        score += left * count;
    }
    return score;
}

pub fn main() !void {
    const input_text = try read_input("data/input01_1.txt");
    const input = try process_input(input_text);
    const result = solve(input);
    const output = std.io.getStdOut().writer();
    try output.print("Result: {d}\n", .{result});
}

test "sample" {
    const input_text: []const u8 = "3   4\r\n4   3\r\n2   5\r\n1   3\r\n3   9\r\n3   3";
    const solution = 31;

    const input = try process_input(input_text);
    const result = solve(input);
    try testing.expect(result == solution);
}
