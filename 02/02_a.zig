const std = @import("std");
var alloc = std.heap.GeneralPurposeAllocator(.{}){};
const Report = struct {
    levels: std.ArrayList(i32),

    pub fn parse(line: []const u8) !Report {
        if (line.len == 0) {
            return error.empty_line;
        }
        var parts = std.mem.split(u8, line, " ");
        var levels = std.ArrayList(i32).init(alloc.allocator());
        while (parts.next()) |part| {
            //std.debug.print("part: {s}\n", .{part});
            const level = try std.fmt.parseInt(i32, part, 10);
            try levels.append(level);
        }
        return Report{ .levels = levels };
    }
};

fn parse(input_text: []const u8) !std.ArrayList(Report) {
    var lines = std.mem.split(u8, input_text, "\r\n");
    var reports = std.ArrayList(Report).init(alloc.allocator());
    while (lines.next()) |line| {
        //std.debug.print("line: {s}\n", .{line});
        const report = Report.parse(line) catch {
            continue;
        };
        try reports.append(report);
    }
    return reports;
}

fn is_save(report: Report) bool {
    std.debug.print("{any}\n", .{report.levels.items});
    const asc = report.levels.items[0] < report.levels.items[1];
    std.debug.print("Is ascending: {any}\n", .{asc});

    for (0..report.levels.items.len - 1) |i| {
        const a = report.levels.items[i + 0];
        const b = report.levels.items[i + 1];
        const diff = b - a;
        if ((asc and diff < 0) or (!asc and diff > 0)) {
            return false;
        } else if (diff == 0 or @abs(diff) > 3) {
            return false;
        }
    }
    return true;
}

fn solve(input_text: []const u8) !i32 {
    const reports = try parse(input_text);
    var count: i32 = 0;
    for (reports.items) |report| {
        if (is_save(report)) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    const input_text = try std.fs.cwd().readFileAlloc(alloc.allocator(), "data/input_2.txt", 1 << 31);
    const result = try solve(input_text);
    std.debug.print("Result: {d}\n", .{result});
}

test "test" {
    const input_text = "7 6 4 2 1\r\n" ++ "1 2 7 8 9\r\n" ++ "9 7 6 2 1\r\n" ++ "1 3 2 4 5\r\n" ++ "8 6 4 4 1\r\n" ++ "1 3 6 7 9\r\n";
    const expected = 2;
    const result = try solve(input_text);
    try std.testing.expectEqual(result, expected);
}
