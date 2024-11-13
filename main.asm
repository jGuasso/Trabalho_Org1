.text
.globl main


########################################################################################################################
# Inicia o programa. Realizamos as inicializaÃ§Ãµes necessÃ¡rias no programa, chamamos o procedimento principal main e em 
# seguida um cÃ³digo para terminar o programa
########################################################################################################################
init:
	    li $s0, 0x10014120#x
	    li $s1, 0x10014320#y
	    li $t0, 32
	    sw $t0, 0($s0)
	    sw $t0, 0($s1)
	    li $s2, 0x10014100#seed e constantes
	    li $t0, 1323 #seed
	    sw $t0, 0($s2)
	    li $t0, 279 #constante multiplicativa
	    sw $t0, 4($s2)
	    li $t0, 23423 # Incremento
	    sw $t0, 8($s2)
	    
	    #$s3 direcao da cobra
	    #  0:cima
	    #  1:baixo
	    #  2:esquerda
	    #  3: direita
	    
	    #$s5 x da maca
	    #$s6 y da maca
	    li $s7, 2 #comprimento
	    jal     init_graph_test
            
            la      $t0, main
            jr    $t0                 # chama o procedimento principal
########################################################################################################################




########################################################################################################################
# Termina o programa, retornando o valor do procedimento main.
########################################################################################################################
finit:
            move    $a0, $v0            # o valor de retorno de main Ã© colocado em $a0
            li      $v0, 17             # serviÃ§o 17: termina o programa
            syscall                     # fazemos a chamada ao serviÃ§o 17.
########################################################################################################################   


.include "display_bitmap.asm"





########################################################################################################################
# Mapa da Pilha
# $ra :     $sp+0   endereÃ§o de retorno do procedimento     
########################################################################################################################
main:            
        # corpo do programa
            lacoP:
 	    # desenho da cobra
 	    jal     verifica_pontuacao
 	    jal     desenha_cobra
 	    
 	    jal     mover_cobra
 	    
 	    j lacoP
 
# epÃ­logo
            la      $t0, finit
            jr      $t0                 # termina o programa
 
# Mapa da Pilha
# $ra   :       $sp + 0 endereÃ§o de retorno do procedimento
########################################################################################################################
init_graph_test:
# prÃ³logo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereÃ§o de retorno na pilha
# corpo do procedimento
            li      $a0, WHITE           # $a0 <- BLUE (azul)
            jal     set_background_color # escolhemos a cor azul para o fundo da tela
            jal     screen_init2         # inicializamos a tela grÃ¡fica
            
            jal     desenha_maca
# epÃ­logo
            lw      $ra, 0($sp)         # restauramos o endereÃ§o de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

desenha_cobra:
	# prÃ³logo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereÃ§o de retorno na pilha
        # corpo do procedimento
            li      $a0, GREEN
            jal     set_foreground_color
            lw      $t0, 0($s0)
            lw      $t1, 0($s1)
            or      $a0, $zero, $t0
            or      $a1, $zero, $t1
            jal     put_pixel
            
# epÃ­logo
            lw      $ra, 0($sp)         # restauramos o endereÃ§o de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

mover_cobra:
	    # prÃ³logo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereÃ§o de retorno na pilha
 # esperamos um caracter no terminal
            la    $t0, 0xFFFF0000   # endereÃ§o do RCR
	
            
            # lemos o carcater
            la    $t0, 0xFFFF0004   # endereÃ§o do RDR
            lw    $t2, 0($t0)       # $t2 <- caracter do terminal
            
            beq $t2, 0x77, mCima
            beq $t2, 0x57, mCima
            beq $t2, 0x73, mBaixo
            beq $t2, 0x53, mBaixo
            beq $t2, 0x44, mDireita
            beq $t2, 0x64, mDireita
            beq $t2, 0x41, mEsquerda
            beq $t2, 0x61, mEsquerda
            
            j mExit
            mCima:
            beq $s3, 1, mExit
            jal move_restante_cobra
            jal retirar_do_fim
                lw $t0, 0($s0)
                beq $t0, $zero, mExit
            	addi $t0, $t0, -1
            	sw $t0, 0($s0)
            	li $s3, 0
            j mExit
            mBaixo:
            beq $s3, 0, mExit
            jal move_restante_cobra
            jal retirar_do_fim
            	lw $t0, 0($s0)
            	beq $t0, 63, mExit
            	addi $t0, $t0, 1
            	sw $t0, 0($s0)
            	li $s3, 1
            j mExit
            
            mDireita:
            beq $s3, 3, mExit
            jal move_restante_cobra
            jal retirar_do_fim
            	lw $t1, 0($s1)
            	beq $t1, 63, mExit
            	addi $t1, $t1, 1
            	sw $t1, 0($s1)
            	li $s3, 3
            j mExit
            mEsquerda:
            beq $s3, 2, mExit
            jal move_restante_cobra
            jal retirar_do_fim
            	lw $t1, 0($s1)
            	beq $t1, $zero, mExit
            	addi $t1, $t1, -1
            	sw $t1, 0($s1)	
            	li $s3, 2
            
            mExit:
# epÃ­logo
            lw      $ra, 0($sp)         # restauramos o endereÃ§o de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
            
move_restante_cobra:
    # Prólogo
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endereço de retorno na pilha
    # corpo do procedimento
    #for(i=c;i>0;i--)
    move $t0, $s7
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
    
    # Epílogo
    mrExit:
    lw      $ra, 0($sp)           # Restauramos o endereço de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
            
desenha_maca:
    # Prólogo
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endereço de retorno na pilha
    
    # Corpo do procedimento
    li      $a0, RED
    jal     set_foreground_color
    jal     coordenada_aleatoria
    move    $s5, $v0           # Armazena a coordenada x
    jal     coordenada_aleatoria
    move    $s6, $v0
    move    $a0, $s5
    move    $a1, $s6
    jal     put_pixel
    
    # Epílogo
    lw      $ra, 0($sp)           # Restauramos o endereço de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

coordenada_aleatoria:
    # Prólogo
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endereço de retorno na pilha
    lw      $t1, 0($s2)
    lw      $t2, 4($s2)
    lw      $t3, 8($s2)
    # Corpo do procedimento - Geração de número aleatório
    mul     $t0, $t1, $t2         # $t0 = seed * a
    add     $t0, $t0, $t3         # $t0 = ($t0 + c)
    

    # Limitação do intervalo
    li      $t1, 64               # Define o limite superior (exclusivo)
    rem     $t0, $t0, $t1         # Calcula o valor aleatório entre 0 e 63
    
    sw      $t0, 0($s2)
    move    $v0, $t0

    # Epílogo
    lw      $ra, 0($sp)           # Restauramos o endereço de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador


verifica_pontuacao:
    # Prólogo
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endereço de retorno na pilha

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
    
    jal     desenha_maca

    # Epílogo
    verExit:
    lw      $ra, 0($sp)           # Restauramos o endereço de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

retirar_do_fim:
    # Prólogo
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endereço de retorno na pilha
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
    
    
    # Epílogo
    lw      $ra, 0($sp)           # Restauramos o endereço de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
