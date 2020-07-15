.text
	addi $t1, $zero, 89
	bne  $zero, $zero, bra1
	addi $t2, $zero, 32
	bne  $t1, $zero, bra1
	addi $t3, $zero, 123
	sll  $t1, $t1, 3
bra1:	beq  $t1, $t2, bra2
	beq  $t3, $t3, bra2
	slt  $t2, $t2, $t3
	addi $t3, $t4, 90 
bra2:   addi $t5, $zero, 400