const std = @import("std");
const Value = @import("engine.zig").Value;

pub fn main() !void {
    var a = Value.create(1);
    var b = Value.create(2);
    var c = a.multiply(&b);
    var d = Value.create(1);
    var e = c.add(&d);

    try e.backward();
    e.print();
    b.print();
    a.print();
}