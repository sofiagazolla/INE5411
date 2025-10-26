# Laboratório 05 - Exercício 1 -> 1º programa -> versão otimizada
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

	# int i = 0;
    	move 	$t0, $zero               	# variável do loop (i)

loop_for:

    	bge 	$t0, $s0, loop_fim   	# se i >= limite, sai do loop
    	
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
    	
    	addi 	$t0, $t0, 2          	# incrementa o contador (count++;)
    
    	j	loop_for

loop_fim:

    	li 	$v0, 10                	# encerra o programa
    	syscall
