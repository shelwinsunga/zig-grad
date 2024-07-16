const std = @import("std");
const Node = @import("node.zig").Node;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !void {
    var a = Node.create(1);
    var b = Node.create(2);
    var c = a.multiply(&b);
    var d = Node.create(1);
    var e = c.add(&d);

    e.backward();
    c.multiplyBackward();
    e.print();
}