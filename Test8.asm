.text
    addi $t0, $zero, 1
    addi $t1, $zero, 0 
    bne  $t0, $zero, end 
    addi $t1, $zero, 2
    add  $t1, $t1, $t1
end:
    addi $t1, $zero, 3
