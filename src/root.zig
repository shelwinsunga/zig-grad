const std = @import("std");
const testing = std.testing;
const Value = @import("engine.zig").Value;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "Value creation" {
    const v = Value.create(5.0);
    try testing.expectEqual(v.data, 5.0);
    try testing.expectEqual(v.grad, 0.0);
    try testing.expect(v.children.self == null);
    try testing.expect(v.children.other == null);
    try testing.expect(v.operand == null);
}

test "Value addition" {
    var a = Value.create(2.0);
    var b = Value.create(3.0);
    const c = a.add(&b);
    try testing.expectEqual(c.data, 5.0);
    try testing.expectEqual(c.grad, 0.0);
    try testing.expect(c.children.self == &a);
    try testing.expect(c.children.other == &b);
    try testing.expect(c.operand.? == '+');
}

test "Value multiplication" {
    var a = Value.create(2.0);
    var b = Value.create(3.0);
    const c = a.multiply(&b);
    try testing.expectEqual(c.data, 6.0);
    try testing.expectEqual(c.grad, 0.0);
    try testing.expect(c.children.self == &a);
    try testing.expect(c.children.other == &b);
    try testing.expect(c.operand.? == '*');
}

test "Value power" {
    var a = Value.create(2.0);
    const b = a.power(3.0);
    try testing.expectEqual(b.data, 8.0);
    try testing.expectEqual(b.grad, 0.0);
    try testing.expect(b.children.self == &a);
    try testing.expect(b.children.other == null);
    try testing.expect(b.operand.? == '^');
}

test "Value ReLU" {
    var a = Value.create(-2.0);
    const b = a.relu();
    try testing.expectEqual(b.data, 0.0);
    try testing.expectEqual(b.grad, 0.0);
    try testing.expect(b.children.self == &a);
    try testing.expect(b.children.other == null);
    try testing.expect(b.operand.? == 'r');

    var c = Value.create(3.0);
    const d = c.relu();
    try testing.expectEqual(d.data, 3.0);
}

test "Backpropagation" {
    // Create input values
    var a = Value.create(2.0);
    var b = Value.create(3.0);
    var c = Value.create(4.0);

    // Build a more complex computational graph
    var x1 = a.multiply(&b);  // x1 = a * b = 2 * 3 = 6
    var x2 = x1.add(&c);      // x2 = (a * b) + c = 6 + 4 = 10
    var x3 = a.power(2);      // x3 = a^2 = 2^2 = 4
    var x4 = x3.multiply(&b); // x4 = (a^2) * b = 4 * 3 = 12
    var x5 = x2.add(&x4);     // x5 = ((a * b) + c) + ((a^2) * b) = 10 + 12 = 22
    var y = x5.relu();        // y = ReLU(22) = 22

    // Perform backpropagation
    try y.backward();

    // Define a small epsilon for floating-point comparisons
    const epsilon = 0.0001;

    // Check final output
    try testing.expectApproxEqAbs(y.data, 22.0, epsilon);
    try testing.expectApproxEqAbs(y.grad, 1.0, epsilon);

    // Check intermediate values and gradients
    try testing.expectApproxEqAbs(x5.data, 22.0, epsilon);
    try testing.expectApproxEqAbs(x5.grad, 1.0, epsilon);

    try testing.expectApproxEqAbs(x2.data, 10.0, epsilon);
    try testing.expectApproxEqAbs(x2.grad, 1.0, epsilon);

    try testing.expectApproxEqAbs(x4.data, 12.0, epsilon);
    try testing.expectApproxEqAbs(x4.grad, 1.0, epsilon);

    try testing.expectApproxEqAbs(x1.data, 6.0, epsilon);
    try testing.expectApproxEqAbs(x1.grad, 1.0, epsilon);

    try testing.expectApproxEqAbs(x3.data, 4.0, epsilon);
    try testing.expectApproxEqAbs(x3.grad, 3.0, epsilon);

    // Check gradients of input values
    try testing.expectApproxEqAbs(a.grad, 15.0, epsilon);
    try testing.expectApproxEqAbs(b.grad, 6.0, epsilon);
    try testing.expectApproxEqAbs(c.grad, 1.0, epsilon);
}