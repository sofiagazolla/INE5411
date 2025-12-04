# Laboratório 8
# Exercício 2

.data
	MAX:   	.word 5          	# basta alterar esse valor para mudar a dimensão da matriz
	BLOCK_SIZE:  	.word 2		# tamanho do bloco (parametrizável também)

	# para alterar o space para exatamente o tamanho da matriz, basta seguir a fórmula ao lado do valor
	A:  		.space 100		# (MAX * MAX * 4)
	B:  		.space 100		# (MAX * MAX * 4)
 
	espaco: 	.asciiz " "
	quebra:     .asciiz "\n"

.text
main:
    	lw   	$s0, MAX         	# carrega o valor MAX -> dimensão da matriz
    	lw   	$s7, BLOCK_SIZE	# carrega o tamanho do bloco -> block_size
    	la   	$s1, A           	# ponteiro para matriz A  
    	la   	$s2, B           	# ponteiro para matriz B

    	jal	preenche_matriz 	# função que preenche as duas matrizes

    	li   	$t0, 0           	# i = 0

for_i:
    	bge  	$t0, $s0, fim_i	# verifica se já percorreu todas as linhas (i < MAX)
    	li   	$t1, 0			# j = 0

for_j:
    	bge  	$t1, $s0, fim_j	# verifica se já percorreu todas as colunas (j < MAX)

    	# --- início dos loops internos do bloco ---
    	move 	$t2, $t0		# ii = i

for_ii:
    	add  	$t8, $t0, $s7		# limite do bloco: i + block_size
    	bge  	$t2, $t8, fim_ii	# sai do bloco se ii >= i + block_size
    	bge  	$t2, $s0, fim_ii	# evita ultrapassar o tamanho da matriz

    	move 	$t3, $t1		# jj = j

for_jj:
    	add  	$t9, $t1, $s7		# limite do bloco: j + block_size
    	bge  	$t3, $t9, fim_jj	# sai do bloco se jj >= j + block_size
    	bge  	$t3, $s0, fim_jj	# evita ultrapassar o tamanho da matriz

    	# --- endereço A[ii][jj] ---
    	mul  	$t4, $t2, $s0		# linha_atual * total_colunas
    	add  	$t4, $t4, $t3		# + coluna_atual
    	sll  	$t4, $t4, 2		# *4 bytes
    	add  	$t5, $s1, $t4		# endereço base A + deslocamento
    	lwc1 	$f0, 0($t5)		# carrega A[ii][jj]

    	# --- endereço B[jj][ii] (transposta) ---
    	mul  	$t6, $t3, $s0		# linha (jj) * total_colunas
    	add  	$t6, $t6, $t2		# + coluna (ii)
    	sll  	$t6, $t6, 2
    	add  	$t7, $s2, $t6		# endereço base B + deslocamento
    	lwc1 	$f1, 0($t7)		# carrega B[jj][ii]

    	# --- soma e salva ---
    	add.s 	$f2, $f0, $f1
    	swc1  	$f2, 0($t5)		# salva em A[ii][jj]

    	addi 	$t3, $t3, 1		# jj++
    	j    	for_jj

fim_jj:
    	addi 	$t2, $t2, 1		# ii++
    	j    	for_ii

fim_ii:
    	add  	$t1, $t1, $s7		# j += block_size
    	j    	for_j

fim_j:
    	add  	$t0, $t0, $s7		# i += block_size
    	j    	for_i

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
