const std = @import("std");
const info = std.log.info;

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

    pub fn backward(self: *Node) void {
        self.grad = 1;
        self.addBackward();
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