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

fn process_input(input_text: []u8) !Input {
    std.debug.print("Processing input...\n", .{});
    std.debug.print("\tSpliting by lines...\n", .{});
    var lines = std.mem.split(u8, input_text, "\r\n");
    var input = try Input.init();
    while (lines.next()) |line| {
        std.debug.print("\tProcessing line: {s}\n", .{line});
        var parts = std.mem.split(u8, line, "   ");
        var a = parts.next() orelse return error.invalid_input;
        a = std.mem.trim(u8, a, " \r\n");
        std.debug.print("\t\tLeft:{s}\n", .{a});
        var b = parts.next() orelse return error.invalid_input;
        b = std.mem.trim(u8, b, " \r\n");
        std.debug.print("\t\tRight:{s}\n", .{b});

        std.debug.print("\t\tParsing integers...\n", .{});
        const left = std.fmt.parseInt(i32, a, 10) catch |e| {
            std.debug.print("Error parsing {s}: {any}", .{ a, e });
            return error.invalid_input;
        };
        std.debug.print("\t\tLeft:{d}\n", .{left});
        const right = std.fmt.parseInt(i32, b, 10) catch |e| {
            std.debug.print("Error parsing {s} : {any}", .{ b, e });
            return error.invalid_input;
        };
        std.debug.print("\t\tRight:{d}\n", .{right});

        try input.left.append(left);
        try input.right.append(right);
    }
    return input;
}

fn solve(input: Input) u32 {
    std.mem.sort(i32, input.left.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, input.right.items, {}, comptime std.sort.asc(i32));

    var dist: u32 = 0;
    const len = input.left.items.len;
    for (0..len) |i| {
        const left = input.left.items[i];
        const right = input.right.items[i];
        dist += @abs(left - right);
    }
    return dist;
}

pub fn main() !void {
    const input_text = try read_input("data/input01_1.txt");
    //std.debug.print("{s}\n", .{input_text});
    const input = try process_input(input_text);
    const result = solve(input);
    const output = std.io.getStdOut().writer();
    try output.print("Result: {d}\n", .{result});
}

test "sample" {
    const input_text: []const u8 = "3   4\n4   3\n2   5\n1   3\n3   9\n3   3";
    const solution = 11;

    const input = try process_input(input_text);
    const result = solve(input);
    try testing.expect(result == solution);
}
