const std = @import("std");
const print = std.debug.print;
const fmt = std.fmt;
const testing = std.testing;
const mem = std.mem;

fn getChar(i: u8) u8 {
    return if (i < 33 or i == 127) ' ' else i;
}

fn tableRows() [32][4]u8 {
    var rows: [32][4]u8 = undefined;
    var i: u8 = 0;
    while (i <= 31) : (i += 1) {
        rows[i][0] = i;
        rows[i][1] = i + 32;
        rows[i][2] = i + 64;
        rows[i][3] = i + 96;
    }
    return rows;
}

fn bodyRow(allocator: mem.Allocator, tableRow: [4]u8) ![]const u8 {
    var formattedBlocks: [4][]const u8 = undefined;
    for (tableRow) |n, i| {
        formattedBlocks[i] = try formatBlock(allocator, n);
    }
    return try mem.join(allocator, " | ", formattedBlocks[0..]);
}

fn headerRow() []const u8 {
    return ("Dec  Hex  Oct  C" ++ " | ") ** 3 ++ "Dec  Hex  Oct  C";
}

fn formatBlock(allocator: mem.Allocator, n: u8) ![]const u8 {
    return try fmt.allocPrint(
        allocator,
        "{d:>3} {x:>4} {o:>4}  {c}",
        .{ n, n, n, getChar(n) },
    );
}

fn asciiTable(allocator: mem.Allocator) ![]const u8 {
    var formattedTableRows: [33][]const u8 = undefined;
    formattedTableRows[0] = headerRow();
    for (tableRows()) |row, i| {
        formattedTableRows[i + 1] = try bodyRow(allocator, row);
    }
    return try mem.join(allocator, "\n", formattedTableRows[0..]);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    print("{s}\n", .{asciiTable(allocator)});
}

test "create body row" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const expOne = "  0    0    0    |  32   20   40    |  64   40  100  @ |  96   60  140  `";
    const expTwo = " 22   16   26    |  54   36   66  6 |  86   56  126  V | 118   76  166  v";

    const exampleOneResult = try bodyRow(allocator, [_]u8{ 0, 32, 64, 96 });
    const exampleTwoResult = try bodyRow(allocator, [_]u8{ 22, 54, 86, 118 });

    try testing.expectEqualStrings(expOne, exampleOneResult);
    try testing.expectEqualStrings(expTwo, exampleTwoResult);
}

test "format block" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const one = "  0    0    0   ";
    const two = " 32   20   40   ";
    const three = " 64   40  100  @";

    const blockOne = try formatBlock(allocator, 0);
    const blockTwo = try formatBlock(allocator, 32);
    const blockThree = try formatBlock(allocator, 64);

    try testing.expectEqualStrings(one, blockOne);
    try testing.expectEqualStrings(two, blockTwo);
    try testing.expectEqualStrings(three, blockThree);
}

test "getting table rows" {
    const expRows = [4][4]u8{
        [_]u8{ 0, 32, 64, 96 },
        [_]u8{ 1, 33, 65, 97 },
        [_]u8{ 2, 34, 66, 98 },
        [_]u8{ 3, 35, 67, 99 },
    };

    // We just test just the first 4 rows.
    const rows = tableRows()[0..4];

    try testing.expectEqual(expRows, rows.*);
}

test "getting character from u8" {
    try testing.expect(getChar(0) == ' ');
    try testing.expect(getChar(31) == ' ');
    try testing.expect(getChar(65) == 'A');
    try testing.expect(getChar(126) == '~');
    try testing.expect(getChar(127) == ' ');
}
