const std = @import("std");
const info = std.log.info;

const Node = struct {
    value: f32,
    grad: f32,
    children: struct {
        self: ?*const Node,
        other: ?*const Node,
    },
    operand: ?u8,
    label: ?[]const u8,

    pub fn init(value: f32, grad: f32, children: ?struct { ?*const Node, ?*const Node }, operand: ?u8, label: ?[]const u8) Node {
        return Node{ 
            .value = value, 
            .grad = grad, 
            .operand = operand, 
            .children = if (children) |c| .{
                .self = c[0],
                .other = c[1],
            } else .{
                .self = null,
                .other = null,
            }, 
            .label = label 
        };
    }

    pub fn add(self: *const Node, other: *const Node) Node {
        return Node.init(self.value + other.value, 0.0, .{ self, other }, '+', null);
    }

    pub fn multiply(self: *const Node, other: *const Node) Node {
        return Node.init(self.value * other.value, 0.0, .{ self, other }, '*', null);
    }

    pub fn print(self: Node) void {
        if(self.label) |label| {
            info("Label: {s}, Value: {d}, Grad: {d}", .{label, self.value, self.grad});
        } else {
            info("Value: {d}, Grad: {d}", .{ self.value, self.grad });
        }
        
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

pub fn main() void {
    var a = Node.init(5.0, 0.0, null, null, "a");
    var b = Node.init(2.0, 0.0, null, null, "b");
    var c = a.add(&b);
    var d = c.multiply(&a);

    a.print();
    b.print();
    c.print();
    d.print();
}