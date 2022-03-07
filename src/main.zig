const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const ArrayList = std.ArrayList;

fn get_char(i: u8) u8 {
    return switch (i) {
        32...126 => i,
        else => ' ',
    };
}

fn get_body_row(allocator: mem.Allocator, i: u8) ![]const u8 {
    var list = ArrayList(u8).init(allocator);
    var j: u8 = 0;
    while (j < 4) : (j += 1) {
        const y = i + j * 32;
        const columns = try fmt.allocPrint(allocator, "{d:>3} {o:>4} {x:>4}  {c} | ", .{ y, y, y, get_char(y) });
        try list.appendSlice(columns);
    }
    return list.items;
}

fn get_header_row() []const u8 {
    return ("Dec  Hex  Oct  C" ++ " | ") ** 4;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const header_row = get_header_row();
    print("{s}\n", .{header_row});

    var i: u8 = 0;
    while (i < 32) : (i += 1) {
        const body_row = try get_body_row(allocator, i);
        print("{s}\n", .{body_row});
    }
}
