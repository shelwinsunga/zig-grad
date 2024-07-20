const std = @import("std");

const info = std.log.info;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;
const Value = @import("engine.zig").Value;
const RndGen = std.rand.DefaultPrng;

pub const Neuron = struct {
    weights: *ArrayList(*Value),
    bias: Value,
    nonlinear: bool,

    // nin = number of inputs
    pub fn create(nin: u32, nonlinear: bool) !*Neuron {
        _ = nin;
        const weights = try allocator.create(ArrayList(*Value));
        weights.* = ArrayList(*Value).init(allocator);

        const weight1 = try allocator.create(Value);
        weight1.* = Value.create(0.23550571390294128);
        try weights.append(weight1);

        const weight2 = try allocator.create(Value);
        weight2.* = Value.create(0.06653114721000164);
        try weights.append(weight2);

        info("Weight 0: {d}", .{weight1.data});
        info("Weight 1: {d}", .{weight2.data});

        const bias = Value.create(0);
        const neuron = try allocator.create(Neuron);
        neuron.* = Neuron{ .weights = weights, .bias = bias, .nonlinear = nonlinear };
        return neuron;
    }

    pub fn forward(self: *const Neuron, x: ArrayList(*Value)) Value {
        const weights = self.weights;
        var weighted_sum: f32 = 0;

        for (weights.items, x.items) |wi, xi| {
            weighted_sum += wi.data * xi.data;
        }

        var result = Value.create(weighted_sum);
        if (self.nonlinear) {
            result = result.relu();
        }

        return result;
    }

    fn randomWeight(rnd: *RndGen, a: f32, b: f32) f32 {
        return a + (b - a) * rnd.random().float(f32);
    }

    pub fn deinit(self: *Neuron) void {
        for (self.weights.items) |weight| {
            allocator.destroy(weight);
        }
        self.weights.deinit();
        allocator.destroy(self.weights);
        allocator.destroy(self);
    }
};
