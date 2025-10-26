# Laboratório 05 - Exercício 1 -> 2º programa
.data
    	# mensagens de entrada e saída
    	msg_tamanho:      .asciiz "Digite o tamanho do vetor: "
    	msg_numeros_p1:   .asciiz "Digite "
    	msg_numeros_p2:   .asciiz " numeros para o vetor:\n"   
    	msg_procurar:     .asciiz "Digite o numero a procurar: "
    	msg_encontrado:   .asciiz "Numero encontrado\n"
    	msg_nao_enc:      .asciiz "Numero nao encontrado.\n"
    	array_label:      .word 0:100  	# espaço alocado para o vetor (máximo de 100 inteiros)

.text

main:

    	li 	$v0, 4                 	# syscall para imprimir string
    	la 	$a0, msg_tamanho       	# imprime "Digite o tamanho do vetor: "
    	syscall

    	li 	$v0, 5                 	# syscall para ler inteiro
    	syscall                   		# lê o tamanho (scanf("%d", &size);)
    	move 	$s0, $v0             	# move o tamanho do array para $s0


    	li 	$v0, 4                 	# syscall para imprimir string
    	la 	$a0, msg_numeros_p1    	# imprime "Digite "
    	syscall
    
    	li 	$v0, 1                 	# syscall para imprimir int
    	move 	$a0, $s0             	# imprime o tamanho do array
    	syscall
    
    	li 	$v0, 4                 	# syscall para imprimir string
    	la 	$a0, msg_numeros_p2    	# imprime " numeros para o vetor:\n"
    	syscall
    	
    	jal	inicio_loop_leitura
    	
    	li 	$v0, 4             		# syscall para imprimir string    
    	la 	$a0, msg_procurar      	# printf("Digite o numero a procurar: ")
    	syscall

    	li 	$v0, 5                 
    	syscall                   		# scanf("%d)
    	move 	$a1, $v0             	# salva o valor a ser procurado em $a1

    	jal	  inicio_loop_busca 	
    	    	
    	# encerra o programa
    	li 	$v0, 10
    	syscall
    
inicio_loop_leitura:
	
	move 	$t0, $zero                 	# contador do loop (i = 0)
    	la 	$t1, array_label       	# carrega o endereço base do array para $t1

loop_leitura:

    	bge 	$t0, $s0, fim_loop_leitura 	# verifica se i é menor que size (condição do loop)

    	li 	$v0, 5                 	# syscall para ler inteiro
    	syscall                   		# (scanf("%d", &array[i]);) -> lê cada valor que irá para o array
    
    	# armazena o valor lido na posição array[i]
    	sll 	$t2, $t0, 2           	# i * 4
    	add 	$t3, $t1, $t2         	# endereço base + deslocamento
    	sw 	$v0, 0($t3)            	# array[i] = valor inserido

    	addi 	$t0, $t0, 1    		# incrementa i (i++)      
    
    	j 	loop_leitura			# repete o loop pelo tamanho do vetor

fim_loop_leitura:
	
	jr	$ra				# volta para o main
	
inicio_loop_busca:
	
	move 	$a2, $zero                 	# cria a variável found = 0
    	move 	$t0, $zero                 	# inicializa o contador do loop
    
loop_busca:

    	bge 	$t0, $s0, fim_loop_busca 	# se já percorreu todo o array, acaba

	# vai percorrer todos os elementos do array para comparar de 1 em 1 
	
    	mul 	$t2, $t0, 4           	# i * 4
    	add 	$t3, $t1, $t2         	# endereço base + deslocamento
    	lw 	$t4, 0($t3)            	# $t4 = array[i]

    	beq 	$t4, $a1, encontrado  	# se o número atual for igual ao que procuramos, ele foi encontrado

    	addi 	$t0, $t0, 1   		# incrementa o i (i++)       
    
    	j 	loop_busca			# repete o loop

encontrado:
    	li 	$a2, 1                 	# found = 1
    	j 	fim_loop_busca		# break

fim_loop_busca:

    	beqz 	$a2, nao_encontrado  	# se found for 0, não encontramos o número

    	# número foi encontrado
    	li 	$v0, 4             		# syscall para imprimir string       
    	la 	$a0, msg_encontrado       	# printf("Numero encontrado\n")
    	syscall			
    	jr 	$ra				# volta para o main

nao_encontrado:
    	li 	$v0, 4        		# syscall para imprimir string            
    	la 	$a0, msg_nao_enc          	# printf("Numero nao encontrado.\n")
    	syscall
    	
    	# encerra o programa
    	li 	$v0, 10                	
    	syscall
    			