const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const info = std.log.info;

const Node = struct {
    value: f32,
    grad: f32,
    children: struct {
        self: ?*const Node,
        other: ?*const Node,
    },
    operand: ?u8,
    label: []const u8,

    pub fn init(value: f32, grad: f32, children: ?struct { ?*const Node, ?*const Node }, operand: ?u8, label: []const u8) !Node {
        const duplicateLabel = try allocator.dupe(u8, label);
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
            .label = duplicateLabel
        };
    }

    pub fn create(value: f32, label: []const u8) !Node {
        return Node.init(value, 0.0, null, null, label);
    }

    pub fn add(self: *const Node, other: *const Node) !Node {
        const label = try std.fmt.allocPrint(allocator, "{s} + {s}", .{self.label, other.label});
        return Node.init(self.value + other.value, 0.0, .{ self, other }, '+', label);
    }

    pub fn multiply(self: *const Node, other: *const Node) !Node {
        const label = try std.fmt.allocPrint(allocator, "{s} * {s}", .{self.label, other.label});
        return Node.init(self.value * other.value, 0.0, .{ self, other }, '*', label);
    }

    pub fn print(self: Node) void {
        info("Label: {s}, Value: {d}, Grad: {d}", .{self.label, self.value, self.grad});

        if (self.operand) |op| {
            info("Operand: {c}", .{op});
        }
        
        if (self.children.self) |child| {
            info("Self: {s}", .{child.label});
        }
        
        if (self.children.other) |child| {
            info("Other: {s}", .{child.label});
        }
    }

    pub fn deinit(self: *Node) void {
        allocator.free(self.label);
    }

};

pub fn main() !void {
    var a = try Node.create(3, "a");
    defer a.deinit();
    var b = try Node.create(5, "b");
    defer b.deinit();
    var c = try a.add(&b);
    defer c.deinit();
    var d = try c.add(&b);
    defer d.deinit();

    d.print();
}