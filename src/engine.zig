const std = @import("std");

const info = std.log.info;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const ArrayList = std.ArrayList;

pub const Node = struct {
    value: f32,
    grad: f32,
    children: struct {
        self: ?*Node,
        other: ?*Node,
    },
    operand: ?u8,

    pub fn init(value: f32, grad: f32, children: ?struct { ?*Node, ?*Node }, operand: ?u8) Node {
        return Node{ .value = value, .grad = grad, .operand = operand, .children = if (children) |c| .{
            .self = c[0],
            .other = c[1],
        } else .{
            .self = null,
            .other = null,
        } };
    }

    pub fn create(value: f32) Node {
        return Node.init(value, 0.0, null, null);
    }

    pub fn add(self: *Node, other: *Node) Node {
        return Node.init(self.value + other.value, 0.0, .{ self, other }, '+');
    }

    pub fn multiply(self: *Node, other: *Node) Node {
        return Node.init(self.value * other.value, 0.0, .{ self, other }, '*');
    }

    pub fn power(self: *Node, exponent: f32) Node {
        return Node.init(std.math.pow(f32, self.value, exponent), 0.0, .{ self, null }, '^');
    }

    pub fn relu(self: *Node) Node {
        return Node.init(if (self.value < 0) 0 else self.value, 0.0, .{ self, null }, 'r');
    }

    pub fn backward(self: *Node) !void {
        self.grad = 1;
        var topo = try self.buildTopologicalGraph();
        defer topo.deinit();

        for (topo.items) |node| {
            switch (node.operand orelse continue) {
                '+' => node.addBackward(),
                '*' => node.multiplyBackward(),
                '^' => node.powerBackward(),
                'r' => node.reluBackward(),
                else => unreachable,
            }
        }
    }   

    pub fn buildTopologicalGraph(self: *Node) !ArrayList(*Node) {
        var topo = ArrayList(*Node).init(allocator);
        var visited = std.AutoHashMap(*Node, void).init(allocator);
        defer visited.deinit();

        try self.dfs(&topo, &visited);

        std.mem.reverse(*Node, topo.items);
        return topo;
    }

    fn dfs(self: *Node, topo: *ArrayList(*Node), visited: *std.AutoHashMap(*Node, void)) !void {
        if (visited.contains(self)) return;
        try visited.put(self, {});

        if (self.children.self) |child| {
            try child.dfs(topo, visited);
        }
        if (self.children.other) |child| {
            try child.dfs(topo, visited);
        }

        try topo.append(self);
    }

    pub fn addBackward(self: *Node) void {
        const self_child = self.children.self orelse return;
        const other_child = self.children.other orelse return;

        self_child.grad += self.grad;
        other_child.grad += self.grad;
    }

    pub fn multiplyBackward(self: *Node) void {
        const self_child = self.children.self orelse return;
        const other_child = self.children.other orelse return;

        self_child.grad += other_child.value * self.grad;
        other_child.grad += self_child.value * self.grad;
    }

    pub fn powerBackward(self: *Node) void {
        const self_child = self.children.self orelse return;
        const exponent = self.value / self_child.value;
        self_child.grad += exponent * std.math.pow(f32, self_child.value, exponent - 1) * self.grad;
    }

    pub fn reluBackward(self: *Node) void {
        const self_child = self.children.self orelse return;
        self_child.grad += if (self.value > 0) self.grad else 0;
    }

    pub fn negate(self: *Node) Node {
        return self.multiply(&Node.create(-1));
    }

    pub fn subtract(self: *Node, other: *Node) Node {
        return self.add(&other.negate());
    }

    pub fn divide(self: *Node, other: *Node) Node {
        return self.multiply(&other.power(-1));
    }

    pub fn print(self: Node) void {
        info("Value: {d}, Grad: {d}", .{ self.value, self.grad });

        if (self.operand) |op| {
            info("Operand: {c}", .{op});
        }

        if (self.children.self) |child| {
            info("Self: {d}", .{child.value});
        }

        if (self.children.other) |child| {
            info("Other: {d}", .{child.value});
        }
    }
};