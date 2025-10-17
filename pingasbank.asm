# PingasBank
# Integrantes: Heitor, Joao Ricardo, Emanuel, Henrique.
#
.data
	# Menu Principal #
	separador: .asciiz "\n|================|\n"
	titulo: .asciiz "\nPingasBank\n"
	select_opt: .asciiz "\nSelecione uma Opcao:\n"
	opcao1: .asciiz "\n1. Exemplo 1\n"
	opcao_sair: .asciiz "\n2. Encerrar Aplicacao\n"
	prompt: .asciiz "\nDigite Sua escolha: "
	opcao_invalida: .asciiz "\nOpcao invalida. Tente novamente.\n"
	msg_em_construcao: .asciiz "\nFuncao em construcao...\n"
	goodbye: .asciiz "\nEncerrando o programa, ate mais!\n"
	
.text
.globl main

##### FUNCAO Main #####
 main:
  #Exibir Menu Principal
  jal display_menu_principal
  
  #receber input do usuario
  jal receber_input
  
  #trazer input de v0 para t0
  move $t0, $v0 
  
  #verificar se a resposta e valida
  li $t1, 1
  blt $t0, $t1, handle_opcao_invalida # Se for menor que 1, invalido
  li $t1, 2
  bgt $t0, $t1, handle_opcao_invalida # Se for maior que 2 (por agora), invalido 
  
  beq $t0, 1, handle_opcao1
  beq $t0, 2, encerrar_programa
  
##### FUNCAO Display Menu Principal #####
 display_menu_principal:
    #print do separador de cima
    li, $v0, 4
    la, $a0, separador 
    syscall
    
    li, $v0, 4
    la, $a0, titulo
    syscall
    
    li, $v0, 4
    la, $a0, separador 
    syscall
    
    #mensagem para selecionar opcao
    li, $v0, 4
    la, $a0, select_opt 
    syscall
    
    #printar opcoes
    li, $v0, 4
    la, $a0, opcao1
    syscall
    
    li, $v0, 4
    la, $a0, opcao_sair 
    syscall
    
    #retornar para Main
    jr $ra

receber_input:
    # Print prompt
    li $v0, 4
    la $a0, prompt
    syscall
    
    # Ler inteiro
    li $v0, 5
    syscall
    # Resultado esta em $v0
    
    #retornar para main
    jr $ra

##### FUNCAO handleOpcaoInvalida #####
handle_opcao_invalida:
    # Printar mensagem de opcao invalida
    li $v0, 4
    la $a0, opcao_invalida
    syscall
    #retornar para main
    j main

##### FUNCAO encerrarPrograma ######
encerrar_programa:
    # Print mensagem saida
    li, $v0, 4
    la, $a0, goodbye 
    syscall
    
    #sair do programa
    li, $v0, 10
    syscall
    
##### FUNCAO Opcao1 #####
handle_opcao1:
    # Print separador
    li, $v0, 4
    la, $a0, separador
    syscall
    
    # Print mensagem opcao1 
    li, $v0, 4
    la, $a0, opcao1
    syscall
    
    # Em construcao....
    li, $v0, 4
    la, $a0, msg_em_construcao
    syscall
    
    #retornar para funcao anterior
    jr $ra
    
    