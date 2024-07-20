const std = @import("std");

const Value = @import("engine.zig").Value;
const Neuron = @import("nn.zig").Neuron;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;
const info = std.log.info;

pub fn main() !void {
    const n = try Neuron.create(2, true);
    defer n.deinit();

    var a = Value.create(1);
    var b = Value.create(-2);
    var values = ArrayList(*Value).init(allocator);
    defer values.deinit();
    try values.append(&a);
    try values.append(&b);

    var y = n.forward(values);
    try y.backward();
    y.print();
}
