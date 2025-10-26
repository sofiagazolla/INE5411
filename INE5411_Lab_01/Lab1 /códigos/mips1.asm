# Laboratório 1
# Exercício 1 - Atividades via Console

.data
	
	# Variáveis
	a: .word 1
	b: .word -5
	c: .word 6
	x0: .word 0
	x1: .word 0
.text

	main:
	
#---------------- Carrega as variáveis nos registradores ---------------- #	
	lw 	$s0, a 	# 1
	lw	$s1, b 	# -5
	lw	$s2, c 	# 6
	
#---------------- Realiza o cálculo do delta ---------------- #	
	
	mul 	$t0, $s1, $s1 	# b ^ 2
	mul 	$t1, $s0, $s2 	# a * c
	mul 	$t2, $t1, 4 	# 4 * a * c 
	sub	$t3, $t0, $t2 	# (b ^ 2) - (4 * a * c)
	
#---------------- Calcula a raiz quadrada de delta ---------------- #	
	
	li	$t4, 0 	# é um contador que testa se esse número é a raiz quadrada (é incrementado a cada repetição)
	
	loop:
		mul 	$t5, $t4, $t4 	# eleva o valor de $t4 ao quadrado
		bgt	$t5, $t3, done 	# verifica se $t5 é maior que $t3 (se for, sai do loop)
		addi	$t4, $t4, 1 	# incrementa o contador
		j	loop 		# volta para testar o próximo valor
	done:
		subi 	$t3, $t4, 1	# subtrai 1 da verificação 
	
#---------------- Calcula as raízes ---------------- #	
	
	sub	$t4, $zero, $s1	# -b 
	sll 	$t5, $s0, 1 	# 2 * a
	
	# X0 = (-b + √delta) / 2 * a
	add 	$t6, $t4, $t3 	# b + delta 
	div  	$t6, $t5		# divide por 2a
	mflo 	$t0       	# quociente vai pra $t0
	
	# X1 = (-b - √delta) / 2 * a
	sub 	$t7, $t4, $t3 	# b - delta
	div  	$t7, $t5 		# divide por 2a
	mflo 	$t1 		# quociente vai pra $t1

#---------------- Armazena os resultados na memória ---------------- #
	
	sw	$t0, x0	# salva o resultado na variável x0 na memória	
	sw	$t1, x1	# salva o resultado na variável x1 na memória
