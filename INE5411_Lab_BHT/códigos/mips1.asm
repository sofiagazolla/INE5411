# Laboratório 05 - Exercício 1 -> 1º programa
.data
    	# mensagens de entrada e saída
    	msg_limite:       	.asciiz "Digite o limite do contador: "
    	msg_contador:  	.asciiz "Contador: "
    	newline:  		.asciiz "\n" 

.text

main:
   
	li 	$v0, 4               	# syscall para imprimir string
    	la 	$a0, msg_limite      	# printf("Digite o limite do contador: ");  
    	syscall

	# int limit;
    	li 	$v0, 5               	# syscall para ler inteiro
   	syscall                   		# scanf("%d", &limit);
    	move 	$s0, $v0             	# move o valor inserido para $s0
    
    	# int count = 0;
    	move 	$s1, $zero               	# contador para o limite estabelecido

	# int i = 0;
    	move 	$t0, $zero               	# variável do loop (i)

loop_for:

    	bge 	$t0, $s0, loop_fim   	# se i >= limite, sai do loop
    
    	# if (i % 2 == 0)
    	li 	$t1, 2                 	# carrega 2 em $t1 para realizar a divisão
    	div 	$t0, $t1              	# divide $t0 (i) por 2. O resto vai para $mf.
    	mfhi 	$t2                  	# move i % 2 para $t2
    
    	bne 	$t2, $zero, incremento_i 	# se o resto não for zero (número ímpar) pula para incremento do i

    	# se o resto for zero (número par):
    	
    	addi 	$s1, $s1, 1          	# incrementa o contador (count++;)

    	
    	# printf("Contador: %d\n", i);
    	li 	$v0, 4                 	# syscall para imprimir inteiro
    	la 	$a0, msg_contador   		# imprime "Contador: "
    	syscall
    
    	# imprime o valor de i ("%d")
    	li 	$v0, 1                 	# syscall para imprimir inteiro
    	move 	$a0, $t0             	# move o valor do limite para ser impresso
    	syscall
    
    	li 	$v0, 4                 	# syscall para imprimir inteiro
    	la 	$a0, newline   		# imprime "\n"
    	syscall
    
    	# fim do if

incremento_i:

    	addi 	$t0, $t0, 1          	# incrementa o i (i++)
    	j 	loop_for                	# repete o loop

loop_fim:

    	li 	$v0, 10                	# encerra o programa
    	syscall
