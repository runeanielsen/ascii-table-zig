const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const heap = std.heap;
const ArrayList = std.ArrayList;
const ArenaAllocator = heap.ArenaAllocator;

fn getChar(i: u8) u8 {
    return switch (i) {
        32...126 => i,
        else => ' ',
    };
}

fn getBodyRow(allocator: mem.Allocator, i: u8) ![]const u8 {
    var list = ArrayList(u8).init(allocator);
    var j: u8 = 0;
    while (j < 4) : (j += 1) {
        const y = i + j * 32;
        const columns = try fmt.allocPrint(allocator, "{d:>3} {o:>4} {x:>4}  {c}", .{ y, y, y, getChar(y) });
        try list.appendSlice(columns);
        if (j < 3) {
            try list.appendSlice(" | ");
        }
    }

    return list.items;
}

fn getHeaderRow() []const u8 {
    const header = "Dec  Hex  Oct  C";
    return (header ++ " | ") ** 3 ++ header;
}

pub fn main() anyerror!void {
    var arena = ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const header_row = getHeaderRow();
    print("{s}\n", .{header_row});

    var i: u8 = 0;
    while (i < 32) : (i += 1) {
        const body_row = try getBodyRow(allocator, i);
        print("{s}\n", .{body_row});
    }
}
