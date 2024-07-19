const std = @import("std");
const Value = @import("engine.zig").Value;
const Neuron = @import("nn.zig").Neuron;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;


pub fn main() !void {
    const n = try Neuron.create(1,true);
    var a = Value.create(5);
    var values = ArrayList(*Value).init(allocator);
    try values.append(&a);

    _ = n.forward();

}