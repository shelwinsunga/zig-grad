const std = @import("std");

const info = std.log.info;

const Node = struct {
    value: f32,
    grad: f32,

    pub fn init(value: f32, grad: f32) Node {
        return Node{
            .value = value,
            .grad = grad,
        };
    }

    pub fn add(self: Node, other: Node) Node {
        return Node{
            .value = self.value + other.value,
            .grad = self.grad + other.grad,
        };
    }
};

pub fn main() void {
    const a = Node.init(1.0, 0.0);
    const b = Node.init(2.0, 0.0);

    const c = a.add(b);

    info("Value of a: {d}", .{a.value});
    info("Value of b: {d}", .{b.value});
    info("Value of c: {d}", .{c.value});
}
