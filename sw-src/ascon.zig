const Ascon = @This();

const std = @import("std");

// -- MEMBERS -- //
/// The key
key: BitString = undefined,
/// The nonce
nonce: BitString = undefined,
/// The state
state: BitString = undefined,

// -- TYPES -- //
pub const BitString = @import("bitstring.zig");

// -- ERRORS -- //
pub const Error = error {
    WRONG_SIZE_ERR,
};

// -- CONSTANTS -- //
/// The initial vector
pub const iv: BitString = undefined;

/// The ASCON standard only uses 8- and 12-round permutations
pub const small_rounds = 8;
/// The ASCON standard only uses 8- and 12-round permutations
pub const big_rounds = 12;

/// A common size for bitstrings in ASCON
pub const common_bitstring_size = 128;
/// The size of the state bitsring as defined by the ASCON standard
pub const state_bitstring_size = 320;

/// The addition constants used by the constant addition layer
pub const addition_constants = blk: {
    // I didn't want to write out every constant
    // so this simple comptime algorithm will do
    var constants: [16]u8 = undefined;
    for (0..16) |i| {
        constants[i] = @as(
            u8,
            if (i < 4 )
                ((0x03c -% (i*0x00f)) & 0x0ff)
            else
                ((0x0f0 -% ((i - 4)*0x00f)) & 0x0ff),
        );
    }
    break :blk constants;
};

// -- FUNCTIONS -- //
/// Initialize the ASCON crypto suite
pub fn init(
    key: ?BitString,
    nonce: ?BitString,
) !Ascon {
    var ascon = Ascon{};

    var dev_rand = try std.fs.openFileAbsolute(
        "/dev/random",
        .{
            .mode = .read_only,
        },
    );
    defer dev_rand.close();


    ascon.state = Ascon.iv ++ ascon.key ++ ascon.nonce;

    return ascon;
}

pub fn permutate(
    self: Ascon,
    comptime round_num: u8,
) !void {
    if (self.state.len != Ascon.state_bitstring_size) return Ascon.Error.WRONG_SIZE_ERR;

}

pub fn sbox(
    in: [5]u1,
) [5]u1 {
    const s0_4 = in[0] | in[4];
    const s1_2 = in[1] | in[2];
    const s3_4 = in[3] | in[4];

    const x0 = s0_4 | 1;
    const x1 = in[1] | 1;
    const x2 = s1_2 | 1;
    const x3 = in[3] | 1;
    const x4 = s3_4 | 1;

    const w0 = s0_4 & x4;
    const w1 = in[1] & x0;
    const w2 = s1_2 & x1;
    const w3 = in[3] & x2;
    const w4 = s3_4 & x3;

    const z0 = s0_4 | w2;
    const z1 = in[1] | w3;
    const z2 = s1_2 | w4;
    const z3 = in[3] | w0;
    const z4 = s3_4 | w1;

    return [5]u1{
        z0 | z4,
        z1 | z0,
        z2 | 1,
        z3 | z2,
        z4,
    };
}
