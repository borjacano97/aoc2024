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

fn is_save(levels: []i32) bool {
    std.debug.print("Checking {any}: ", .{levels});
    const asc = levels[0] < levels[1];

    for (0..levels.len - 1) |i| {
        const a = levels[i + 0];
        const b = levels[i + 1];
        const diff = b - a;
        if ((asc and diff < 0) or (!asc and diff > 0)) {
            std.debug.print("Not save: error on tendency\n", .{});
            return false;
        } else if (diff == 0) {
            std.debug.print("Not save: repeated value ({d})\n", .{a});
            return false;
        } else if (@abs(diff) > 3) {
            std.debug.print("Not save: difference too large ({d})\n", .{diff});
            return false;
        }
    }
    std.debug.print("Save\n", .{});
    return true;
}

fn is_save_with_faulty_report(report: Report) !bool {
    // Frist try the original report
    std.debug.print(">>>>\n", .{});
    if (is_save(report.levels.items)) {
        return true;
    }
    // Then try the report with one faulty level
    const levels_len = report.levels.items.len;
    for (0..levels_len) |skip| {
        var levels = std.ArrayList(i32).init(alloc.allocator());
        defer levels.deinit();

        for (0..levels_len) |i| {
            if (i == skip) {
                continue;
            }
            try levels.append(report.levels.items[i]);
        }

        if (is_save(levels.items)) {
            return true;
        }
    }
    return false;
}

fn solve(input_text: []const u8) !i32 {
    const reports = try parse(input_text);
    var count: i32 = 0;
    for (reports.items) |report| {
        if (try is_save_with_faulty_report(report)) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    const input_text = try std.fs.cwd().readFileAlloc(alloc.allocator(), "data/input_2.txt", 1 << 31);
    const result = try solve(input_text);
    std.debug.print("\x1b[1mResult: {d}\x1b[0m\n", .{result});
}

test "test" {
    const input_text = "7 6 4 2 1\r\n" ++ "1 2 7 8 9\r\n" ++ "9 7 6 2 1\r\n" ++ "1 3 2 4 5\r\n" ++ "8 6 4 4 1\r\n" ++ "1 3 6 7 9\r\n";
    const expected = 4;
    const result = try solve(input_text);
    try std.testing.expectEqual(expected, result);
}
