.data
	matriz:	.space 1024
.text

main:
	
	li	$s0, 0			# acumulador 
	li	$s3, 16		# ordem
	la	$a0, matriz		# ponteiro para o endereço
	jal	preencher		# chama a função
	
	li	$v0, 10		# encerra o programa
	syscall
	
preencher:

	li	$s1, 0			# contador de linhas
	
loop_linhas:

	bge	$s1, $s3, fim		# confere se já percorreu todas as linhas
	li	$s2, 0			# contador de colunas

loop_colunas:

	bge	$s2, $s3, proxima_linha	# confere se já percorreu todas as colunas
	
	#offset
	mul	$t0, $s2, $s3		# coluna atual + ordem
	add	$t0, $t0, $s1		# resultado + linha atual
	sll	$t0, $t0, 2		
	
	add	$t1, $a0, $t0		#offset total
	move	$t2, $s0		# move o acumulador pra t2
	sw	$t2, 0($t1)		# armazena na memória
	
	addi	$s0, $s0, 1		# adiciona no acumulador
	addi	$s2, $s2, 1		# incrementa no numero de colunas
	
	j	loop_colunas		# repete o loop de colunas
	
proxima_linha:

	addi	$s1, $s1, 1		# incrementa contador de linhas
	j	loop_linhas		# repete o loop de linhas
	
fim:
	
	jr	$ra			# volta para o main