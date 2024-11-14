########################################################################################################################
# Inicia o programa. Realizamos as inicializações necessárias no programa, chamamos o procedimento principal main e em 
# seguida um código para terminar o programa
########################################################################################################################
init:
	    la $s0, x#x
	    la $s1, y#y
	    li $t0, 16
	    sw $t0, 0($s0)
	    sw $t0, 0($s1)
	    la $s2, seed#seed e constantes
	    la $s3, mExit
	    #$s4 cor da cobra
	    #$s5 x da maca
	    #$s6 y da maca
	    li $s7, 1 #comprimento
	    
	    jal     init_graph_test
	    jal     gera_maca
            
            la      $t0, main
            jr    $t0                 # chama o procedimento principal
.include "display_bitmap.asm"
.data
         x: .space 1000
         y: .space 1000
         seed: .word 1323, 279, 23423#seed, constante multiplicativa, Incremento
.text
.globl main




########################################################################################################################
# Termina o programa, retornando o valor do procedimento main.
########################################################################################################################
finit:
            move    $a0, $v0            # o valor de retorno de main é colocado em $a0
            li      $v0, 17             # serviço 17: termina o programa
            syscall                     # fazemos a chamada ao serviço 17.
########################################################################################################################   



########################################################################################################################
# Mapa da Pilha
# $ra :     $sp+0   endereço de retorno do procedimento     
########################################################################################################################
main:            
        # corpo do programa
        li $s4, NAVY
            lacoP:
 	    # desenho da cobra
 	    jal     verifica_pontuacao
 	    
 	    jal     desenha_maca
 	    
 	    jal     desenha_cobra
 	    
 	    jal     mover_cobra
 	    
 	    j lacoP

# epílogo
            la      $t0, finit
            jr      $t0                 # termina o programa
 
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
init_graph_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, WHITE           # $a0 <- BLUE (azul)
            jal     set_background_color # escolhemos a cor azul para o fundo da tela
            jal     screen_init2         # inicializamos a tela gráfica
            
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

desenha_cobra:
	# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
        # corpo do procedimento
            addi $s4, $s4, 50    # Duplica a intensidade da cor em cada componente (pode precisar de m?ara depois)
            andi $s4, $s4, 0x00FFFFFF
            
            
            move      $a0, $s4
            jal     set_foreground_color
            lw      $t0, 0($s0)
            lw      $t1, 0($s1)
            or      $a0, $zero, $t0
            or      $a1, $zero, $t1
            jal     put_pixel
            
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

mover_cobra:
	    # prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
 # esperamos um caracter no terminal
            la    $t0, 0xFFFF0004   # endereço do RDR
            lw    $t2, 0($t0)       # $t2 <- caracter do terminal
            
            li $v0, 32
            li $a0, 100
            syscall

            # lemos o carcater
            
            la $t3, mCima
            beq $t3, $s3, mHorizontal
            la $t3, mBaixo
            beq $t3, $s3, mHorizontal
            la $t3, mEsquerda
            beq $t3, $s3, mVertical
            la $t3, mDireita
            beq $t3, $s3, mVertical
            
            mVertical:
            beq $t2, 0x77, mCima #w
            beq $t2, 0x57, mCima #W
            beq $t2, 0x73, mBaixo #s
            beq $t2, 0x53, mBaixo #S
            
            la $t3, mExit
            bne $s3, $t3, mElse
            
            mHorizontal:
            beq $t2, 0x44, mDireita #D
            beq $t2, 0x64, mDireita #d
            beq $t2, 0x41, mEsquerda #A
            beq $t2, 0x61, mEsquerda #a
            
            mElse:
            jr $s3
            mCima:
            jal retirar_do_fim
            jal move_restante_cobra
                lw $t0, 0($s0)
                beq $t0, $zero, finit
            	addi $t0, $t0, -1
            	sw $t0, 0($s0)
            	la $s3, mCima
            j mExit
            mBaixo:
            jal retirar_do_fim
            jal move_restante_cobra
            	lw $t0, 0($s0)
            	beq $t0, 31, finit
            	addi $t0, $t0, 1
            	sw $t0, 0($s0)
            	la $s3, mBaixo
            j mExit
            
            mDireita:
            jal retirar_do_fim
            jal move_restante_cobra
            	lw $t1, 0($s1)
            	beq $t1, 31, finit
            	addi $t1, $t1, 1
            	sw $t1, 0($s1)
            	la $s3, mDireita
            j mExit
            mEsquerda:
            jal retirar_do_fim
            jal move_restante_cobra
            	lw $t1, 0($s1)
            	beq $t1, $zero, finit
            	addi $t1, $t1, -1
            	sw $t1, 0($s1)
            	la $s3, mEsquerda
            
            mExit:
# epílogo
            jal verificar_derrota
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
            
move_restante_cobra:
    # Pr?o
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # corpo do procedimento
    #for(i=c;i>0;i--)
    addi $t0, $s7, -1 
    sll $t0, $t0, 2
    add $t1, $t0, $s1
    add $t0, $t0, $s0
    addi $t4, $s0, 4
    beq $t0, $s0, mrExit
    mrFor:
    	lw $t3, -4($t0)
    	sw $t3, 0($t0)
    	lw $t3, -4($t1)
    	sw $t3, 0($t1)
    	addi $t0, $t0, -4
    	addi $t1, $t1, -4
    	
        bne $t0, $s0, mrFor            
    
    # Ep?o
    mrExit:
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
            
desenha_maca:
    # Pr?o
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    
    # Corpo do procedimento
    li      $a0, RED
    jal     set_foreground_color
    move    $a0, $s5
    move    $a1, $s6
    jal     put_pixel
    
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

gera_maca:
    # Pr?o
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    
    # Corpo do procedimento
    jal     coordenada_aleatoria
    move    $s5, $v0           # Armazena a coordenada x
    jal     coordenada_aleatoria
    move    $s6, $v0
    
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

coordenada_aleatoria:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    lw      $t1, 0($s2)
    lw      $t2, 4($s2)
    lw      $t3, 8($s2)
    # Corpo do procedimento - Gera? de número aleat?
    mul     $t0, $t1, $t2         # $t0 = seed * a
    add     $t0, $t0, $t3         # $t0 = ($t0 + c)
    

    # Limita? do intervalo
    li      $t1, 32               # Define o limite superior (exclusivo)
    rem     $t0, $t0, $t1         # Calcula o valor aleat? entre 0 e 63
    
    sw      $t0, 0($s2)
    move    $v0, $t0

    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador


verifica_pontuacao:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha

    lw $t0, 0($s0)
    lw $t2, 0($s1)
    bne $t0, $s5, verExit
    bne $t2, $s6, verExit
    
    move $t0, $s7
    addi $t0, $t0, -1
    sll $t0, $t0, 2
    
    add $t1, $t0, $s1
    add $t0, $t0, $s0
    
    lw $t2, 0($t0)
    sw $t2, 4($t0)
    
    lw $t2, 0($t1)
    sw $t2, 4($t1)
    
    
    addi $s7, $s7, 1
    
    jal     gera_maca

    # Ep?o
    verExit:
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

retirar_do_fim:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # Corpo do procedimento
    li      $a0, WHITE
    jal     set_foreground_color
    
    move $t0, $s0
    move $t1, $s1
    move $t2, $s7
    
    addi $t2, $t2, -1
    sll $t2, $t2, 2
    add  $t0, $t2, $t0
    add  $t1, $t2, $t1
    
    lw $t0, 0($t0)
    lw $t1, 0($t1)
    move    $a0, $t0
    move    $a1, $t1
    jal     put_pixel
    
    
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

verificar_derrota:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # Corpo do procedimento
    addi $t0, $s7, -1
    beqz $t0, derExit
    sll $t0, $t0, 2
    add $t1, $t0, $s1
    add $t0, $t0, $s0
    lw $t4, 0($s0)
    lw $t5, 0($s1)
    verFor:
    	lw $t3, 0($t0)
    	bne $t4, $t3, verElse
    	lw $t3, 0($t1)
    	bne $t5, $t3, verElse
    	j finit
    	
    	verElse:
    	addi $t0, $t0, -4
    	addi $t1, $t1, -4
    	
        bne $t0, $s0, verFor
    derExit:
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
