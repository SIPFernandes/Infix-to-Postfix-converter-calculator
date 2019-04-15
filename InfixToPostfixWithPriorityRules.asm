#a41674
#Samuel Fernandes
#LEI, 2016/2017.
#Videografia: https://www.youtube.com/watch?v=vq-nUF0G4fI&t=311s
#o meu programa funciona 100% apenas tem de terminar com '.' pois com 0 ou $zero ao passar de infixto postfix mete o ultimo bite do postfix na outra linha e não sei o porque??

.data
infix: .space 256
postfix: .space 256
stack: .space 256
n_line: .asciiz "\n"
.text

#input(infix)
la $a0, infix
li $a1, 256
li $v0, 8
syscall

jal infix2postfix	#vamos chamar a função infix2postfix
jal solvePostfix	#vamos chamar a função solvePostfix

li $v0, 10		#termina o programa
syscall

#------------------------INFIX TO POSTFIX--------------------------------------------
infix2postfix:			#temos de guardar na stack privada do mips as variáveis s que vamosutilizar
sw $s0, 0($sp)
addi $sp, $sp, -4
sw $s1, 0($sp)
addi $sp, $sp, -4
sw $s2, 0($sp)

#contadores
li $s1, -1 	#infix		
li $t2, -1	#postfix
li $s2, -1	#stack

ciclo0:			#aqui começa o nosso primeiro ciclo para passar o infix para postfix
la $s0, infix			#os endereços voltam sempre a posição inicial quando o ciclo recomeça
la $t0, postfix
la $t1, stack

addi $s1, $s1, 1		#vamos adicionar ao contador do infix um para andarmos um bite para a direita
add $s0, $s0, $s1		#vamos carregar o endereço do infix na posição do seu contador
lb $t3, 0($s0)			#e guardar o bite atual em $t3

beq $t3, '(', parentesis	#vamos verificar se o bite em $t3 é um operador, um numero, parentesis ou ponto/vazio
beq $t3, '+', operadorless
beq $t3, '-', operadorless
beq $t3, '*', operadormore
beq $t3, '/', operadormore
beq $t3, '.', pop00
beq $t3, 0, pop00

addi $t2, $t2, 1	#caso seja um numero andamos para a proxima casa vazia do postfix e guardamos lá o bite
add $t0, $t0, $t2
sb $t3, 0($t0)
j ciclo0

operadorless:		#se operador+ ou - carregamos para $t4 o que se encontra anteriormente na stack, verificamos se é um operador
la $t0, postfix
la $t1, stack
add $t1, $t1, $s2
lb $t4, 0($t1)
beq $t4, '*', pop0
beq $t4, '/', pop0
beq $t4, '+', pop01
beq $t4, '-', pop01
addi $s2, $s2, 1		#se não for um operador vamos para a proxima casa vazia da stack e guardamos la o novo operador que se encontra em $t3
addi $t1, $t1, 1
sb $t3, 0($t1)
j ciclo0

operadormore:		#se operador * ou / carregamos para $t4 o que se encontra anteriormente na stack e verificamos se é * ou /
add $t1, $t1, $s2	
lb $t4, 0($t1)
beq $t4, '*', pop01	
beq $t4, '/', pop01
addi $s2, $s2, 1	#se não for * ou / vamos para a proxima casa vazia da stack e guardamos o novo operador que se encontra em $t3
addi $t1, $t1, 1
sb $t3, 0($t1)
j ciclo0

pop01:			#vamospara a proxima casa vazia do postfix guardamos o operador anterior e na stack substituimos o operador anterior pelo operador novo
addi $t2, $t2, 1	
add $t0, $t0, $t2
sb $t4, 0($t0)
sb $t3, 0($t1)
j ciclo0

pop0:
la $t0, postfix
la $t1, stack
addi $t2, $t2, 1	#vamos para a proxima casa vazia no postfix e guardamos la o operador que estava na stack
add $t0, $t0, $t2
sb $t4, 0($t0)		
add $t1, $t1, $s2	#na mesma posição do operador da stack guardamos zero para verificar que esse lugar fica desocupado caso queiramos ter maior controlo de todos os movimentos da stack
sb $zero, 0($t1)
addi $s2, $s2, -1	# retrocedemos para o bite anterior da stack
addi $t1, $t1, -1
lb  $t4, 0($t1) 	#carregamos em $t4 esse bite da stack
beqz $t4, operadorless  #se for zero significa que a stack está vazia e vamos para operadorless
j pop0			#caso haja um operador voltamos ao inicio de pop0

pop00:			#em pop00 ou seja depois de atingirmos o '.' ou 0 vamos colocar bit mais recente da stack e colocá-lo no postfix  
add $t1, $t1, $s2
lb $t4, 0($t1)
while:
la $t0, postfix
la $t1, stack
addi $t2, $t2, 1		
add $t0, $t0, $t2
sb $t4, 0($t0)
add $t1, $t1, $s2
sb $zero, 0($t1)
addi $s2, $s2, -1	#e verificar se ainda se encontram mais operadores na stack
addi $t1, $t1, -1
lb  $t4, 0($t1) 
beqz $t4, end_infix  	#se $t4 fo zero significa que não há mais operadores caso seja diferente de zero voltamos a repetir o while até acabar com os operadores
j while


ciclo:	#ciclo do parentesis
la $s0, infix
la $t0, postfix
la $t1, stack

addi $s1, $s1, 1	#após encontrarmos um parentesis voltamos a andar para o proximo bite do infix e vamosverificar qual é o tipo
add $s0, $s0, $s1
lb $t3, 0($s0)

parentesis:
beq $t3, '(', open_parentesis
beq $t3, '+', low_operador
beq $t3, '-', low_operador
beq $t3, '*', high_operador
beq $t3, '/', high_operador
beq $t3, ')', close_parentesis
beq $t3, '.', end_infix
beq $t3, 0, end_infix

addi $t2, $t2, 1		#caso seja um numero adicionamos ao postfix
add $t0, $t0, $t2
sb $t3, 0($t0)
j ciclo

open_parentesis:
addi $s2, $s2, 1	#se for um open parentesis adicionamos á stack
add $t1, $t1, $s2
sb $t3, 0($t1)
j ciclo

high_operador:
addi $s2, $s2, 1	#se for * ou / adicionamos ao stack
add $t1, $t1, $s2
sb $t3, 0($t1)
j ciclo

low_operador:		#se for + ou - vamos verificar se anteriormente na stack e encontra um operador * ou /
la $t0, postfix
la $t1, stack
add $t1, $t1, $s2
lb $t4, 0($t1)
beq $t4, '*', pop2
beq $t4, '/', pop2 
addi $s2, $s2, 1	#caso na stack encontre-se +, -, ou nada adicionamos o novo operador na stack
addi $t1, $t1, 1
sb $t3, 0($t1)
j ciclo

close_parentesis:	#quando encontramos ')' vamos verificar o bite mais recente da stack e fazer pop até encontrármos '('
la $t0, postfix
la $t1, stack
add $t1, $t1, $s2
lb $t3, 0($t1)
beq $t3, '+', pop
beq $t3, '-', pop
beq $t3, '*', pop
beq $t3, '/', pop
sb $zero, 0($t1)
addi $s2, $s2, -1	#se não for nenhum dos acima andamos para trás na stack e carregamos em $t4 o valor da stack
addi $t1, $t1, -1
lb $t4, 0($t1)		
beq $t4, '(', ciclo	#se for '(' significa que a prioridade do parentises acabou, entao voltamos ao ciclo normal
j ciclo0		#se for diferente de '(' significa que a prioridade parentesis ainda não acabou

pop:
addi $t2, $t2, 1	#adicionamos ao postfix o operador atual guardado em $t3
add $t0, $t0, $t2
sb $t3, 0($t0)
sb $zero, 0($t1)	#no seu lugar pomos o valor zero para termos mais controlo dos movimentos na stack e andamos o contador da stack uma casa para trás
addi $s2, $s2, -1
j close_parentesis	#voltamos a função close_parentesis

pop2:
addi $t2, $t2, 1	#adicionamos o operador em $t4 ao postfix e andamos no contador da stack um bite para trás 
add $t0, $t0, $t2
sb $t4, 0($t0)
sb $zero, 0($t1)
addi $s2, $s2, -1
j low_operador		#voltamos a low_operador

end_infix:
la $t0, postfix		#adicionamos o '.' ou 0 no final do postfix e imprimi-mos
addi $t2, $t2, 1
add $t0, $t0, $t2
sb $t3, 0($t0)

la $a0, postfix
li $v0, 4
syscall

la $a0, n_line
li $v0, 4
syscall

lw $s2, 0($sp)		#carregamos os registos s com os valores guardados na stack privada do mips 
addi $sp, $sp, 4
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)

jr $ra			#voltamos á main
#-------------------------------SOLVE POSTFIX-----------------------------------------------

sw $s0, 0($sp)		#guardamos na stack privada do mips as variáveis s que vamosutilizar
addi $sp, $sp, -4
sw $s1, 0($sp)
addi $sp, $sp, -4
sw $s2, 0($sp)
addi $sp, $sp, -4
sw $s3, 0($sp)

solvePostfix:
li $s1, -1	#postfix contador
li $s3, -4	#stack contador

ciclo_solve:
la $s0, postfix
la $s2, stack

addi $s1, $s1, 1	#andamos um bite no postfix
add $s0, $s0, $s1
lb $t1, 0($s0)

beq $t1, '+', solve_more	#vamos verificar se o novo bit do postfix é numero, operador ou outro
beq $t1, '-', solve_less
beq $t1, '*', solve_mult
beq $t1, '/', solve_divi
beq $t1, '.', print_result
beq $t1, 0, print_result

j check		#se for numero vamos transformar de string para inteiro
number:
addi $s3, $s3, 4	#após termos o inteiro guardamos como word na stack
add $s2, $s2, $s3
sw $t1, 0($s2) 
j ciclo_solve

solve_more:		#se o operador for '+' carregamos o operador mais recente da stack em $t2
add $s2, $s2, $s3	#nessa posição da stack damos o valor zero para termos mais controlo se quisermos saber a movimentação da stack
lw $t2, 0($s2)
sw $zero, 0($s2)
addi $s3, $s3, -4	#recuamos à word anterior da stack e carregamos em $t3
addi $s2, $s2, -4	
lw $t3, 0($s2)
add $t1, $t2, $t3	#adicionamos $t2 a $t3 e guardamos em $t1 o resultado
sw $t1, 0($s2)		#guardamos como word o resultado na stack e voltamos ao ciclo_solve
j ciclo_solve

solve_less:
add $s2, $s2, $s3	#é igual ao do operador '+' apenas muda a operação que é a subtração
lw $t2, 0($s2)
sw $zero, 0($s2)		
addi $s3, $s3, -4
addi $s2, $s2, -4
lw $t3, 0($s2)
sub $t1, $t3, $t2
sw $t1, 0($s2)
j ciclo_solve

solve_mult:		#é igual ao do operador '+' apenas muda a operação que é a multiplicação
add $s2, $s2, $s3
lw $t2, 0($s2)
sw $zero, 0($s2)
addi $s3, $s3, -4
addi $s2, $s2, -4
lw $t3, 0($s2)
mul $t1, $t2, $t3
sw $t1, 0($s2)
j ciclo_solve

solve_divi:		#é igual ao do operador '+' apenas muda a operação que é a divisão
add $s2, $s2, $s3
lw $t2, 0($s2)
sw $zero, 0($s2)
addi $s3, $s3, -4
addi $s2, $s2, -4
lw $t3, 0($s2)
div $t1, $t3, $t2
sw $t1, 0($s2)
j ciclo_solve

print_result:		#vamos imprimir o valor que restou na stack como numero inteiro
lw $a0, 0($s2)
li $v0, 1
syscall

lw $s3, 0($sp)		#carregamos os registos s com os valores guardados na stack privada do mips
addi $sp, $sp, 4
lw $s2, 0($sp)
addi $sp, $sp, 4
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)

jr $ra
#----------------Auxiliar--------------------

check:			#vamos transformar a string em numero inteiro, como no postfix apenas temos numeros 0 a 9 podemos verificar um a um
beq $t1, '0', zero	
beq $t1, '1', one
beq $t1, '2', two 
beq $t1, '3', tree
beq $t1, '4', four
beq $t1, '5', five
beq $t1, '6', six
beq $t1, '7', seven
beq $t1, '8', eight
beq $t1, '9', nine

#check ints
zero:
li $t1, 0
j number
one:
li $t1, 1
j number
two:
li $t1, 2
j number
tree:
li $t1, 3
j number
four:
li $t1, 4
j number
five:
li $t1, 5
j number
six:
li $t1, 6
j number
seven:
li $t1, 7
j number
eight:
li $t1, 8
j number
nine:
li $t1, 9
j number

##-----------------Tools-----------------------
la $a0, stack		#ferramentas utilizadas para ver a movimentação da stack, postfix e outras variáveis durante os testes na varias fazes do programa.
li $v0, 4
syscall
la $a0, n_line
li $v0, 4
syscall
la $a0,($t0)
li $v0, 1
syscall
