#*******************************************************************************
# exercicio017.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo de procedimento para ler da ferramenta keyboard e escrever
#            na ferramenta display
#
# Para ler um caracter do keyboard
# 1. leia o conteúdo do endereço 0xFFFF0000 (receiver control register)
# 2. Verifique o bit menos significativo do receiver control register
# 3. Se 0 vá para o item 1 senão leia o caracter digitado do endreço
#    0xFFFF0004 (receiver data register)
#
# Para escrever um caracter em display
# 1. leia o conteúdo do endereço 0xFFFF0008 (transmitter control register)
# 2. Verifique o bit menos significativo do dado lido
# 3. Se 0 vá para o item 1 (continue esperando até que o bit menos
#    significativo do transmitter control register seja igual a 1).
#    Se 1 escreva no display. Isto é feito escrevendo um dado no
#    endereço 0xFFFF000C (transmitter data register).
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    ??/??/????     GBTO   versão inicial  
# 0.2    25.04.2018     GBTO   formatação e adição de Comentários
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #

.text
.globl main

################################################################################    
main:
#
# Subrotina main
# 
# Descrição: Esta subrotima lê os caracteres da ferramenta keyboard e
# escreve na ferramenta display.
#
# Argumentos: não existem argumentos para esta subrotina
################################################################################
loop:
            # lê caracter do teclado
            jal   wait_keyboard     # espera um caracter ser digitado
            li    $t0, 0xFFFF0004   # endereço do receiver data register
            lw    $s0, 0($t0)       # carrega caracter do receiver data register em S0
            # escreve no display
            jal   wait_display      # espera 
            li    $t0, 0xFFFF000C   # endereço do transmitter data register
            sw    $s0, 0($t0)       # escreve caracter no registrador transmitter data register
            j     loop              # repita 
            # o código a seguir não é executado
exit:    
            li    $v0, 10           # chama o serviço de saída para o sistema
    syscall
    
    
    
################################################################################    
wait_keyboard:
#
# Subrotina wait_keyboard
# 
# Descrição: Esta rotina espera que um caracter seja entrado pela
# ferramenta teclado. Ela espera que o bit menos significativo
# do endereço 0XFFFF0000 (receiver control register) seja igual a
# 1, inidcando que um caracter foi digitado
#
# Argumentos:
#           não existem argumentos para esta subrotina
################################################################################    

# prólogo
            sub   $sp, $sp, 4       # ajusta a pilha para guardar um item
            sw    $ra, 0($sp)       # salva o valor de $ra
# corpo do procedimento            
            li    $a0, 0xFFFF0000   # ao <- endereço do receiver control register
            jal   wait              # espera bit LSB de 0xFFFF0000 ser 1
# epílogo            
            lw    $ra, 0($sp)       # restaura o valor de $ra
            add   $sp, $sp, 4       # ajusta a pilha para remover 1 item
            jr    $ra           # retorna
################################################################################            
            
            
            
################################################################################    
wait_display:
#
# Subrotina wait_display
# 
# Descrição: Esta subrotina espera até que o mostrador (display)
# esteja disponível para apresentar um caracter. Ela espera que o bit
# menos significativo do endereço 0xFFFF0008 (transmitter control register
# seja igual a 1, indicando que um novo caracter pode ser apresentado
# no mostrador (display)
#
# Argunentos:
#           não existem argumentos para esta subrotina
################################################################################
# prólogo
            sub   $sp, $sp, 4       # ajusta a pilha para guardar 1 item
            sw    $ra, 0($sp)       # salva o valor de $ra
# corpo do procedimento    
            li    $a0, 0xFFFF0008   # a0 <- endereço do transmitter control register
            jal   wait              # espera bit LSB de 0xFFFF0008 ser 1
#epílogo
            lw    $ra, 0($sp)       # restaura o valor de $ra
            add   $sp, $sp, 4       # ajusta a pilha removendo 1 item
            jr    $ra               # retorne
################################################################################    
    
    
    
################################################################################    
wait:
#
# Subrotina wait
# 
# Descrição: Esta rotina entra em um laço, retornando somente
# quando o bit menos significativo de um endereço entregue como
# argumento é igual a 1. Este procedimento é usado para verificar
# se o mostrador ou o teclado da ferramenta keyboard and display
# simulator pode apresentar um caracter ou possui um caracter 
# digitado.Usamos os seguintes endereços:
#
# Endereço
# 0xFFFF0008    Mostrador (display) - Transmitter control register
# 0xFFFF0000    teclado (keyboard) - Receiver control register
#
# Argunentos:
#        $a0: o endereço que deve ser monitorado o bit menos significativo
################################################################################

# prólogo
# corpo do procedimento
            lw    $t0, 0($a0)       # carrega o dado do endereço
            and   $t0, 0x00000001   # isola o bit menos significativo
            beq   $t0, $zero, wait  # se bit LSB=0 repita
# epílogo    
            jr    $ra               # retorne
################################################################################    

