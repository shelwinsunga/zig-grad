const std = @import("std");

const info = std.log.info;

const Node = struct {
    value: f32,
    grad: f32,
    operand: ?u8,

    pub fn init(value: f32, grad: f32, operand: ?u8) Node {
        return Node{
            .value = value,
            .grad = grad,
            .operand = operand,
        };
    }

    pub fn add(self: Node, other: Node) Node {
        const output = Node.init(self.value + other.value, 0.0, '+');
        return output;
    }

    pub fn multiply(self: Node, other: Node) Node {
        const output = Node.init(self.value * other.value, 0.0, '*');
        return output;
    }

    pub fn print(self: Node) void {
        if (self.operand) |op| { // unwraps the u8
            info("Value: {d}, Grad: {d}, Operand: {c}", .{ self.value, self.grad, op });
        } else {
            info("Value: {d}, Grad: {d}", .{ self.value, self.grad });
        }
    }
};

pub fn main() void {
    const a = Node.init(5.0, 0.0, null);
    const b = Node.init(2.0, 0.0, null);
    const c = a.add(b);
    const d = c.multiply(a);

    a.print();
    b.print();
    c.print();
    d.print();
}
