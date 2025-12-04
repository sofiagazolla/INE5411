# Laboratório 8
# Exercício 1

.data
	MAX:   	.word 5 	# basta alterar esse valor para mudar a dimensão da matriz

	# para alterar o space para exatamente o tamanho da matriz, basta seguir a fórmula ao lado do valor
	A:  		.space 100	# (MAX * MAX * 4)
	B:  		.space 100	# (MAX * MAX * 4)
 
	espaco: 	.asciiz " "
	quebra:       .asciiz "\n"

.text

main:
    	lw   	$s0, MAX         	# carrega o valor MAX -> dimensão da matriz
    	la   	$s1, A           	# ponteiro para matriz A  
    	la   	$s2, B           	# ponteiro para matriz B

    	jal	preenche_matriz 	# função que preenche a matriz

    	li   	$t0, 0           	# i = 0

for_i:

    	bge  	$t0, $s0, fim_i	# verifica se já percorreu todas as linhas, comparando i com MAX
    	li   	$t1, 0			# j = 0

for_j:
    	bge  	$t1, $s0, fim_j	# verifica se já percorreu todas as colunas, comparando j com MAX

    	# --- endereço A[i][j] ---
    	mul  	$t2, $t0, $s0		# faz linha_atual * total_colunas
    	add  	$t2, $t2, $t1		# resultado + coluna atual
    	sll  	$t2, $t2, 2		# *4, pq estamos lidando c bytes
    	add  	$t3, $s1, $t2		# adiciona o offset ao endereço base da matriz para obter o endereço do elemento A[i][j]

    	lwc1 	$f0, 0($t3)          # carrega A[i][j]

    	# --- endereço B[j][i] ---
    	mul  	$t4, $t1, $s0		# coluna_atual * total_linhas
    	add  	$t4, $t4, $t0		# resultado + linha_atual
    	sll  	$t4, $t4, 2		# *4, pq estamos lidando c bytes
    	add  	$t5, $s2, $t4		# adiciona o offset ao endereço base da matriz para obter o endereço do elemento B[j][i]

    	lwc1 	$f1, 0($t5)          # carrega B[j][i]

    	# --- soma e salva ---
    	add.s 	$f2, $f0, $f1		# soma os dois elementos
    	swc1  	$f2, 0($t3)		# armazena eles em A[i][j] (no endereço já calculado com o offset)

    	addi 	$t1, $t1, 1		# incrementa j 
    	j    	for_j			# repete o for do j

fim_j:
    	addi 	$t0, $t0, 1		# incrementa i
    	j    	for_i			# repete o for do i 

fim_i:

	#j	fim_print_i		# descomentar essa linha para não printar a matriz no terminal

    	li   	$t0, 0			# i = 0

print_i:

    	bge  	$t0, $s0, fim_print_i	# verifica se já percorreu todas as linhas, comparando i com MAX
    	li   	$t1, 0				# j = 0
    	
print_j:
    	bge  	$t1, $s0, fim_print_j	# verifica se já percorreu todas as colunas, comparando j com MAX

	# calcula o deslocamento para pegar o elemento correto em A
	# o deslocamento é calculado exatamente da mesma maneira que é antes, pois queremos A[i][j]
    	mul  	$t2, $t0, $s0
    	add  	$t2, $t2, $t1
    	sll  	$t2, $t2, 2
    	add  	$t3, $s1, $t2

    	lwc1 	$f12, 0($t3)	# carrega o elemento no registrador que passa o argumento para $v0
    	
    	li   	$v0, 2       	# syscall para imprimir float
    	syscall

    	li   	$v0, 4		# sycall para imprimir string
    	la   	$a0, espaco	# adiciona um espaço entre os números
    	syscall

    	addi 	$t1, $t1, 1	# incrementa j 
    	j    	print_j	# repete o laço

fim_print_j:

    	li   	$v0, 4		# syscall para imprimir string
    	la   	$a0, quebra	# quebra a linha
    	syscall

    	addi 	$t0, $t0, 1	# incrementa i
    	j    	print_i	# repete o laço

fim_print_i:

    	li   $v0, 10		# syscall para encerrar o programa
    	syscall

# função que preenche a matriz
# baseada no código desenvolvido para o laboratório 4
preenche_matriz:

	# basta mexer nos valores carregados em $t3 e $t4 para alterar o preenchimento da matriz
	# $t3 preenche a matriz A de maneira crescente e $t4 preenche B de maneira decrescente
    	li 	$t3, 1         # acumulador para A
    	li 	$t4, 20        # acumulador para B

    	li 	$t0, 0         # i = 0

loop_linhas:

    	bge 	$t0, $s0, fim_preenche	# verifica se já percorreu todas as linhas, comparando i com MAX
    	li 	$t1, 0         		# j = 0  

loop_colunas:

    	bge 	$t1, $s0, prox_linha	# verifica se já percorreu todas as colunas, comparando j com MAX

	# calcula o deslocamento
    	mul 	$t2, $t0, $s0		# faz linha_atual * total_colunas
    	add 	$t2, $t2, $t1		# resultado + coluna_atual
    	sll 	$t2, $t2, 2		# *4, pq estamos lidando com bytes

    	# matriz A -> A[i][j]
    	add 	$t5, $s1, $t2 	# adiciona o offset ao endereço base da matriz para obter o endereço do elemento A[i][j]

    	mtc1 	$t3, $f0             # move acumulador (int) para f0
    	cvt.s.w $f0, $f0           	# converte para float antes de armazenar (como a matriz é de números de ponto flutuante)
    	swc1 	$f0, 0($t5)          # salva o elemento final em A

    	addi 	$t3, $t3, 1          # incrementa o acumulador de A

    	# matriz B -> B[i][j]
    	add 	$t6, $s2, $t2        # adiciona o offset ao endereço base da matriz para obter o endereço do elemento B[i][j]

    	mtc1 	$t4, $f1             # move acumulador (int) para f1
    	cvt.s.w $f1, $f1		# converte para float antes de armazenar (como a matriz é de números de ponto flutuante)
    	swc1 	$f1, 0($t6)          # salva o elemento final em B

    	subi 	$t4, $t4, 1          # incrementa o acumulador de B

    	addi 	$t1, $t1, 1		# incrementa j 
    	j 	loop_colunas		# repete o laço

prox_linha:
    	addi 	$t0, $t0, 1		# incrementa i 
    	j 	loop_linhas		# repete o laço

fim_preenche:
    	jr 	$ra 	# volta para o main depois de preencher as duas matrizes completamente
