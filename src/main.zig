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
    pub fn Length(self: *const Vector) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }
};

const Tag = enum { value, err };
const Result = union(Tag) { value: i32, err: GeneralError };

pub fn main() !void {
    // try basics();
    try stadardPatterns();
}

fn stadardPatterns() !void {
    try print("Page Allocator\n");
    const page_allocator = std.heap.page_allocator;
    const page_memory = try page_allocator.alloc(u8, 100);
    defer page_allocator.free(page_memory);
    try printformat("{d}\n", .{page_memory.len});

    try print("Fixed Allocator\n");
    var fixed_buffer: [1000]u8 = undefined;
    var fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(&fixed_buffer);
    const fixed_allocator = fixed_buffer_allocator.allocator();
    const fixed_memory = try fixed_allocator.alloc(u8, 100);
    defer fixed_allocator.free(fixed_memory);

    try print("General Allocator\n");
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const general_allocator = general_purpose_allocator.allocator();

    defer {
        const check = general_purpose_allocator.deinit();
        if (check == .leak) {}
    }

    const general_bytes = try general_allocator.alloc(u8, 100);
    defer general_allocator.free(general_bytes);

    try print("Arraylist\n");
    var list = std.ArrayList(u8).init(general_allocator);
    defer list.deinit();
    try list.append('A');
    try list.append('Z');
    try list.appendSlice("Hello");
    try printformat("{s}\n", .{list.items});

    try print("FileSystem\n");
    const file = try std.fs.cwd().createFile("test.txt", .{ .read = true });
    defer file.close();
    const bytes_written = try file.writeAll("Hello file!");
    _ = bytes_written;
    try file.seekTo(0);
    var file_buffer: [100]u8 = undefined;
    const bytes_read = try file.readAll(&file_buffer);
    try printformat("{d} {s}\n", .{ bytes_read, file_buffer[0..bytes_read] });
    const stats = try file.stat();
    try printformat("{d} {d} {s}", .{ stats.ctime, stats.mtime, @tagName(stats.kind) });
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

    try print("Unions\n");
    const un0 = Result{ .value = 34 };
    const un1 = Result{ .err = GeneralError.InternalError };
    try printformat("{d}\n", .{un0.value});
    try printformat("{s}\n", .{@errorName(un1.err)});
    switch (un0) {
        .value => |a| try printformat("Value {d}\n", .{a}),
        .err => |b| try printformat("Error {s}\n", .{@errorName(b)}),
    }
    switch (un0) {
        .value => |*a| try printformat("Value* {d}\n", .{a.*}),
        .err => |*b| try printformat("Error* {s}\n", .{@errorName(b.*)}),
    }

    try print("Labelled Blocks\n");

    const count = blk: {
        var sum: i32 = 0;
        var k: i32 = 0;
        while (k < 10) : (k += 1) sum += k;
        break :blk sum;
    };

    try printformat("{d}\n", .{count});

    try print("While return\n");

    i = 0;
    const val = while (i < 5) : (i += 1) {
        if (i == 1) break i;
    } else 10;

    try printformat("{d}\n", .{val});

    try print("OrElse null\n");

    const nullable: ?i32 = null;
    const notnullable = nullable orelse 0;

    try printformat("{d}\n", .{notnullable});

    try print("While null\n");

    i = 5;

    while (eventuallyNull(i)) |valu| : (i -= 1) {
        try printformat("{d}", .{valu});
    }
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

fn eventuallyNull(i: i32) ?i32 {
    if (i == 0) return null;
    return i - 1;
}
test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
