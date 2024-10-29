pub const RCC_APB2PCENR = @as(*volatile u32, @ptrFromInt(0x40021018));
pub const GPIOC_CFGLR = @as(*volatile u32, @ptrFromInt(0x40011000));
pub const GPIOC_OUTDR = @as(*volatile u16, @ptrFromInt(0x4001100C));

export fn main() void {
    RCC_APB2PCENR.* |= @as(u32, 1 << 4); // Enable PC clk
    GPIOC_CFGLR.* &= ~@as(u32, 0b1111 << 0); // Clear all bits for PC0
    GPIOC_CFGLR.* |= @as(u32, 0b0011 << 0); // Set push-pull output for PC0

    var loop: u32 = 1;
    while (true) {
        var i: u32 = 0;
        GPIOC_OUTDR.* ^= @as(u16, 1 << 0); // Toggle PC0
        while (i < (1 * 100_000)) { // busy wait
            // i *= 2;
            i += loop;
        }
        loop += 1;
        // loop *= 2;
        if (loop > 100) {
            loop = 1;
        }
    }
}
