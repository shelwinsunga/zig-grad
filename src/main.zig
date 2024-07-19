const std = @import("std");
const Value = @import("engine.zig").Value;
const Neuron = @import("nn.zig").Neuron;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;


pub fn main() !void {
    const n = try Neuron.create(2,true);
    var a = Value.create(5);
    var b = Value.create(2);
    var values = ArrayList(*Value).init(allocator);
    try values.append(&a);
    try values.append(&b);


    _ = n.forward(values);

}