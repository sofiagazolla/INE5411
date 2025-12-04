.include "labels.asm"

.data
numeros1: .byte 0x3F,0x06 		# 0, 1
.text

.globl prog2

prog2:

    	la   	$s7, numeros1       	# guarda o endereço base do array
    	li   	$s1, 0xFFFF0011     	# código do display esquerdo (onde vai exibir)
    	li   	$s4, 1000           	# 1000 ms = 1 segundo

    	li   	$v0, 30             	# pega o tempo inicial
    	syscall
    	move 	$s3, $a0             # tempo inicial em ms

inicializa1:

     	move 	$s0, $s7             # reseta o ponteiro ($s0) para o início do array
    	li   	$s2, 0              	# índice do número

loop1:

    	beq  $s2, 2, fim1		# verifica se já processou os 2 elementos (0, 1)

    	# lógica de delay
    	li   	$v0, 30		# pega o tempo novamente
    	syscall
    	move 	$s5, $a0             # tempo atual

    	sub  	$s6, $s5, $s3        # tira a diferença do tempo atual pelo inicial
    	blt  	$s6, $s4, loop1      # espera até passar 1 segundo
    	move 	$s3, $s5             # atualiza tempo inicial

    	# escreve no display
    	lb   	$t7, 0($s0)		# pega o padrão do número do data
    	sb   	$t7, 0($s1)		# passa esse padrão para o display

    	addi 	$s0, $s0, 1          # avança o ponteiro
    	addi 	$s2, $s2, 1          # avança o índice
    	j    	loop1			# repete o loop
    
fim1:
    	j 	inicializa1			# inicia a contagem novamente
