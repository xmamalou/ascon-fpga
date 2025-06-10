const BitString = @This();

const std = @import("std");

/// The memory block that contains the bitstring
block: []u1,

/// Parse a bitstring into separate blocks
pub inline fn parse(
    self: BitString,
    comptime block_count: u32, // The blocks to generate
) [block_count]BitString {
    const block_size: usize = self.block.len / block_count;
    var blocks: [block_count]BitString = undefined;
    for (0..block_count) |i| {
        blocks[i].block = if (i == block_count - 1)
            self.block[i*block_size..(i+1)*block_size] else
            self.block[i*block_size..self.block.len];
    }

    return blocks;
}

/// Pad a bitstring to the desired length
pub inline fn pad(
    self: BitString,
    allocator: std.mem.Allocator, // The allocator to use
    comptime pad_count: u32, // The new bitstring's length
) !BitString {
    const size = self.block.len + 1 + pad_count;
    var padded_string = try allocator.alloc(
        u1,
        size,
    );

    for (0..padded_string.len) |i| {
        padded_string[i] = if (i < self.block.len)
            self.block[i] else if (i == self.block.len)
            1 else
            0;
    }
}

/// XOR two specific bits of two bytes
pub inline fn xor_at_bits(
    op1: u8,
    comptime op1_bit: u3,
    op2: u8,
    comptime op2_bit: u3,
) u8 {
    const op1_mask = comptime switch (op1_bit) {
        0 => 0b00000001,
        1 => 0b00000010,
        2 => 0b00000100,
        3 => 0b00001000,
        4 => 0b00010000,
        5 => 0b00100000,
        6 => 0b01000000,
        7 => 0b10000000,
    };

    const op2_mask = comptime switch (op2_bit) {
        0 => 0b00000001,
        1 => 0b00000010,
        2 => 0b00000100,
        3 => 0b00001000,
        4 => 0b00010000,
        5 => 0b00100000,
        6 => 0b01000000,
        7 => 0b10000000,
    };

    return (op1 & op1_mask) ^ (op2 & op2_mask);
}

/// AND two specific bits of two bytes
pub inline fn and_at_bits(
    op1: u8,
    comptime op1_bit: u3,
    op2: u8,
    comptime op2_bit: u3,
) u8 {
    const op1_mask = comptime switch (op1_bit) {
        0 => 0b00000001,
        1 => 0b00000010,
        2 => 0b00000100,
        3 => 0b00001000,
        4 => 0b00010000,
        5 => 0b00100000,
        6 => 0b01000000,
        7 => 0b10000000,
    };

    const op2_mask = comptime switch (op2_bit) {
        0 => 0b00000001,
        1 => 0b00000010,
        2 => 0b00000100,
        3 => 0b00001000,
        4 => 0b00010000,
        5 => 0b00100000,
        6 => 0b01000000,
        7 => 0b10000000,
    };

    return (op1 & op1_mask) & (op2 & op2_mask);
}
