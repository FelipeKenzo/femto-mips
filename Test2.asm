.text
	la   $t1, label
	addi $t2, $zero, 100
	addi $t3, $zero, 4
	jr   $t1
	slti $t4, $t2, -100
	add  $t2, $t3, $t2
label:  sll  $t5, $t3, 5
	