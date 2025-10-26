#Laboratório 1
#Exercício 2 - Atividades via Console

.data
	# variáveis
	x0:	.word 0
	x1:	.word 0
	
	# mensagens
	prompt1: .asciiz "Digite o valor de a: "
	prompt2: .asciiz "Digite o valor de b: "
	prompt3: .asciiz "Digite o valor de c: "
	printx0: .asciiz "Primeira raíz: "
	printx1: .asciiz "\nSegunda raíz: "
	
.text
main:

# ---------------------Solicita as variáveis ao usuário-----------------------------------

	li 	$v0, 4		# comando para imprimir string
	la 	$a0, prompt1	# carrega a mensagem de prompt1	
	syscall
	
	# lê e armazena a
	li	$v0, 5		# comando para ler inteiro
	syscall
	move	$s0,$v0	# armazena o input do usuário no registrador $s0
	
	# solicita o valor de b
	li	$v0, 4		# comando para imprimir string
	la	$a0, prompt2	# carrega a mensagem de prompt2
	syscall
	
	# lê e armazena b
	li 	$v0, 5		# comando para ler inteiro
	syscall	
	move	$s1, $v0	# armazena o input do usuário no registrador $s1
	
	# solicita o valor de c
	li	$v0, 4		# comando para imprimir string
	la	$a0, prompt3	# carrega a mensagem de prompt3
	syscall
	
	# lê e armazena c
	li	$v0, 5		# comando para ler inteiro
	syscall
	move	$s2, $v0	# armazena o input do usuário no registrador $s2
	
# ---------------------Calculando delta-----------------------------------	
	
	mul	$t0, $s1, $s1 	# b ^2
	mul	$t1, $s0, $s2		# a * c
	mul	$t2, $t1, 4 		# 4 * a * c
	sub	$t3, $t0, $t2 	# delta
	
# ---------------------Calculando raíz usando loop-----------------------------------	
	
	li 	$t4, 0 		# é um contador que testa se esse número é a raiz quadrada (é incrementado a cada repetição)
	
loop_raiz:

	mul	$t5, $t4, $t4   	# eleva o valor de $t4 ao quadrado
	bgt	$t5, $t3, fim_raiz	# verifica se $t5 é maior que $t3 (se for, sai do loop)
	addi	$t4, $t4, 1		# incrementa o contador
	j	loop_raiz		# volta para testar o próximo valor
	
fim_raiz:
	
	subi 	$t4, $t4, 1 		# subtrai 1 da verificação 
	
# ---------------------Calcula as raízes-----------------------------------

	sub 	$t6, $zero, $s1 	# -b
	
	mul	$t7, $s0, 2 		# 2 * a
	
	# (-b + √delta) / 2 * a
	add	$t8, $t6, $t4 	# -b + √delta
	div	$t8, $t7 	# divisão por 2 * a
	mflo	$t8 		# parte inteira da divisão
	sw	$t8, x0 	# armazena na variável da memória
	
	# (-b - √delta) / 2 * a
	sub	$t9, $t6, $t4 	# -b - √delta
	div	$t9, $t7 	# divisão por 2 * a
	mflo	$t9 		# parte inteira da divisão
	sw	$t9, x1 	# salva na variável da memória
	
# ---------------------Imprimindo resultados-----------------------------------	
	
	# imprime mensagem resultado de x0
	li	$v0, 4 
	la	$a0, printx0
	syscall
	# imprime o resultado da primeira raíz
	li	$v0, 1
	lw	$a0, x0
	syscall
	
	# imprime mensagem resultado de x1
	li	$v0, 4
	la	$a0, printx1
	syscall
	# imprime o resultado da segunda raíz
	li	$v0, 1
	lw	$a0, x1
	syscall