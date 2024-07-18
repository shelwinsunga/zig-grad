const std = @import("std");

const info = std.log.info;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;
const Value = @import("engine.zig").Value;
const RndGen = std.rand.DefaultPrng;

pub const Neuron = struct {
    weights: ArrayList(*Value),
    bias: Value,
    nonlinear: bool,

    // nin = number of inputs
    pub fn create(nin: u32, nonlinear: bool) !Neuron {
        var weights = ArrayList(*Value).init(allocator);
        var rnd = RndGen.init(0);

        for (0..nin) | i | {
            var weight = Value.create(randomWeight(&rnd, -1, 1));
            try weights.append(&weight);
            info("Weight {d}: {d}", .{ i, weight.value });
        }

        const bias = Value.create(0);

        return Neuron{
            .weights = weights,
            .bias = bias,
            .nonlinear = nonlinear
        };
    }
    
    fn randomWeight(rnd: *RndGen, a: f32, b: f32) f32 {
        return a + (b - a) * rnd.random().float(f32);
    }

};