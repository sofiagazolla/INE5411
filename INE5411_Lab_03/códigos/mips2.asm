#Exercício 2 - Seno calculado por série de Taylor

.data
	um:          		.double 1.0	# constante 1.0 em ponto flutuante
	menos_um:    		.double -1.0	# constante -1.0 em ponto flutuante, para alternar o sinal da série
	zero:         	.double 0.0	# constante 0.0 usada para inicializar a soma
	graus_para_radianos: .double 0.017453292519943295  # π / 180 (conversão de graus para radianos)
	limite_termos:   	.word 20		# número de termos na série de Taylor
	newline:      	.asciiz "\n"
	msg_input:    	.asciiz "Digite o valor de x em graus: "
	msg_resultado:   	.asciiz "Resultado da aproximação de sin(x): "

.text

main:
    	# Solicitar entrada do usuário
    	li 	$v0, 4
    	la 	$a0, msg_input
    	syscall

    	li 	$v0, 7              # comando para ler double
    	syscall

    	# Converter graus para radianos: x * (π / 180)
    	l.d 	$f14, graus_para_radianos
    	mul.d 	$f12, $f0, $f14  	# $f12 = x em radianos

    	# Inicializações
    	li 	$t0, 0             	# n = 0
    	lw 	$t1, limite_termos   # limite de termos = 20
   	l.d 	$f2, zero          	# inicializa a soma em 0

loop:

    	bge 	$t0, $t1, fim      	# verifica se já calculou os 20 termos

    	# expoente 
    	mul 	$t2, $t0, 2		# 2n
    	addi 	$t2, $t2, 1       	# 2n + 1

    	# potência: x^(2n+1)
    	move 	$a0, $t2          	# expoente vai para o argumento para entrar no procedimento que calcula a potência
    	jal 	funcao_potencia    	# resultado em $f4

    	# fatorial: (2n+1)!
    	move 	$a0, $t2		# (2n+1) vai para o argumento para entrar no procedimento que calcula o fatorias
    	jal 	funcao_fatorial          	# resultado em $f6

    	# calcular sinal: (-1)^n
    	andi 	$t3, $t0, 1 		# & lógico bit a bit entre n e 1, se t0 é par -> t3 0, se t0 é ímpar -> t3 é 1
    	beq 	$t3, $zero, positivo
    	#se não
    	l.d 	$f8, menos_um		# carrega -1 para ser o sinal do termo
    	j 	fim_sinal
    	
positivo:

    	l.d 	$f8, um		# carega 1 para ser o final do termo

fim_sinal:

    	# calcula o termo
    	mul.d 	$f10, $f4, $f8	
    	div.d 	$f10, $f10, $f6	

    	# soma o termo à variável acumuladora
    	add.d 	$f2, $f2, $f10

    	# n++
    	addi 	$t0, $t0, 1
    	j loop

fim:
    	# Imprimir resultado
    	li 	$v0, 4
    	la 	$a0, msg_resultado
    	syscall

    	li 	$v0, 3
    	mov.d 	$f12, $f2
    	syscall

    	li 	$v0, 4
    	la 	$a0, newline
    	syscall

    	# Encerrar
    	
    	li 	$v0, 10
    	syscall

# ------------------------------- Potência (base, expoente) ------------------------------- #
# Entrada: $f12 = base, $a0 = exp
# Saída:   $f4 = base^exp

funcao_potencia:

    	li 	$t4, 0				# contador
    	l.d 	$f4, um			# inicializa resultado em 1

potencia_loop:

    	bge 	$t4, $a0, potencia_fim	# se o contador >= expotente, termina
    	mul.d 	$f4, $f4, $f12		# multiplica o resultado (f4) pela base (f12)
    	addi 	$t4, $t4, 1			# contador ++
    	j 	potencia_loop		

potencia_fim:

    	jr 	$ra

# ------------------------------- Fatorial(n) ------------------------------- #
# Entrada: $a0 = n
# Saída:   $f6 = n!

funcao_fatorial:

    	li 	$t5, 1			# contador inicializado em 1
    	l.d 	$f6, um		# inicializa resultado em 1, (1! = 1)

fatorial_loop:

    	bgt 		$t5, $a0, fatorial_fim	# se o contador >= n, termina
    	mtc1 		$t5, $f16			# move o inteiro t5 para registrador de ponto flutuante
    	cvt.d.w 	$f16, $f16			# converte para double
    	mul.d 		$f6, $f6, $f16		# multiplica acumulador pelo valor atual
    	addi 		$t5, $t5, 1			# contador ++
    	j 		fatorial_loop

fatorial_fim:

    	jr 	$ra
