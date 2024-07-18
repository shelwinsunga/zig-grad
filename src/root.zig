const std = @import("std");
const testing = std.testing;
const Value = @import("engine.zig").Value;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}



test "Value creation" {
    const v = Value.create(5.0);
    try testing.expectEqual(v.value, 5.0);
    try testing.expectEqual(v.grad, 0.0);
    try testing.expect(v.children.self == null);
    try testing.expect(v.children.other == null);
    try testing.expect(v.operand == null);
}


test "Value addition" {
    var a = Value.create(2.0);
    var b = Value.create(3.0);
    const c = a.add(&b);
    try testing.expectEqual(c.value, 5.0);
    try testing.expectEqual(c.grad, 0.0);
    try testing.expect(c.children.self == &a);
    try testing.expect(c.children.other == &b);
    try testing.expect(c.operand.? == '+');
}

test "Value multiplication" {
    var a = Value.create(2.0);
    var b = Value.create(3.0);
    const c = a.multiply(&b);
    try testing.expectEqual(c.value, 6.0);
    try testing.expectEqual(c.grad, 0.0);
    try testing.expect(c.children.self == &a);
    try testing.expect(c.children.other == &b);
    try testing.expect(c.operand.? == '*');
}

test "Value power" {
    var a = Value.create(2.0);
    const b = a.power(3.0);
    try testing.expectEqual(b.value, 8.0);
    try testing.expectEqual(b.grad, 0.0);
    try testing.expect(b.children.self == &a);
    try testing.expect(b.children.other == null);
    try testing.expect(b.operand.? == '^');
}

test "Value ReLU" {
    var a = Value.create(-2.0);
    const b = a.relu();
    try testing.expectEqual(b.value, 0.0);
    try testing.expectEqual(b.grad, 0.0);
    try testing.expect(b.children.self == &a);
    try testing.expect(b.children.other == null);
    try testing.expect(b.operand.? == 'r');

    var c = Value.create(3.0);
    const d = c.relu();
    try testing.expectEqual(d.value, 3.0);
}


test "Value backward pass" {
    var a = Value.create(2.0);
    var b = Value.create(3.0);
    var c = a.multiply(&b);
    var d = c.add(&b);
    try d.backward();

    try testing.expectEqual(d.grad, 1.0);
    try testing.expectEqual(c.grad, 1.0);
    try testing.expectEqual(b.grad, 3.0);
    try testing.expectEqual(a.grad, 3.0);
}
