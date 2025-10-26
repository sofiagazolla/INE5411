#Exercício 1 - Raiz quadrada por método iterativo de Newton

.data

#-------- Prompts e mensagens de saída utilizados  --------
	prompt1: 		.asciiz "Digite um double: "
	prompt2: 		.asciiz "Digite o numero de iteracoes: "
	saida_aprox: 		.asciiz "\nRaiz quadrada aproximada: "
	saida_exata: 		.asciiz "Raiz quadrada exata: "
	saida_erro_abs: 	.asciiz "Erro absoluto: "
	newline: 		.asciiz "\n"
#----------------------------------------------------------

	x: 	.double 0.0	# Double inserido pelo usuário
	
#----------------------------------------------------------
	
#---------- Carrega valores que serão utilizados ----------
	um: 	.double 1.0		
	meio: 	.double 0.5
#----------------------------------------------------------

.text

main:

#--------------------------- Input do número que será calculado --------------------------------------
    	
    	li 	$v0, 4 		# comando pra imprimir string
    	la 	$a0, prompt1		# passa o prompt1 como argumento
    	syscall		

    	li 	$v0, 7			# comando para ler double
    	syscall
    	mov.d 	$f12, $f0		# move o valor inserido
    	s.d 	$f0, x			# armazena o valor inserido na memória
    	
#--------------------------- Input do número de iterações  --------------------------------------

    	li 	$v0, 4			# comando para ler string
    	la 	$a0, prompt2		# passa o prompt2 como argumento
    	syscall

    	li 	$v0, 5			# comando para ler inteiro
    	syscall		
    	move 	$a0, $v0		# move o num de iterações

#--------------------------- Cálculo e impressão da raiz aproximada --------------------------------------
    	
    	jal 	raiz_quadrada		# chama o procedimento raiz quadrada
    
    	li 	$v0, 4			# comando pra printar string
    	la 	$a0, saida_aprox	# prompt do resultado
    	syscall

    	li 	$v0, 3			# comando para printar double
    	mov.d 	$f12, $f0		# move o resultado de raiz_quadrada para ser passado como argumento
    	syscall
    
	jal 	imprimir_newline	# chama a função de printar nova linha

#--------------------------- Cálculo e impressão da raiz exata --------------------------------------

    	l.d 	$f2, x			# pega o valor da memória
    	sqrt.d $f4, $f2		# calcula a raiz quadrada exata usando a função
    
    	li 	$v0, 4			# comando para printar string
    	la 	$a0, saida_exata	# mensagem da raiz precisa
    	syscall

    	li 	$v0, 3			# comando para printar double
	mov.d 	$f12, $f4 		# talvez trocar por um move ao invés do store
    	syscall

	jal	imprimir_newline	# chama a função de printar nova linha 

#-------------------- Cálculo e impressão do erro absoluto --------------------


	sub.d 	$f6, $f0, $f4		# subtrai a raiz exata da aproximada
    	abs.d 	$f8, $f6		# tira o absoluto da diferença

    	li 	$v0, 4			# comando para printar string
    	la 	$a0, saida_erro_abs	# passa a mensagem do erro como argumento
    	syscall

    	li 	$v0, 3			# comando para printar double
    	mov.d 	$f12, $f8		# move para já estar no argumento 
    	syscall

#-------------------- Encerrar o programa --------------------

    	li 	$v0, 10		# comando para encerrar o programa
    	syscall

raiz_quadrada:

    	l.d 	$f0, um		# carrega o 1 da memória
    	l.d 	$f2, meio		# carrega o 0.5 da memória
    	l.d	$f4, x
    	move 	$t0, $a0		# cópia do contador de iterações -- maybe tirar

loop:

    	beq 	$t0, $zero, fim_loop	# se já tiver feito n iterações, acaba
    	div.d 	$f6, $f4, $f0		# x / estimativa
    	add.d 	$f8, $f6, $f0		# estimativa + (x/estimativa)
    	mul.d 	$f0, $f2, $f8		# nova estimativa = resultado * 0.5
    	addi 	$t0, $t0, -1		# decrementa o contador
    	j 	loop			# repete o loop

fim_loop:

    	jr 	$ra			# volta para o main
    
imprimir_newline:

    	li 	$v0, 4			# comando para printar string
    	la 	$a0, newline		# passa a nova linha como argumento
    	syscall
    	jr 	$ra			# volta para o main
