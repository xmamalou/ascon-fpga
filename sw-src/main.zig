const std = @import("std");
const proc = std.process;

const stdout = std.io.getStdOut().writer();

const Ascon = @import("ascon.zig");
const BitString = Ascon.BitString;

pub fn main() !void {
    const ascon_inst = try Ascon.init(null, null);
    try stdout.print(
        "The generated key is {any}\nThe generated nonce is {any}\n",
        .{
            ascon_inst.key,
            ascon_inst.nonce,
        },
    );

    return;
}
