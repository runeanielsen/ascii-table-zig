const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const heap = std.heap;
const ArrayList = std.ArrayList;
const ArenaAllocator = heap.ArenaAllocator;

fn getChar(i: u8) u8 {
    if (i < 33 or i == 127) {
        return ' ';
    } else {
        return i;
    }
}

fn getBodyRow(allocator: mem.Allocator, i: usize) ![]const u8 {
    var list = ArrayList(u8).init(allocator);

    var j: usize = 0;
    while (j < 4) : (j += 1) {
        const y = i + j * 32;

        const columns = try fmt.allocPrint(
            allocator,
            "{d:>3} {o:>4} {x:>4}  {c}",
            .{ y, y, y, getChar(@intCast(u8, y)) });

        try list.appendSlice(columns);

        if (j < 3) {
            try list.appendSlice(" | ");
        }
    }

    try list.append('\n');

    return list.items;
}

fn getHeaderRow() []const u8 {
    const header = "Dec  Hex  Oct  C";
    return (header ++ " | ") ** 3 ++ header ++ "\n";
}

fn getAsciiTable(allocator: mem.Allocator) ![]const u8 {
    var list = ArrayList(u8).init(allocator);

    const header_row = getHeaderRow();
    try list.appendSlice(header_row);

    var i: usize = 0;
    while (i < 32) : (i += 1) {
        const body_row = try getBodyRow(allocator, i);
        try list.appendSlice(body_row);
    }

    return list.items;
}

pub fn main() anyerror!void {
    var arena = ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const ascii_table = try getAsciiTable(allocator);
    print("{s}", .{ascii_table});
}
