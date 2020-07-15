.text 
	 j jaddr
	 addi $t1, $zero, 42
	 add $t1, $t2, $t3
jaddr:   jal jaladdr
	 addi $t2, $zero, 32
	 sll $t2, $zero, 2
jaladdr: sw $t1, 100
