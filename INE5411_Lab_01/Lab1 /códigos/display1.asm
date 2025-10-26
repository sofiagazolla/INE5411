# Laboratório 1
# Exercício 1 - Atividades via Digital Lab

.data

# Cria um array de bytes 
# Cada byte equivale a um número escrito em display de 7 seg em hexadecimal

numeros:  .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F

.text


main:

    la   $t0, numeros      	# carrega o array com os endereços
    li   $t1, 0xFFFF0010   	# define que vai usar o display direito

    li   $t2, 0            	# cria um contador para qual número estamos para poderO fazer o ble

loop:

#----------- Imprime o número atual -----------

    lb   $t3, 0($t0)       	# pega padrão do dígito
    sb   $t3, 0($t1)       	# envia para p display

#------------- Ativa o sleep -----------------
# Isso é necessário para que cada número fique em display por um segundo e todos sejam visíveis
    
    li   $v0, 32           	# carrega o comando do sleep
    li   $a0, 1000         	# estabelece o tempo do sleep para 1s
    syscall
#----------------------------------------------

    addi $t0, $t0, 1   	# incrementa para que vá para o próximo byte no array
    addi $t2, $t2, 1		# incrementa o contador do índice
    ble  $t2, 9, loop		# compara com 9 para garantir que o loop se repita dez vezes
