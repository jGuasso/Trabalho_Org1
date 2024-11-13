#***********************************************************************************************************************
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Aula sobre procedimentos. Programa que retorna a soma do maior e do menor valor de uma lista
#***********************************************************************************************************************
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                   #

########################################################################################################################
.text
.globl main
########################################################################################################################


########################################################################################################################
# Inicia o programa. Realizamos as inicializações necessárias no programa, chamamos o procedimento principal main e em 
# seguida um código para terminar o programa
########################################################################################################################
init:
            la      $t0, main
            jalr    $t0                 # chama o procedimento principal
            la      $t0, finit
            jr      $t0                 # termina o programa
########################################################################################################################




########################################################################################################################
# Termina o programa, retornando o valor do procedimento main.
########################################################################################################################
finit:
            move    $a0, $v0            # o valor de retorno de main é colocado em $a0
            li      $v0, 17             # serviço 17: termina o programa
            syscall                     # fazemos a chamada ao serviço 17.
########################################################################################################################   



.include "display_bitmap.asm"





########################################################################################################################
# Mapa da Pilha
# $ra :     $sp+0   endereço de retorno do procedimento     
########################################################################################################################
main:
# prólogo
            addiu   $sp, $sp, -4        # ajusta a pilha
            sw      $ra, 0($sp)         # guarda na pilha o endereço de retorno
# corpo do programa
            # teste da inicialização da tela: versão inicial
            jal     init_graph_test
            # teste da inicialização da tela: versão otimizada
            jal     init2_graph_test
            # teste do desenho de linhas
            jal     lines_test
            # teste do desenho de retângulos
            jal     rectangles_test
            # teste do desenho de circulos
            jal     circles_test
            # teste do desenho de pontos
            jal     points_test


# epílogo
            lw      $ra, 0($sp)         # restaura o endereço de retorno
            addiu   $sp, $sp, 4         # restaura a pilha
            jr	    $ra                 # retorna ao procedimento chamador
########################################################################################################################


########################################################################################################################
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
init_graph_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, BLUE           # $a0 <- BLUE (azul)
            jal     set_background_color # escolhemos a cor azul para o fundo da tela
            jal     screen_init         # inicializamos a tela gráfica
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################



########################################################################################################################
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
init2_graph_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, GREEN
            jal     set_background_color
            jal     screen_init2        # inicializamos a tela gráfica, versão otimizada
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################


########################################################################################################################
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
lines_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, WHITE
            jal     set_foreground_color
            li      $a0, 0
            li      $a1, 0
            li      $a2, 63
            li      $a3, 63
            jal     draw_line
            li      $a0, 63
            li      $a1, 0
            li      $a2, 0
            li      $a3, 63
            jal     draw_line
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################


########################################################################################################################
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
rectangles_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, RED 
            jal     set_foreground_color
            li      $a0, 0
            li      $a1, 0
            li      $a2, 63
            li      $a3, 63
            jal     draw_rectangle
            li      $a0, 2
            li      $a1, 2
            li      $a2, 61
            li      $a3, 61
            jal     draw_rectangle
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################

########################################################################################################################
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
circles_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, FUCHSIA
            jal     set_foreground_color
            li      $a0, 31
            li      $a1, 31
            li      $a2, 10
            jal     draw_circle
            li      $a0, 31
            li      $a1, 31
            li      $a2, 20
            jal     draw_circle
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################




########################################################################################################################
# Mapa da Pilha
# $ra   :       $sp + 0 endereço de retorno do procedimento
########################################################################################################################
points_test:
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos o endereço de retorno na pilha
# corpo do procedimento
            li      $a0, BLACK
            jal     set_foreground_color
            li      $a0, 0
            li      $a1, 0
            jal     put_pixel
            li      $a0, PURPLE
            jal     set_foreground_color
            li      $a0, 63
            li      $a1, 0
            jal     put_pixel
            li      $a0, BLUE
            jal     set_foreground_color
            li      $a0, 0
            li      $a1, 63
            jal     put_pixel
            li      $a0, YELLOW
            jal     set_foreground_color
            li      $a0, 63
            li      $a1, 63
            jal     put_pixel
# epílogo
            lw      $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr	    $ra                 # retornamos ao procedimento chamador
########################################################################################################################


