########################################################################################################################
# Configuração do Bitmap Display
# Dimensões do pixel 16x16
# Dimensões da tela 512x512
########################################################################################################################

.text
########################################################################################################################
# Inicia o programa. Realizamos as inicializações necessárias no programa chamamos e o procedimento principal main
# Coloquei o Init primeiro, pois foi a única maneira do ".include display_bitmap.asm" não interferir nas inicializações de variáveis no .data
########################################################################################################################
init:
	    la $s0, x# coordenada x
	    la $s1, y# coordenada y
	    #carrega a coordenada inicial no centro do mapa
	    li $t0, 16
	    sw $t0, 0($s0)
	    sw $t0, 0($s1)
	    
	    #seed e constantes para geração de um número aleatório
	    la $s2, seed
	    
	    #Direção que a cobra está seguindo, inicializada com mExit, para não se mexer quando o jogo começar
	    la $s3, mExit
	    
	    #$s4 cor da cobra
	    #$s5 x da maca
	    #$s6 y da maca
	    
	    #comprimento da cobra
	    li $s7, 1
	    
	    #Função que pinta o fundo
	    jal     init_graph_test
	    #Inicialização da maçã
	    jal     gera_maca
            
            la      $t0, main
            jr    $t0                 # chama o procedimento principal
 ########################################################################################################################           
.include "display_bitmap.asm"            

########################################################################################################################
# Inicia o programa. Realizamos as inicializações necessárias no programa chamamos e o procedimento principal main
########################################################################################################################
.data
	 #Espaço máximo necessário para a cobra caso ela ocupe o tabuleiro inteiro
	 # 32 x 32 = 1024, cada word precisa de 2 bytes, então 1024 x 2 = 2048 
         x: .space 2048
         y: .space 2048
         
         #seed, constante multiplicativa, Incremento
         seed: .word 53, 13, 17
         #optei por números primos pois acho que fica mais difícil de criar padrões previsiveis
 
########################################################################################################################
        
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
# Procedimento principal de execução do programa     
########################################################################################################################
main:            
        # corpo do programa
        #carrego a cor inicial
        li $s4, NAVY
            lacoP:
 	    #Verifica se a maçã foi comida
 	    jal     verifica_pontuacao
 	    
 	    #Desenha a maçã na tela
 	    #Esse procedimento é chamado toda vez para não correr o risco da maçã ser apagada pela cobra
 	    jal     desenha_maca
 	    
 	    #Desenha a cobra
 	    jal     desenha_cobra
 	    
 	    #Move a cobra
 	    jal     mover_cobra
 	    
 	    #Verifica se bateu no proprio corpo da cobra
 	    jal    verificar_derrota
 	    
 	    #Volta para o laço
 	    j lacoP

# epílogo
            la      $t0, finit
            jr      $t0                 # termina o programa
########################################################################################################################
# Procedimento que pinta o fundo de branco
########################################################################################################################
init_graph_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, WHITE           # $a0 <- WHITE
            jal     set_background_color # escolhemos a cor branca para o fundo da tela
            jal     screen_init2         # inicializamos a tela gráfica
            
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

########################################################################################################################
# Desenha a cabeça da cobra(Parte dianteira)
########################################################################################################################
desenha_cobra:
	# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
        # corpo do procedimento
            #COR
            #cria efeito de mudança de cor durante o jogo
            addi $s4, $s4, 50 #soma 50 ao registrador que guarda a cor
            andi $s4, $s4, 0x00FFFFFF #máscara para evitar que extrapole o número necessário para representar a cor
            #Seleciona a cor
            move      $a0, $s4
            jal     set_foreground_color
            
            #passa as coordenadas
            lw      $a0, 0($s0)
            lw      $a1, 0($s1)
            jal     put_pixel
            
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

########################################################################################################################
# Procedimento que move a cabeça da cobra(parte dianteira)
########################################################################################################################
mover_cobra:
	    # prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
 #Recebe o caracter digitado no Keyboard and Display MMIO Simulator
            la    $t0, 0xFFFF0004   # endereço do RDR (Receiver Data Register)
            lw    $t2, 0($t0)       # $t2 <- caracter do terminal
            
            #Syscall de sleep de 100 milissegundos (0.1 segundos)
            #Para limitar a velocidade da cobra
            li $v0, 32 #Número da Syscall
            li $a0, 100 #Tempo de espera em milissegundos
            syscall

            #Para evitar movimentações erradas, como o usuario se movimentar contra o próprio corpo da cobra
            #Caso a cobra esteja se movimentando no eixo VERTICAL
            la $t3, mCima
            beq $t3, $s3, mHorizontal
            la $t3, mBaixo
            beq $t3, $s3, mHorizontal
            #Caso a cobra esteja se movimentando no eixo HORIZONTAL
            la $t3, mEsquerda
            beq $t3, $s3, mVertical
            la $t3, mDireita
            beq $t3, $s3, mVertical
            
            #Movimentações possíveis para o eixo vertical
            #Tratamento para os caracteres maiúsculos a partir de seu código ASCII
            mVertical:
            beq $t2, 0x77, mCima #w
            beq $t2, 0x57, mCima #W
            beq $t2, 0x73, mBaixo #s
            beq $t2, 0x53, mBaixo #S
            
            #Caso nenhum caractere valido seja verificado
            #Se a cobra estiver em movimento, continua na mesma direção
            #Se a cobra estiver parada, verificasse o eixo horizontal
            la $t3, mExit
            bne $s3, $t3, mElse
            
            
            
            #Movimentações possíveis para o eixo horizontal
            #Tratamento para os caracteres maiúsculos a partir de seu código ASCII
            mHorizontal:
            beq $t2, 0x44, mDireita #D
            beq $t2, 0x64, mDireita #d
            beq $t2, 0x41, mEsquerda #A
            beq $t2, 0x61, mEsquerda #a
            
            
            mElse:
            #Continua o mesmo movimento caso NENHUM caracter valido tenha sido digitado
            jr $s3
            
            #Movimentação para cima
            mCima:
            #Retira o fim da cobra
            jal retirar_do_fim
            
            #Altera o resto das coordenadas da cobra
            jal move_restante_cobra
            
                lw $t0, 0($s0) #$t0 <- x(cabeça da cobra)
                beq $t0, $zero, finit  # Caso a cobra bata na parte superior da tela
            	addi $t0, $t0, -1 #ajusta a posição da coordenada x da cabeça
            	sw $t0, 0($s0) #salva o ajuste
            	la $s3, mCima #salva a direção que a cobra está indo
            j mExit #pula pro final
            mBaixo:
            #Retira o fim da cobra
            jal retirar_do_fim
            
            #Altera o resto das coordenadas da cobra
            jal move_restante_cobra
            	lw $t0, 0($s0) #$t0 <- x(cabeça da cobra)
            	beq $t0, 31, finit # Caso a cobra bata na parte inferior da tela
            	addi $t0, $t0, 1  #ajusta a posição da coordenada x da cabeça
            	sw $t0, 0($s0) #salva o ajuste
            	la $s3, mBaixo #salva a direção que a cobra está indo
            j mExit #pula pro final
            
            mDireita:
            #Retira o fim da cobra
            jal retirar_do_fim
            
            #Altera o resto das coordenadas da cobra
            jal move_restante_cobra
            	lw $t1, 0($s1) #$t1 <- y(cabeça da cobra)
            	beq $t1, 31, finit # Caso a cobra bata na parte a direita da tela
            	addi $t1, $t1, 1 #ajusta a posição da coordenada y da cabeça
            	sw $t1, 0($s1)  #salva o ajuste
            	la $s3, mDireita #salva a direção que a cobra está indo
            j mExit  #pula pro final
            mEsquerda:
            #Retira o fim da cobra
            jal retirar_do_fim
            
            #Altera o resto das coordenadas da cobra
            jal move_restante_cobra
            	lw $t1, 0($s1) #$t1 <- y(cabeça da cobra)
            	beq $t1, $zero, finit # Caso a cobra bata na parte a esquerda da tela
            	addi $t1, $t1, -1 #ajusta a posição da coordenada y da cabeça
            	sw $t1, 0($s1)  #salva o ajuste
            	la $s3, mEsquerda #salva a direção que a cobra está indo
            
            mExit:# fim
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

########################################################################################################################
# Procedimento que atualiza o restante da cobra
########################################################################################################################         
move_restante_cobra:
    # Pr?o
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # corpo do procedimento
    #for(i=c;i>0;i--)
    #Comprimento - 1 pois a cabeça está na posição 0
    addi $t0, $s7, -1 # $t0 <- Comprimento - 1
    sll $t0, $t0, 2 # $t0 <- 4*(Comprimento - 1)
    #Seleciona a ultima posição de ambos arrays
    add $t1, $t0, $s1 # $t1 <- Y[Comprimento - 1]
    add $t0, $t0, $s0 # $t0 <- X[Comprimento - 1]
    
    #Se o endereço do inicio for igual ao final, pule para o final
    beq $t0, $s0, mrExit
    #laço para mover todas as coordenadas
    mrFor:
    	#X[Comprimento - i - 1] = X[Comprimento - i - 2]
    	lw $t3, -4($t0)#célula anterior(x)
    	sw $t3, 0($t0) #salva a célula anterior na próxima(x)
    	#Y[Comprimento - i - 1] = Y[Comprimento - i - 2]
    	lw $t3, -4($t1)#célula anterior(y)
    	sw $t3, 0($t1) #salva a célula anterior na próxima(y)
    	
    	#anda uma célula para trás
    	addi $t0, $t0, -4
    	addi $t1, $t1, -4
    	
    	 #Se a célula for diferente da inicial, continue o laço
        bne $t0, $s0, mrFor            
    
    # Ep?o
    mrExit:
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
########################################################################################################################

########################################################################################################################
# Desenha a maçã na posição salva nos registradores $s5(x) e $s6(y)
########################################################################################################################       
desenha_maca:
    # Pr?o
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    
    # Corpo do procedimento
    #Carrega a cor vermelha
    li      $a0, RED 
    jal     set_foreground_color
    #Coloca o pixel na tela
    move    $a0, $s5 #$a0 <- x da maçã
    move    $a1, $s6 #$a1 <- y da maçã
    jal     put_pixel#Coloca o pixel
    
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

########################################################################################################################

########################################################################################################################
# Gera as coordenadas da maca
########################################################################################################################       
gera_maca:
    # Pr?o
    addiu   $sp, $sp, -4         # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    
    # Corpo do procedimento
    jal     coordenada_aleatoria #Gera a coordenada aleatoria
    move    $s5, $v0           # Armazena a coordenada x da maçã
    jal     coordenada_aleatoria #Gera a coordenada aleatoria
    move    $s6, $v0           # Armazena a coordenada y da maçã
    
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4          # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador

########################################################################################################################

########################################################################################################################
# Gera as coordenada Pseudo-aleatória a partir de uma seed, e deconstantes de multiplicação e incremento
########################################################################################################################    
coordenada_aleatoria:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
     # Corpo do procedimento
    lw      $t1, 0($s2) #$t1 <- seed
    lw      $t2, 4($s2) #$t2 <- (a) constante multiplicativa
    lw      $t3, 8($s2) #$t3 <- (c) constante de incremento
    mul     $t0, $t1, $t2         # $t0 <- seed * a
    add     $t0, $t0, $t3         # $t0 <- ($t0 + c)
    

    # Limita? do intervalo
    li      $t1, 32               # Define o limite superior
    rem     $t0, $t0, $t1         # $t0 <- $t0 % 32
    
    sw      $t0, 0($s2)           # seed <- $t0
    move    $v0, $t0              # o retorno é $t0

    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador


########################################################################################################################

########################################################################################################################
# Verifica se o usuario pontuou (comeu a maçã)
########################################################################################################################   
verifica_pontuacao:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # Corpo do procedimento
    lw $t0, 0($s0) #$t0 <- x[0]
    lw $t2, 0($s1) #$t2 <- y[0]
    
    #Verifica a posição
    bne $t0, $s5, verExit# Se x[0] != x_maçã então saia
    bne $t2, $s6, verExit# Se y[0] != y_maçã então saia
    
    addi $s7, $s7, 1 #Incrementa o comprimento em 1
    
    #Gera uma nova maçã
    jal     gera_maca

    # Ep?o
    verExit:
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
########################################################################################################################

########################################################################################################################
# Retira a ultima célula da cobra para ela se movimentar
########################################################################################################################   
retirar_do_fim:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # Corpo do procedimento
    #Seleciona a cor branca(cor do fundo)
    li      $a0, WHITE
    jal     set_foreground_color
    
    move $t0, $s0#$t0<-X
    move $t1, $s1#$t1<-Y
    move $t2, $s7#$t2<-Comprimento
    
    #calcula o final da cobra
    addi $t2, $t2, -1#$t2 <- $t2 - 1 | (Comprimento - 1)
    sll $t2, $t2, 2  #$t2 <- $t2 * 4 | (Comprimento - 1)*4
    add  $t0, $t2, $t0#$t0 <- $t2 + $t0 | $t0 = &X[Comprimento-1](endereço)
    add  $t1, $t2, $t1#$t1 <- $t2 + $t1 | $t1 = &Y[Comprimento-1](endereço)
    
    #Carrega as coordenadas do final da cobra
    lw $a0, 0($t0) # $a0 <- X[Comprimento-1](valor)
    lw $a1, 0($t1) # $a1 <- Y[Comprimento-1](valor)
    jal     put_pixel #Coloca o pixel
    
    
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador


########################################################################################################################

########################################################################################################################
# Verifica se a cobra colidiu com o próprio corpo
########################################################################################################################  
verificar_derrota:
    # Pr?o
    addiu   $sp, $sp, -4          # Ajustamos a pilha
    sw      $ra, 0($sp)           # Armazenamos o endere?de retorno na pilha
    # Corpo do procedimento
    #acha as coordenadas finais do procedimento
    addi $t0, $s7, -1 #$t0 <- Comprimento - 1
        
    beqz $t0, derExit
    sll $t0, $t0, 2 #(Comprimento - 1)*4
    add $t1, $t0, $s1 #Y+(Comprimento - 1)*4
    add $t0, $t0, $s0 #X+(Comprimento - 1)*4
    lw $t4, 0($s0) # $t4 <- X[0]
    lw $t5, 0($s1) # $t5 <- Y[0]
    #Laço para verificar a cobra inteira
    verFor:
        #Verifica a posição
    	lw $t3, 0($t0) #$t3 <- X[Comprimento - i - 1]
    	#Se X[0] != X[Comprimento - i - 1] então vá para verElse
    	bne $t4, $t3, verElse
    	lw $t3, 0($t1) #$t3 <- Y[Comprimento - i - 1]
    	#Se Y[0] == Y[Comprimento - i - 1] então vá para verElse
    	bne $t5, $t3, verElse
    	#Se ambas coordenadas forem iguais o jogo acaba
    	j finit
    	
    	#Se pelo menos uma coordenada for diferente continua o laço
    	verElse:
    	#Retorna uma posição
    	#i = i-1
    	addi $t0, $t0, -4
    	addi $t1, $t1, -4
    	
    	#Quando i==0 a função acaba
        bne $t0, $s0, verFor
    derExit:
    # Ep?o
    lw      $ra, 0($sp)           # Restauramos o endere?de retorno
    addiu   $sp, $sp, 4           # Restauramos a pilha
    jr      $ra                   # Retornamos ao procedimento chamador
