# Laboratório 1
# Exercício 2 - Atividades via Digital Lab

#------------- Equivalences (apelidos) -----------
.eqv display_direito	0xFFFF0010 	# display direito
.eqv linha_ativa	0xFFFF0012	# linha ativa no momento
.eqv valor_tecla	0xFFFF0014	# valores das teclas

#--------------------------------------------------

.data

tabela_padroes: # padrão que escreve cada um dos dígitos do teclado
	.byte 0x3f, 0x66, 0x7f, 0x39  
    	.byte 0x06, 0x6d, 0x6f, 0x5e 
    	.byte 0x5b, 0x7d, 0x77, 0x79 
    	.byte 0x4f, 0x07, 0x7c, 0x71 
    	
codigos_teclas: # código retornado pelo hardware ao apertar cada tecla
    	.byte 0x11,0x12,0x14,0x18	
    	.byte 0x21,0x22,0x24,0x28	
    	.byte 0x41,0x42,0x44,0x48	
    	.byte 0x81,0x82,0x84,0x88
    	
.text

main:
	
	# escolhemos $s7 pra armazenar o valor da última tecla pressionada
	li 	$s7, -1 		# é inicializado com um valor inválido para saber que nenhuma tecla foi pressionada ainda
	li	$t0, 0x00		# começa com todos os segmentos apagados (nenhum valor escrito)
	sb	$t0, display_direito	# passa o byte do padrão de segmentos ao display		


loop_principal:
	
	li	$s0, 1			# estabelece que comece na linha um


#------------- Verifica a linha -----------	
verifica_linha:

	sb	$s0, linha_ativa	#seleciona a linha que vai ser percorrida nesse loop (vai ser incrementado depois para percorrer todas)
	
	# É necessário fazer um pequeno delay, para que todas as teclas estabilizem
	li	$a0, 50		# é o argumento que será passado para o delay
	jal	delay			# salta para o delay e salva para onde deve voltar
	
	lbu	$t0, valor_tecla	# passa o valor da tecla que foi apertada
	beqz	$t0, proxima_linha	# vai para a proxima linha caso o valor não esteja nela
	
	la	$t1, codigos_teclas	# $t1 funciona como um ponteiro para os valores
	li	$t2, 0			# é um contandor para o índice que está sendo conferido (será incrementado)
	
	
#------------- Procura a tecla -------------
procura_tecla:

	lbu	$t3, 0($t1)			# lê o valor do endereço apontado por $t1
	beq	$t3, $t0, tecla_encontrada	# se o código lido for igual ao que está sendo verificado, já pula pra tecla_encontrada
	
	addi	$t1, $t1, 1 			# incementa o contador para ir para o próximo byte
	addi	$t2, $t2, 1			# incrementa o contador do índice
	
	li	$t4, 16			# carrega 16 (o número de teclas) no registrador
	blt	$t2, $t4, procura_tecla 	# se o número de teclas que já foi testado for maior ou igual a 16, significa que já percorremos tudo
	j	proxima_linha			# vem pra cá caso tenha percorrido tudo e não tenha achado a tecla (mas não deve acontecer)


#------------- Achou a tecla -----------
tecla_encontrada:
	
	beq	$s7, $t2, proxima_linha	# se o valor não mudou, nada acontece
	move	$s7, $t2			# atualiza $s7 com a tecla nova, caso tenha mudado
	la	$t5, tabela_padroes		# funciona como um ponteiro que aponta para o padrão de cada display
	addu	$t5, $t5, $t2			# carrega o padrão do valor que será exibido
	lbu 	$t6, 0($t5)			# soma o índice ao endereço base pra apontar certo
	sb	$t6, display_direito		# exibe o valor no display

	
#------------ Verifica se há tecla sendo pressionada -----------			
espera_liberar:
	
	lbu	$t0, valor_tecla		# carrega o código em $t0
	bnez	$t0, espera_liberar		# enquanto é diferente de zero,significa que alguma tecla está pressionada e continua preso nesse loop
	j	continuar_loop		# continua o loop normalmente
	
	
#------------ Vai para a próxima linha------------	
proxima_linha:
	
	sll 	$s0, $s0, 1 			# desloca um bit pra esquerda, pois como as linhas são potências de 2, isso faz com que vá pra próxima
	andi	$s0, $s0, 0x0F		# garante que não seja maior de 16 (não vá pra lugares inválidos) e, se for, zera
	bnez	$s0, verifica_linha		# se não é 0 (é válido), verifica a linha


#----------- Reinicia o loop --------------
continuar_loop:
	
	j	loop_principal		# repete o loop principal


#----------- Delay ------------	
# Aqui é feio um loop bobo com o objetivo de "matar tempo" no programa, para 
# Fizemos isso pois quando usamos o sleep tava erro em tudo, então foi a alternativa que achamos

delay:
	
	li	$v0, 0				# zera o contador
	
delay_loop:
	
	addi	$v0, $v0, 1			# incrementa o contador em 1
	blt	$v0,$a0, delay_loop		# se for menor que o valor em $a0 (50), continua o loop
	jr	$ra				# quando $v0 chegar em 50, volta para o lugar que parou em continua_linha