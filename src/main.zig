const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    try stdout_file.print("Without buffering:\n", .{});
    var name: [5]u8 = undefined;
    const hello = [_]u8{ 'H', 'e', 'l', 'l', 'o' };

    for (hello, 0..) |c, i| {
        name[i] = c;
    }

    var i: i32 = 4;

    while (i >= 0) : (i -= 1) {
        try stdout_file.print("{d}\n", .{i});
    }

    try stdout_file.print("{s} has len {d}\n", .{ name, name.len });
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
