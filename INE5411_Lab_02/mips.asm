.data
# Matrizes -----------------------------------------	
matriz_resultado: .space 36	# reserva espaço para uma matriz quadrada de ordem 3 (9 inteiros = 36 bytes)
    
matriz_transposta: .space 36	# reserva espaço para uma matriz quadrada de ordem 3 (9 inteiros = 36 bytes)
    
# Declara e inicializa as matrizes que serão operadas
matriz_a: 	.word 1, 2, 3
              	.word 0, 1, 4
              	.word 0, 0, 1
    
matriz_b: 	.word 1, -2, 5
              	.word 0, 1, -4
              	.word 0, 0, 1           	
#-----------------------------------------------------------------------------------------------------------------------------------------------------#    	
       
       prompt: 	.asciiz "Insira um nome para o arquivo: "	# string para pedir o nome do arquivo
	nome: 		.space 104   				# espaço vazio para guardar o nome (é grande caso o usuário escolha um nome grande)
	buffer:     	.space 12            			# reserva espaço para a conversão da string (máx 11 dígitos + null)

	newline:    	.asciiz "\n" 				# string para quebra de linha
	espaco:      	.asciiz " "				# string para espaço entre números
.text

main:

    	li	$t0, 3               				# ordem das matrizes
    
#-----------------------------------------------------------------------------------------------------------------------------------------------------#
	
	la	$a0, matriz_a			# ponteiro para a matriz A 
	la	$a1, matriz_b			# ponteiro para a matriz B
	la	$a2, matriz_transposta		# ponteiro para a matriz transposta
	la	$a3, matriz_resultado		# ponteiro para a matriz resultado
	
#-----------------------------------------------------------------------------------------------------------------------------------------------------#
	
	jal	PROC_MUL			# chama função da multiplicação (não folha), que chama a função da transposta dentro dela (folha)
	jal	PROC_NOME 			# chama a função para a escrita do arquivo .txt

#--------------------------------- ARQUIVO ---------------------------------------------------------------------------------------------------------#

    	# abre o arquivo
    	li 	$v0, 13              		# syscall 13 serve para abrir um arquivo
    	la 	$a0, nome           		# recebe o nome do arquivo da string em .data
    	li 	$a1, 1                   	# flag de abertura = 1, significa que vamos escrever no arquivo
    	li 	$a2, 0                   	# modo
    	syscall
    	move 	$s7, $v0               		# retorno de $v0 é o file descriptor (identificação de arquivo aberto)

	# escreve no arquivo
    	jal 	escreve	

	# fecha o arquivo
    	li 	$v0, 16				# syscall 16 serve para fechar um arquivo
    	move 	$a0, $s7			# move o file descriptor
    	syscall
    	
#--------------------------------- FINALIZAÇÃO DO PROGRAMA ---------------------------------------------------------------------------------------------------------#

    	li 	$v0, 10
    	syscall
    	
#--------------------------------- FUNÇÕES ---------------------------------------------------------------------------------------------------------#
	
#---------------------------------- NOME ---------------------------------------------------------------------------------------------------------#	

PROC_NOME:
	
	# pede pra inserir o nome 
	li	$v0, 4		# syscall para imprimir string
	la	$a0, prompt	# carrega o prompt
	syscall
	
	# salva como nome do arquivo
	li	$v0, 8		# syscall para ler string
	la	$a0, nome	# carrega o nome
	li	$a1, 104	# tamanho máximo
	syscall
	jr 	$ra		# retorna para o endereço salvo em $ra

#--------------------------------- TRANSPOSTA ---------------------------------------------------------------------------------------------------------#

PROC_TRANS:
	
	addi 	$sp, $sp, -32	 	# aloca espaço para 8 registradores na pilha
	sw	$ra, 28($sp) 		# salva o endereço de retorno na pilha 
	sw   	$s0, 24($sp)		# salva o registrador $s0 na pilha
	sw   	$s1, 20($sp)		# salva o registrador $s1 na pilha
	sw   	$s2, 16($sp)		# salva o registrador $s2 na pilha
	sw   	$s3, 12($sp)		# salva o registrador $s3 na pilha
	sw   	$s4, 8($sp)		# salva o registrador $s4 na pilha
	sw   	$s5, 4($sp)		# salva o registrador $s5 na pilha
	sw   	$s6, 0($sp)		# salva o registrador $s6 na pilha
	
	move  	$s0, $zero    		# inicializa contador de linhas ($s0)

loop_linhas_transposta:

	bge	$s0, $t0, fim_transposta 		# verifica se já percorreu todas as linhas (comparando o contador com a ordem)
    	move  	$s1, $zero    			# inicializa contador de colunas ($s1)

loop_colunas_transposta:

	bge	$s1, $t0, proxima_linha_transposta	# verifica se já percorreu todas as colunas (comparando o contador com a ordem)

	# pega elemento por elemento em B por linha
    	mul 	$t1, $s0, $t0 		# faz linha_atual * total_colunas
    	add   	$t1, $t1, $s1			# resultado + coluna atual
    	sll   	$t1, $t1, 2			# *4, pq estamos lindando c bytes

	add	$t8, $a1, $t1			# adiciona o offset ao endereço base da matriz B para obter o endereço do elemento B[i][j]
	lw	$t2, 0($t8)			# carrega B[i][j]
	
	
	# faz o deslocamento por colunas na transposta p achar a pos certa
	mul	$t3, $s1, $t0			# coluna_atual * total_linhas
	add 	$t3, $t3, $s0			# resultado + linha_atual
	sll	$t3, $t3, 2			# *4, como são bytes
	
	add 	$t9, $a2, $t3			# adiciona o offset ao endereço para achar a posição certa para armazenar o elemento
	sw	$t2, 0($t9)			# armazena o elemento na posição calculada
	
	addi	$s1, $s1, 1			# incrementa o contador de colunas
	j	loop_colunas_transposta	# reinicia o loop de colunas
	
proxima_linha_transposta: 

	addi	$s0, $s0, 1			# incrementa o contador de linhas
	j	loop_linhas_transposta	# reinicia o loop de linhas
	
fim_transposta:

	lw 	$s6, 0($sp)		# restaura o valor de $s6 da pilha  
   	lw 	$s5, 4($sp) 		# restaura o valor de $s5 da pilha
        lw 	$s4, 8($sp)		# restaura o valor de $s4 da pilha
        lw 	$s3, 12($sp)		# restaura o valor de $s3 da pilha
    	lw 	$s2, 16($sp)		# restaura o valor de $s2 da pilha
     	lw 	$s1, 20($sp)		# restaura o valor de $s1 da pilha
        lw 	$s0, 24($sp)		# restaura o valor de $s0 da pilha
    	lw 	$ra, 28($sp)		# restaura o endereço de retorno na pilha 
    	addi 	$sp, $sp, 32		# desaloca o espaço da pilha
    	
	jr 	$ra			# volta para onde parou na função

#--------------------------------- MULTIPLICAÇÃO ---------------------------------------------------------------------------------------------------------#

PROC_MUL:	

	addi $sp, $sp, -36		# aloca espaço para 9 registradores na pilha
	sw   $ra, 32($sp) 		# salva o endereço de retorno na pilha 
	sw   $s0, 28($sp)		# salva o registrador $s0 na pilha
	sw   $s1, 24($sp)		# salva o registrador $s1 na pilha
	sw   $s2, 20($sp)		# salva o registrador $s2 na pilha
	sw   $s3, 16($sp)		# salva o registrador $s3 na pilha
	sw   $s4, 12($sp)		# salva o registrador $s4 na pilha
	sw   $s5, 8($sp)		# salva o registrador $s5 na pilha
	sw   $s6, 4($sp)		# salva o registrador $s6 na pilha
	sw   $s7, 0($sp)		# salva o registrador $s7 na pilha

	move  	$s0, $zero    		# inicializa o contador de linhas ($s0)
	jal	PROC_TRANS		# chama a função que faz a transposta de B
	
loop_linhas_mult:

	bge 	$s0, $t0, fim_multiplicacao		#verifica se já percorreu todas as linhas
	move  	$s1, $zero    				# inicializa o contador de colunas ($s1)

loop_colunas_mult:

	bge	$s1, $t0, fim_colunas		# verfica se já percorreu todas as colunas
	move	$t6, $zero			# inicizaliza um acumulador para calcular cada elemento
	move	$s2, $zero			# inicializa o contador do loop interno 
	
loop_i:
	bge	$s2,$t0, fim_i			# verifica se já percorreu todos os elementos do índice atual
		
#deslocamento em A (por linhas) --------------------------------------------------------------
    	mul 	$t1, $s0, $t0 		# faz linha_atual * total_colunas
    	add   	$t1, $t1, $s2		# resultado + coluna atual
    	sll   	$t1, $t1, 2		# *4, pq estamos lidando com bytes
	add	$t8, $a0, $t1		# calcula o endereço completo do elemento

# deslocamento na transposta (por colunas) ----------------------------------------------------
	mul	$t2, $s2, $t0		# faz indice_atual * total_linhas
	add	$t2, $t2, $s1		# resultado + linha_atual
	sll	$t2, $t2, 2		# *4, pois estamos lidando com bytes
	add	$t9, $a2, $t2		# calcula o endereço completo do elemento na transposta
	
# pega os elementos -----------------------------------------------------------------------------
    	lw    	$t4, 0($t8)   		# pega o elemento de a
    	lw    	$t5, 0($t9)   		# pega o elemento da transposta
    	
    	
# multiplica e acumula -------------------------------------------------------------------------

    	mul 	$t7, $t4, $t5		# multiplica os dois elementos
    	add 	$t6, $t6, $t7		# adiciona o resultado ao acumulador
    	
    	addi	$s2, $s2, 1		# incrementa o contador do índice
    	j	loop_i			# repete o loop
    	
fim_i:

	# faz o deslocamento por linhas para armazenar o elemento no lugar certo
	mul	$t3,$s0, $t0		# faz linha_atual * total_colunas	
	add	$t3, $t3, $s1		# resultado + coluna_atual
	sll	$t3, $t3, 2		# *4, pois estamos lidando com bytes
	add	$t8, $a3, $t3		# calcula o endereço completo do resultado
	
	sw	$t6, 0($t8) 		# armazena o resultado do acumulador
	
	addi	$s1, $s1, 1		# incrementa o contador de colunas
	j	loop_colunas_mult	# volta para o loop das colunas

fim_colunas:

	addi	$s0, $s0, 1		# incrementa o contador de linhas
	j	loop_linhas_mult	# volta para o loop das linhas
	
fim_multiplicacao:

	lw 	$s7, 0($sp)		# restaura o valor de $s6 da pilha
     	lw 	$s6, 4($sp)		# restaura o valor de $s6 da pilha
       	lw 	$s5, 8($sp)		# restaura o valor de $s6 da pilha
       	lw 	$s4, 12($sp)		# restaura o valor de $s6 da pilha
      	lw 	$s3, 16($sp)		# restaura o valor de $s6 da pilha
      	lw 	$s2, 20($sp)		# restaura o valor de $s6 da pilha
    	lw 	$s1, 24($sp)		# restaura o valor de $s6 da pilha
    	lw 	$s0, 28($sp)		# restaura o valor de $s6 da pilha
    	lw 	$ra, 32($sp)		# restaura o endereço de retorno na pilha
    	addi 	$sp, $sp, 36		# desaloca o espaço da pilha
    
    	jr $ra				# retorna para o main depois de concluir a multiplicação
	
#-------------------------------------------------------------------------------------------

# percorre matriz
escreve:

	addi 	$sp, $sp, -28		# aloca espaço na pilha para sete registradores
	sw 	$ra, 24($sp)		# salva o endereço de retorno na pilha
	sw 	$s0, 20($sp)		# salva o registrador $s0 na pilha
	sw 	$s1, 16($sp)		# salva o registrador $s1 na pilha
	sw 	$s7, 12($sp) 		# salva o descritor de arquivo ($s7)
	sw 	$t0, 8($sp)		# salva o registrador $t0 na pilha
	sw 	$a3, 4($sp)		# salva o registrador $a3 na pilha
	sw 	$t1, 0($sp)		# salva o registrador $t1 na pilha

    	move   $s0, $zero           # incrementa o contador de linhas ($s0)

loop_linhas_escreve:
    	bge    $s0, $t0, fim_escreve	# confere se já percorreu todas as linhas
    	move   $s1, $zero           	# incrementa o contador de colunas

loop_colunas_escreve:
    	bge    $s1, $t0, proxima_linha_escreve	# confere se já percorreu todas as colunas

    	mul    $t1, $s0, $t0        # linha_atual * total_colunas
    	add    $t1, $t1, $s1        # + coluna atual
    	sll    $t1, $t1, 2          # *4, pois estamos lidando com bytes

    	add    $t5, $a3, $t1        # calcula o endereço completo
    	lw     $t8, 0($t5)          # pega o número
    
    	jal    converte_numero      # chama a função que converte o número para string e já o salva no arquivo
    	
    	addi	$t2, $s1, 1			# incrementa o contador de colunas (em uma cópia) para conferir se é o último elemento
    	blt	$t2, $t0, escreve_espaco	# se não for o último elemento, vai para a função que escreve um espaço
    
    	j	continua_coluna		# continua percorrendo a coluna
    
escreve_espaco: 
   
    	li 	$v0, 15		# syscall para escrever no arquivo
    	move 	$a0, $s7		# move o descritor do arquivo
    	la 	$a1, espaco		# escreve um espaço no arquivo
    	li 	$a2, 1			# define o tamanho da string (1 byte)
    	syscall

continua_coluna:

    	addi   $s1, $s1, 1		# incrementa o contador de colunas
    	j      loop_colunas_escreve	# reinicia o loop de colunas
    
proxima_linha_escreve: 
    
    	addi   $s0, $s0, 1			# incrementa o contador de linhas
    	blt 	$s0, $t0, escreve_newline	# se não for a última linha, chama a função de escrever nova linha
    	j      fim_escreve			# se for a última, vai para a parte que finaliza a escrita
    
escreve_newline:

    	li 	$v0, 15			# syscall para escrever no arquivo
    	move 	$a0, $s7		# move o descritor do arquivo
    	la 	$a1, newline		# passa o prompt newline como argumento
    	li 	$a2, 1			# define o tamanho da string (1 byte)
    	syscall
    	j	loop_linhas_escreve  # reinicia o loop de linhas
    
fim_escreve:
    	lw 	$t1, 0($sp)		# restaura o registrador $t1 da pilha
	lw 	$a3, 4($sp)		# restaura o registrador $a3 da pilha
	lw 	$t0, 8($sp)		# restaura o registrador $t0 da pilha
	lw 	$s7, 12($sp)		# restaura o descritor de arquivo ($s7)
	lw 	$s1, 16($sp)		# restaura o registrador $s1 da pilha
	lw 	$s0, 20($sp)		# restaura o registrador $s0 da pilha
	lw 	$ra, 24($sp)		# restaura o endereço de retorno da pilha
	addi 	$sp, $sp, 28		# desaloca o espaço da memória
	jr 	$ra			# retorna para o main
	

# Converte número em string e escreve no arquivo
converte_numero:
    	
    	# Checa se é negativo
    	li 	$t1, 0			# carrega $t1 com 0
    	blt 	$t8, $t1, negativo	# se $t8 < $t0, o número é negativo

    	move 	$t1, $t8            	# se o número é positivo, move ele para $t1
    	li 	$t2, 0               # 0 = positivo
    	j 	converte		# vai para a lógica de conversão

negativo:
    	negu 	$t1, $t8		# nega o valor de $t8
    	li 	$t2, 1			# 1 = negativo

converte:

    	la 	$t3, buffer          # carrega o endereço de buffer 
    	addiu 	$t3, $t3, 11		# aponta para o último byte do buffer
    	sb 	$zero, 0($t3)        # armazena o terminador ('\0')
    	addiu 	$t3, $t3, -1		# decrementa o ponteiro pra armazenar os dígitos

    	li 	$t4, 0               # inicializa o contador de dígitos

converte_loop:
    	li 	$t5, 10		# carrega 10 no registrador para fazer a divisão
    	divu 	$t1, $t5		# divide $t1 por 10
    	mfhi 	$t6                 	# move o resto (dígito atual) para $t6 
    	mflo 	$t1                 	# move o restante do número para $t1

    	addiu 	$t6, $t6, 48       	# converte o dígito para seu valor ASCII
    	sb 	$t6, 0($t3)		# armazena obyte do dígito no buffer
    	addiu 	$t3, $t3, -1		# decrementa o ponteiro para o próximo byte
    	addiu 	$t4, $t4, 1		# incrementa o contadro de dígitos

    	bnez 	$t1, converte_loop	# se o quociente não for zero, continua o loop

    	beqz 	$t2, escreve_o_numero	# se for positivo (flag = 0), vai para a escrita do número
    	li 	$t6, 45               	# carrega o valor ASCII do '-'
    	sb 	$t6, 0($t3)		# armazena '-' no buffer
    	addiu 	$t3, $t3, -1		# decrementa o ponteiro para o próximo byte
    	addiu 	$t4, $t4, 1		# incrementa o contador de dígitos

escreve_o_numero:

    	addiu 	$t3, $t3, 1        	# incrementa o ponteiro para o início da string
    
   	# Escreve o número convertido (string) no arquivo
    	li 	$v0, 15			# syscall para escrever no arquivo
    	move 	$a0, $s7		# move o descritor do arquivo
    	move 	$a1, $t3		# move o endereço da string
    	move 	$a2, $t4		# move o tamanho da string
    	syscall

    	jr 	$ra			# volta para o endereço de retorno
