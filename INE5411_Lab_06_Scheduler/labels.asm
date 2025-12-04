# Descobrimos que o store conditional e o load linked são 
# de mentirinha. Não funcionam no MARS. Paia :(
# Por isso, para evitar eventuais problemas de concorrência, 
# implementei esse artifício técnico: desabilitar o contador e
# habilitar o contador para evitar preempção numa região crítica.
# É uma solução bem feia, mas o Pete Sanderson não nos deixou 
# outra escolha. 

.macro lock_in
sb $0 0xffff013
.end_macro

.macro lock_out
li $at 1
sb $at 0xffff013
.end_macro

# Não reabilitar o lock leva ao programa nunca ser preemptado. O
# que seria bem grave.

# Push's da stack para se usar no programa
.macro psb, %r
subi $sp, $sp, 1
sb %r, 0($sp)
.end_macro

.macro psh, %r
subi $sp, $sp, 2
sh %r, 0($sp)
.end_macro

.macro psw, %r
subi $sp, $sp, 4
sw %r, 0($sp)
.end_macro

# Pop's também
.macro ppb, %r
lbu %r, 0($sp)
addi $sp, $sp, 1
.end_macro

.macro pph, %r
lhu %r, 0($sp)
addi $sp, $sp, 2
.end_macro

.macro ppw, %r
lw %r, 0($sp)
addi $sp, $sp, 4
.end_macro
