####################################################################################################
#
#   ARQUIVO:  		kernel.s
#   PROJETO:    	-
#   AUTOR:   		Pedro Henrique Tesman Mansani da Silva <phtmsilva@gmail.com>
#   ORIENTADOR:		Marcelo Daniel Berejuck <email.orientador@dominio.com>
#   INSTITUIÇÃO:	Universidade Federal de Santa Catarina
#
#   DATA DE CRIAÇÃO:	-
#
# --------------------------------------------------------------------------------------------------
#
#   DESCRIÇÃO:
#	-
#	-
#	-
#	-
#
# --------------------------------------------------------------------------------------------------
#
#   COMO COMPILAR/EXECUTAR:
#       1. Abra este arquivo no simulador MARS (v4.5 ou superior).
#       2. Monte o código (F3).
#       3. Execute (F5).
#       4. [Se houver entrada de dados] Os dados de entrada devem estar no
#          formato X e a saída será exibida no console.
#
# --------------------------------------------------------------------------------------------------
#
#   HISTÓRICO DE VERSÕES: -
#
# --------------------------------------------------------------------------------------------------
#
#   COPYRIGHT:
#       Copyright (C) 2025, Pedro Henrique Tesman Mansani da Silva.
#
#       Este programa é software livre; você pode redistribuí-lo e/ou
#       modificá-lo sob os termos da Licença MIT.
#
###################################################################################################

# CONFIGURAÇÃO:
#
# Essas duas constantes simbólicas abaixo definem a lista de threads que o kernel
# vai estar preparado para gerenciar.
# A primeira, max_th, diz respeito ao número de threads na lista estática, enquanto
# a segunda, thread_v, dita os labels de cada thread. Podem haver labels repetidos
# (duas threads com mesmo código), dependendo da aplicação pode ser algo útil...

.eqv max_th 2
.eqv thread_v prog2, prog3

##################################################################################### #############

# Não pode haver outra global nomeada main no projeto, para não conflitar com essa.
# Até porque, isso pode confundir o linkador (o programa deve iniciar aqui).
.globl main

# As diretivas que seguem servem apenas para deixar melhor legível o acesso aos TCBs.
# Para uma TCB no registrador $s0, para obter o valor do registrador $pc (e guardar
# no registrador $t0), temos apenas que fazer a instrução: lw $k0 pc($s0)

.eqv zero  0
.eqv at    4
.eqv v0    8
.eqv v1   12

.eqv a0   16
.eqv a1   20
.eqv a2   24
.eqv a3   28

.eqv t0   32
.eqv t1   36
.eqv t2   40
.eqv t3   44
.eqv t4   48
.eqv t5   52
.eqv t6   56
.eqv t7   60

.eqv s0   64
.eqv s1   68
.eqv s2   72
.eqv s3   76
.eqv s4   80
.eqv s5   84
.eqv s6   88
.eqv s7   92

.eqv t8   96
.eqv t9  100

.eqv ra  104
.eqv pc  108

.eqv sp  112

.kdata
thread_atual: .word 0
max_threads: .word max_th
thread_vector: .word thread_v
kat: .word

##################################################################################### #############

# Aqui começa o texto do kernel, colocado no ktext sobre a diretiva .ktext. O código, portanto,
# fica em uma região a parte do código das threads, em regiões mais altas da memória

###################################################################################################

.ktext
main:
# Onde o programa começa (e executa uma única vez)
# Aqui alocamos memória para guardar o contexto das threads (as TCBs)

lw $s0 max_threads

li $t0 0x3feffc 	# 03FEFFC é o tamanho da stack total.
div $s1 $t0 $s0 	# Dividimos-a para cada thread.
andi $s1 $s1 0xfffffffc # Isso assegura que a stack
			# vai estar alinhada com uma word

la $s2 tcbs		# array de tcbs

li $t0 0 		# contador 4 em 4
li $t1 0 		# contador 1 em 1

loop_cria_tcb:
lw $t2 thread_vector($t0)	# Inicializa o pc
sw $t2 pc($s2)			# de cada thread

mul $t3 $s1 $t1		# Inicializa
sub $t4 $sp $t3		# a
sw $t4 sp($s2)		# stack

addi $t0 $t0 4
addi $t1 $t1 1
addi $s2 $s2 128 # 4*32 (registradores), para alcançar a próxima tcb

bne $t1 $s0 loop_cria_tcb

kmain:
# parte principal do kernel. Qualquer coisa
# extra que o kernel deva fazer (ler entradas,
# escrever no display, etc) deve vir aqui, essa
# seção é executada uma vez entre cada troca de contexto

scheduler:
# Aqui, ocorre a grande mágica de qualquer kernel preemptivo: a troca de contexto.

lw $t0 thread_atual	# Conseguir o endereço
sll $t0 $t0 7 		# do TCB correspondente
la $t1 tcbs		# a thread atual
add $k0 $t0 $t1		# (ficará em $k0)

# Carrega cada registrador da thread em questão, um a um
lw $v0 v0($k0)
lw $v1 v1($k0)

lw $a0 a0($k0)
lw $a1 a1($k0)
lw $a2 a2($k0)
lw $a3 a3($k0)

lw $t0 t0($k0)
lw $t1 t1($k0)
lw $t2 t2($k0)
lw $t3 t3($k0)
lw $t4 t4($k0)
lw $t5 t5($k0)
lw $t6 t6($k0)
lw $t7 t7($k0)

lw $s0 s0($k0)
lw $s1 s1($k0)
lw $s2 s2($k0)
lw $s3 s3($k0)
lw $s4 s4($k0)
lw $s5 s5($k0)
lw $s6 s6($k0)
lw $s7 s7($k0)

lw $t8 t8($k0)
lw $t9 t9($k0)

lw $ra ra($k0)

lw $sp sp($k0)

li $k1 0x80		# Reabilita o contador
sb $k1 0xffff0013	# de instruções

lw $k1 pc($k0)		# Vamos pular para o endereço do $pc

lw $at at($k0)		# carregamos o registrador do assembler

jr $k1

##################################################################################### #############

# A seção abaixo diz respeito ao tratador de interrupções do kernel. Quando ocorre
# uma interrupção, seja pelo pseudotimer, pelo teclado ou por um problema no
# programa, o fluxo do código é jogado no endereço 0x80000180, ali devemos
# detectar a exceção e tratá-la corretamente (trocar a thread, destruí-la, etc).

###################################################################################################

.ktext 0x80000180
move $k0 $at
sw $k0 kat	# guardar o at para poder usá-lo aqui

sb $0 0xffff0013	# desabilitar contador
mfc0 $k0 $13 # verificar a causa da exceção

# Contador
andi $k1 $k0 0x400 # bit 10
bne $k1 0, exc_contador

# Uma exceção de teclado virira aqui

# Exceções em geral: carregar thread atual,
# derrubá-la e exibir mensagem de erro apropriada.
# A partir daqui, não é necessário manter o contexto
# das threads, pois elas serão destruídas (a exceção
# é incorrigível)

andi $k1 $k0 0x8 # 4
bne $k1 0, exc_addlw

andi $k1 $k0 0x9 # 5
bne $k1 0, exc_addsw

andi $k1 $k0 0x20 # 8
bne $k1 0, exc_syscall

andi $k1 $k0 0x24 # 9
bne $k1 0, exc_breakpoint

andi $k1 $k0 0x28 # 10
bne $k1 0, exc_instrução_reservada

andi $k1 $k0 0x2a # 12
bne $k1 0, exc_of_aritimetico

andi $k1 $k0 0x2c # 13
bne $k1 0, exc_trap

andi $k1 $k0 0x2 # 15
bne $k1 0, exc_div_by_zero

andi $k1 $k0 0x2c # 16
bne $k1 0, exc_of_fp

andi $k1 $k0 0x2c # 17
bne $k1 0, exc_uf_fp

# outras exceções fatais viriam aqui

j exc_desconhecida # exceção desconhecida

exc_contador:
mtc0 $0 $13 # limpa o cause
beqz $0 trocar_contexto
j ret_std

exc_desconhecida:
la $s0 EXCMSG_generico
j destruir_thread

exc_addlw:
la $s0 EXCMSG_addlw
j destruir_thread

exc_addsw:
la $t0 EXCMSG_addsw
j destruir_thread

exc_syscall:
la $t0 EXCMSG_syscall
j destruir_thread

exc_breakpoint:
la $t0 EXCMSG_breakpoint
j destruir_thread

exc_instrução_reservada:
la $t0 EXCMSG_instrução_reservada
j destruir_thread

exc_of_aritimetico:
la $t0 EXCMSG_of_aritimetico
j destruir_thread

exc_trap:
la $t0 EXCMSG_trap
j destruir_thread

exc_div_by_zero:
la $t0 EXCMSG_div_by_zero
j destruir_thread

exc_of_fp:
la $t0 EXCMSG_of_fp
j destruir_thread

exc_uf_fp:
la $t0 EXCMSG_uf_fp
j destruir_thread

ret_std:
li $k0 0x80
sb $k0 0xffff0013	# reabilitando
lw $at kat	# retornando at
eret

destruir_thread:
# Ocorreu um problema crítico na thread: para evitar
# o pior, matar a thread é uma boa opção:
# max_threads
# thread_atual
# thread_vector

mtc0 $0 $13 # limpa o cause

li $v0 4	# Printa o texto da
move $a0 $s0	# exceção em questão
syscall

lw $t0 thread_atual
li $v0 1
move $a0 $t0	# Printa a thrad atual
syscall	#

la $t1 thread_vector
mul $t0 $t0 4
add $t0 $t0 $t1 # possui o end da thread a ser removida

sw $0 0($t0) # zera o endereço quando o scheduler
# lê-lo ele o pulará. Como a fila de processos
# é pequena o impacto no desempenho é pequeno,
# negligenciável. Poderíamos modificar a forma que isso
# é feito, modificando a estrutura de dados usada.
# Isso seria mais interessante.

lw $t3 max_threads

lw $t2 thread_atual		# Atualiza a thread atual,
addi $t2 $t2 1			# somando um ao seu index
blt $t2 $t3 atualiza_counter	# (e naturalmente retornando
li $t2 0			# ele a zero caso passe de
atualiza_counter:		# $t3 (o número total de
sw $t2 thread_atual		# threads)

la $t4 scheduler	# importante: retornar usando eret, caso contrário
mtc0 $t4 $14		# o código ainda estaria rodando em modo tratamento de
eret			# exceções, com compostamento indesejado.

##################################################################################### #############

# Essa próxima seção diz respeito a troca de contexto. thread -> kernel.

###################################################################################################

trocar_contexto:
lw $k0 thread_atual	# Conseguir o endereço
sll $k0 $k0 7		# do TCB correspondente
la $k1 tcbs		# a thread atual
add $k0 $k0 $k1	# (ficará em $k0)

lw $at kat	# Guarda o registrador $at, antes
move $k1 $at	# guardado para liberar pseudo
sw $k1 at($k0)	# instruções no kernel

sw $v0 v0($k0)
sw $v1 v1($k0)

sw $a0 a0($k0)
sw $a1 a1($k0)
sw $a2 a2($k0)
sw $a3 a3($k0)

sw $t0 t0($k0)
sw $t1 t1($k0)
sw $t2 t2($k0)
sw $t3 t3($k0)
sw $t4 t4($k0)
sw $t5 t5($k0)
sw $t6 t6($k0)
sw $t7 t7($k0)

sw $s0 s0($k0)
sw $s1 s1($k0)
sw $s2 s2($k0)
sw $s3 s3($k0)
sw $s4 s4($k0)
sw $s5 s5($k0)
sw $s6 s6($k0)
sw $s7 s7($k0)

sw $t8 t8($k0)
sw $t9 t9($k0)

sw $ra ra($k0)

sw $sp sp($k0)

mfc0 $k1 $14 # guardar pc
sw $k1 pc($k0)

la $k1 kmain
mtc0 $k1 $14

lw $t0 thread_atual	# 
next_thread: 		#
lw $t1 max_threads	# Soma mais um a thread_atual
addi $t0 $t0 1		# (e volta para zero se maior que
blt $t0 $t1 pass	# o máximo)
move $t0 $0		#
pass: 
sll $t2 $t0 2			# Verifica se a thread escolhida
lw $t3 thread_vector($t2)	# é um nullptr, se for, a thread
beqz $t3 next_thread		# não existe mais e deve ser ignorada
sw $t0 thread_atual		#

eret

.kdata 
# Esse espaço reserva algumas mensagens de erro
# para caso os programas causarem alguma exceção
# durante a execução do programa. Para tornar o
# programa mais interativo, o erro derrubará apenas
# a thread que lançou a exceção e a mensagem de erro
# informará o número da thread problemática

EXCMSG_addlw: .asciiz "Load inválido na thread "
EXCMSG_addsw: .asciiz "Store inválido na thread "
EXCMSG_syscall: .asciiz "Exceção causada por syscall na thread"
EXCMSG_breakpoint: .asciiz "Exceção causada por breakpoint na thread"
EXCMSG_instrução_reservada: .asciiz "Exceção causada por instrução reservada na thread"

EXCMSG_of_aritimetico: .asciiz "Exceção aritimética na thread"
EXCMSG_trap: .asciiz "Exceção causada por trap na thread"
EXCMSG_div_by_zero: .asciiz "Divisão por zero na thread"
EXCMSG_of_fp: .asciiz "Overflow de ponto flutuante na thread"
EXCMSG_uf_fp: .asciiz "Underflow de ponto flutuante na thread"

EXCMSG_generico: .asciiz "Exceção na thread: "

.kdata
.align 2
tcbs: # espaço de memória para os TCBs

# Não aloque nada aqui, o espaço dos TCBs deve ser o último pois 
# cresce de acordo com o número de threads configurada
