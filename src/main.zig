const std = @import("std");

const FileError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};
const AllocationError = error{
    OutOfMemory,
};

const GeneralError = error{
    InternalError,
};

const Color = enum(u8) {
    red = 1,
    green = 2,
    blue = 4,
    pub fn isGreen(self: Color) bool {
        return self == Color.green;
    }
};

const Vector = struct {
    x: f32,
    y: f32,
    z: f32,
    fn Length(self: *const Vector) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }
};

pub fn main() !void {
    try basics();
}

fn basics() !void {
    try printformat("\ncasting \n", .{}); //casting @as operator
    const number = @as(i32, 1000);
    try printformat("{d} ", .{number});

    try print("\nwhile \n"); // while
    var i: i32 = 0;
    while (i < 5) : (i += 1) {
        if (i == 1) continue;
        if (i == 3) break;
        try printformat("{d} ", .{i});
    }

    try printformat("\nfor \n", .{}); // for
    const items = [_]i32{ 10, 2, 3, 4, 68 };
    for (items, 0..) |item, index| {
        try printformat("{d}-{d}\n", .{ index, item });
    }

    try print("\nfunctions \n"); // functions
    const fib = fibonacci(10);
    try printformat("fib {d}\n", .{fib});

    try print("Defer\n"); // defer
    i = 2;
    {
        defer i = i - 2;
        defer i = @divTrunc(i, 2);
    }
    try printformat("{d}\n", .{i});

    try print("Errors\n"); // errors

    const e: FileError = AllocationError.OutOfMemory;
    try printformat("{s}\n", .{@errorName(e)});

    const d = div(-1) catch -1;
    try printformat("Value is {d}\n", .{d});

    try print("Switch\n"); // switch
    i = 3;
    const j = switch (i) {
        0...4 => i + 1,
        else => 0,
    };
    try printformat("{d}\n", .{j}); // switch

    try print("Pointers\n"); // pointers
    increment(&i);
    try printformat("{d}\n", .{i});

    try print("Pointers II \n"); // pointers II
    const p = [_]u8{ 1, 2, 3, 4 };
    const v: [*]const u8 = &p;
    try printformat("{d}\n", .{v[0]});

    try print("Slices\n");
    const slice = p[1..2];
    try printformat("{d}\n", .{slice[0]});

    try print("Enums\n");

    const c = Color.blue;
    try printformat("{d}\n", .{@intFromEnum(c)});

    try print("Structs\n");
    const v1 = Vector{ .x = 1, .y = 2, .z = 3 };
    try printformat("{d}\n", .{v1.Length()});
}

fn printformat(comptime format: []const u8, args: anytype) !void {
    return std.io.getStdOut().writer().print(format, args);
}

fn print(comptime text: []const u8) !void {
    return printformat(text, .{});
}

fn fibonacci(n: i32) i32 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

fn div(value: i32) GeneralError!i32 {
    if (value < 0) return GeneralError.InternalError;
    return @divTrunc(value, 2);
}

fn increment(x: *i32) void {
    x.* += 100;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
