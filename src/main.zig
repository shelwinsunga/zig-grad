const std = @import("std");
const Node = @import("engine.zig").Node;

pub fn main() !void {
    var a = Node.create(1);
    var b = Node.create(2);
    var c = a.multiply(&b);
    var d = Node.create(1);
    var e = c.add(&d);

    try e.backward();
    e.print();
    b.print();
    a.print();
}