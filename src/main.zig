const std = @import("std");
const Value = @import("engine.zig").Value;
const Neuron = @import("nn.zig").Neuron;



pub fn main() !void {
    _ = try Neuron.create(10,true);
}