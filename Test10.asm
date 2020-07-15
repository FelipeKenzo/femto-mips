.data
    a: .word 10

.text
    lw $t0, a
    bne $t0, $zero, end
    addi $t1, $t0, 2
    sll $t2, $t1, 4
end:
    addi $t1, $zero, 3