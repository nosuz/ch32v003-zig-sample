# define STORE    sw
# define LOAD     lw
# define LOG_REGBYTES 2
#define REGBYTES (1 << LOG_REGBYTES)

/* default entry point */

.section .init, "ax"
.global _start

_start:
    // CH32V003 starts from 0x0000_0000.
    lui ra, %hi(_abs_start)
    jr %lo(_abs_start)(ra)

_abs_start:
    /* interrupts must be disabled by default
    csrw mie, 0 // interrupt disable
    csrw mip, 0 // no pending interrupts

    // set interrupts trap vec.
    la      t0, _start_trap
    csrw    mtvec, t0
    */

    // set global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // set stack pointer
    la sp, _stack_start

copy_data:
    // copy data section to RAM
    la a0, _sdata_lma
    la a1, _sdata
    la a2, _data_length
    beqz a2, copy_done

copy_data_loop:
    // copy data
    lw a3, 0(a0)
    sw a3, 0(a1)

    addi a0, a0, 4
    addi a1, a1, 4

    addi a2, a2, -4
    bnez a2, copy_data_loop
copy_done:

clear_bss:
    # clear data and bss section
    li t0, 0
    la t1, _sbss
    la t2, _ebss
    beq t1, t2, clear_bss_done
clear_bss_loop:
    sw t0, 0(t1)
    addi t1, t1, 4
    bne t1, t2, clear_bss_loop
clear_bss_done:

    // Set frame pointer
    add s0, sp, zero

    // start main
    jal zero, main
