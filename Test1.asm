.data
	a: .word 13
	b: .word 15
	c: .word 5
	d: .word 20

.text
	lw 	$t1, a
	lw 	$t2, b
	lw 	$t3, c
	lw   	$t4, d
	add  	$t1, $t1, $t1
	addu 	$t2, $t3, $t2
	slt	$t5, $t3, $t4
	


