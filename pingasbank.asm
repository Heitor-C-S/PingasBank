# PingasBank
# Integrantes: Heitor, Joao Ricardo, Emanuel, Henrique.
#
.data
    # # # ATRIBUTOS DE CONTA DO CLIENTE : # # #
    # - CPF: 12 bytes (11 digitos + '\0')                       (Offset 0)
    # - Conta completa (com DV): 8 bytes (6 digitos + DV + '\0')  (Offset 12)
    # - Nome: 50 bytes                                          (Offset 20)
    # - Padding: 2 bytes (para alinhar Saldo)                   (Offset 70)
    # - Saldo: 4 bytes (inteiro em centavos)                    (Offset 72)
    # - Limite credito: 4 bytes                                 (Offset 76)
    # - Credito usado: 4 bytes                                  (Offset 80)
    # - Status ativo: 4 bytes (0=inativo, 1=ativo)              (Offset 84)
    # - Padding: 38 bytes (para alinhar em 128)                 (Offset 88)
    
    clientes: .space 6400 #50 clientes para 128 bytes cada;
    num_clientes: .word 0 #contador de clientes ativos
    
    # Buffers de conta e arquivo: #
    buffer_comando: .space 256
    buffer_cpf: .space 12
    buffer_conta: .space 8
    buffer_conta_completa: .space 10  # XXXXXX-D\0
    buffer_nome: .space 51
    buffer_temp: .space 100        # Usado para parsear o comando
    buffer_args: .space 200        # Usado para guardar o ponteiro dos args
    buffer_arquivo: .space 8000  # Buffer para ler arquivo completo
    buffer_cpf_busca: .space 12
    buffer_confirmar_opcao: .space 4 #buffer para o S/N (estava com problemas de não rodar)

    # Constantes globais
    limite_credito_padrao: .word 150000 # R$1500,00
    max_clientes: .word 50
    
    #####  Mensagens do sistema #####
    msg_sucesso_cadastro: .asciiz "\nCliente cadastrado com sucesso. Numero da conta "
    msg_cpf_duplicado: .asciiz "\nJa existe conta neste CPF\n"
    msg_conta_duplicada: .asciiz "\nNumero da conta ja em uso\n"
    msg_limite_clientes: .asciiz "\nLimite maximo de clientes atingido\n"
    msg_comando_invalido: .asciiz "\nComando invalido\n"
    newline: .asciiz "\n"
    hifen: .asciiz "-"
    msg_str_zero: .asciiz "0"
    msg_str_rs: .asciiz "R$" 
    msg_str_virgula: .asciiz ","

    # Strings para impressão em conta_buscar
    msg_str_cpf: .asciiz "\nCPF: "
    msg_str_conta: .asciiz "\nConta: "
    msg_str_nome: .asciiz "\nNome: "
    msg_str_saldo: .asciiz "\nSaldo: "
    msg_str_limite: .asciiz "\nLimite de Credito: "
    msg_str_credito_usado: .asciiz "\nCredito Usado: "

    msg_deposito_sucesso: .asciiz "\nDeposito realizado com sucesso\n"
    msg_saque_sucesso: .asciiz "\nSaque realizado com sucesso\n"
    msg_saldo_insuficiente: .asciiz "\nFalha: saldo insuficente\n"
    msg_cliente_inexistente: .asciiz "\nFalha: cliente inexistente\n"
    
    msg_em_construcao: .asciiz "\nEm construcao...\n"
    
    # Nome do arquivo # ainda não implementado, sujeito a mucanças
    arquivo_nome: .asciiz "pingasbank_data.txt"
    
    # Delimitadores # (Mantidos mas funções comentadas)
    virgula: .asciiz ","
    ponto_virgula: .asciiz ";"
    abre_parentese: .asciiz "("
    abre_chave: .asciiz "{"
    fecha_chave: .asciiz "}"
    fecha_parentese: .asciiz ")"
    underscore: .asciiz "_"
    
    
    # Menu Principal - CLI #
    prompt_cli: .asciiz "\nPingasBank> "
    goodbye: .asciiz "\nEncerrando o programa, ate mais!\n"

    # Nomes dos Comandos para Comparação #
    str_conta_cadastrar: .asciiz "conta_cadastrar"
    str_conta_format: .asciiz "conta_format"
    str_conta_fechar: .asciiz "conta_fechar"
    str_conta_buscar: .asciiz "conta_buscar"
    str_debito_extrato: .asciiz "debito_extrato"
    str_credito_extrato: .asciiz "credito_extrato"
    str_transferir_debito: .asciiz "transferir_debito"
    str_transferir_credito: .asciiz "transferir_credito"
    str_pagar_fatura: .asciiz "pagar_fatura"
    str_sacar: .asciiz "sacar"
    str_depositar: .asciiz "depositar"
    str_alterar_limite: .asciiz "alterar_limite"
    str_data_hora: .asciiz "data_hora"
    str_salvar: .asciiz "salvar"
    str_recarregar: .asciiz "recarregar"
    str_formatar: .asciiz "formatar"
    str_encerrar: .asciiz "encerrar"  
    
.text
.globl main

##### FUNCAO Main - LOOP CLI #####
main:
    # Salva o ponteiro para os argumentos em $s1
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    
    cli_loop:
        # Mostrar o prompt
        li $v0, 4
        la $a0, prompt_cli
        syscall
        
        # Ler o comando inteiro do usuário
        li $v0, 8
        la $a0, buffer_comando
        li $a1, 256
        syscall
        
        # Limpar o newline do comando
        la $a0, buffer_comando
        jal limpar_newline_comando
        
        # Parsear o COMANDO (a parte antes do primeiro '-')
        la $a0, buffer_temp        # Destino
        li $a1, '-'                # Delimitador
        la $a2, buffer_comando     # Fonte
        jal parse_campo
        move $s1, $v0              # Salva o ponteiro para o RESTO (argumentos) em $s1
        
        # -- Início do Bloco de Comparação de Comandos --
        
        la $a0, buffer_temp
        la $a1, str_conta_cadastrar
        jal strcmp
        beqz $v0, handle_conta_cadastrar
        
        la $a0, buffer_temp
        la $a1, str_conta_buscar
        jal strcmp
        beqz $v0, handle_conta_buscar 
        
        la $a0, buffer_temp
        la $a1, str_encerrar
        jal strcmp
        beqz $v0, handle_encerrar

        # --- Comandos "Em Construção" --- #
        
        la $a0, buffer_temp
        la $a1, str_conta_format
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_conta_fechar
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_debito_extrato
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_credito_extrato
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_transferir_debito
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_transferir_credito
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_pagar_fatura
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_sacar
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_depositar
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_alterar_limite
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_data_hora
        jal strcmp
        beqz $v0, handle_em_construcao
        
        la $a0, buffer_temp
        la $a1, str_salvar
        jal strcmp
        beqz $v0, handle_em_construcao 
        
        la $a0, buffer_temp
        la $a1, str_recarregar
        jal strcmp
        beqz $v0, handle_em_construcao 
        
        la $a0, buffer_temp
        la $a1, str_formatar
        jal strcmp
        beqz $v0, handle_em_construcao 
        
        # --- Fim dos Comandos ---
        
        # Se chegou aqui, o comando é inválido
        li $v0, 4
        la $a0, msg_comando_invalido
        syscall
        j cli_loop

# --- Handlers de Comandos ---

handle_conta_cadastrar:
    # $s1 já contém o ponteiro para os argumentos
    
    # 1. Parsear CPF (arg1)
    la $a0, buffer_cpf
    li $a1, '-'
    move $a2, $s1
    jal parse_campo
    move $s1, $v0  # Atualiza ponteiro de argumentos
    
    # 2. Parsear Conta (arg2)
    la $a0, buffer_conta
    li $a1, '-'
    move $a2, $s1
    jal parse_campo
    move $s1, $v0  # Atualiza ponteiro de argumentos
    
    # 3. Parsear Nome (arg3 - é o resto da string)
    la $a0, buffer_nome
    move $a1, $s1
    jal strcpy # Copia o resto da string
    
    # 4. Executar a lógica de cadastro
    jal logica_cadastro_cliente
    
    j cli_loop

##### NOVA FUNCAO Handler para conta_buscar #####
handle_conta_buscar:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp) # Salvar $s0 (ponteiro do cliente)

    # $s1 já contém o ponteiro para os argumentos (a conta XXXXXX-X)

    # 1. Copiar o argumento (conta) para um buffer temporário
    la $a0, buffer_temp # Destino
    move $a1, $s1        # Fonte (o resto da linha de comando)
    jal strcpy

    # 2. Buscar cliente usando a conta no buffer_temp
    la $a0, buffer_temp
    jal buscar_cliente_por_conta_completa # Retorna ponteiro em $v0, ou 0

    # 3. Verificar se cliente foi encontrado
    beqz $v0, buscar_conta_nao_encontrado
    move $s0, $v0 # Salvar ponteiro do cliente em $s0

    # 4. Imprimir detalhes do cliente encontrado
    # CPF
    li $v0, 4
    la $a0, msg_str_cpf
    syscall
    la $a0, 0($s0) # Offset 0 = CPF
    syscall

    # Conta Formatada (XXXXXX-X)
    li $v0, 4
    la $a0, msg_str_conta
    syscall
    la $t0, 12($s0) # Offset 12 = Conta Completa (sem hifen)
    li $t1, 0
    loop_exibir_conta_busca:
        bge $t1, 6, exibir_hifen_conta_busca
        lb $a0, 0($t0)
        li $v0, 11
        syscall
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        j loop_exibir_conta_busca
    exibir_hifen_conta_busca:
        li $v0, 4
        la $a0, hifen
        syscall
        lb $a0, 0($t0) # Exibe o 7º caractere (DV)
        li $v0, 11
        syscall

    # Nome
    li $v0, 4
    la $a0, msg_str_nome
    syscall
    la $a0, 20($s0) # Offset 20 = Nome
    syscall

    # Saldo
    li $v0, 4
    la $a0, msg_str_saldo
    syscall
    lw $a0, 72($s0) # Offset 72 = Saldo
    jal print_moeda # print_moeda já imprime newline no final

    # Limite de Crédito
    li $v0, 4
    la $a0, msg_str_limite
    syscall
    lw $a0, 76($s0) # Offset 76 = Limite
    jal print_moeda # print_moeda já imprime newline no final

    # Crédito Usado
    li $v0, 4
    la $a0, msg_str_credito_usado
    syscall
    lw $a0, 80($s0) # Offset 80 = Credito Usado
    jal print_moeda # print_moeda já imprime newline no final

    # Imprime um newline extra no final da consulta
    li $v0, 4
    la $a0, newline
    syscall

    j fim_handle_conta_buscar # Pula a mensagem de erro

buscar_conta_nao_encontrado:
    li $v0, 4
    la $a0, msg_cliente_inexistente
    syscall

fim_handle_conta_buscar:
    lw $s0, 4($sp) # Restaurar $s0
    lw $ra, 0($sp)
    addi $sp, $sp, 8
    # jr $ra  <-- ERRO AQUI: Retorna para o meio do handler, causando loop
    j cli_loop # <-- CORREÇÃO: Deve saltar de volta para o loop principal

handle_em_construcao:
    li $v0, 4
    la $a0, msg_em_construcao
    syscall
    j cli_loop

handle_encerrar:
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    jal encerrar_programa
    # Nao volta

##### FUNCAO Encerrar Programa #####
encerrar_programa:
    li $v0, 4
    la $a0, goodbye
    syscall

    li $v0, 10
    syscall

##### FUNCAO logica_cadastro_cliente (Refatorada) #####
# Esta função assume que buffer_cpf, buffer_conta, e buffer_nome
# já foram preenchidos pelo 'main'
logica_cadastro_cliente:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Verificar limite de clientes
    la $t0, num_clientes
    lw $t1, 0($t0)
    la $t2, max_clientes
    lw $t3, 0($t2)
    bge $t1, $t3, erro_limite_clientes

    # Verificar se CPF já existe
    la $a0, buffer_cpf
    jal verificar_cpf_existe
    beq $v0, 1, erro_cpf_duplicado

    # Verificar se conta já existe
    la $a0, buffer_conta
    jal verificar_conta_existe
    beq $v0, 1, erro_conta_duplicada

    # Calcular dígito verificador
    la $a0, buffer_conta
    jal calcular_digito_verificador

    # Adicionar DV ao final da conta
    la $t0, buffer_conta
    addi $t0, $t0, 6

    beq $v0, 10, dv_x_cadastrar
    addi $t1, $v0, 48
    sb $t1, 0($t0)
    j fim_dv_cadastrar

    dv_x_cadastrar:
        li $t1, 'X'
        sb $t1, 0($t0)

    fim_dv_cadastrar:
        addi $t0, $t0, 1
        sb $zero, 0($t0)

    # Adicionar cliente
    la $a0, buffer_cpf
    la $a1, buffer_conta
    la $a2, buffer_nome
    jal adicionar_cliente

    # Mensagem de sucesso
    li $v0, 4
    la $a0, msg_sucesso_cadastro
    syscall

    # Exibir conta com DV
    la $t0, buffer_conta
    li $t1, 0
    loop_exibir_conta_cad:
        bge $t1, 6, exibir_hifen_conta_cad
        lb $a0, 0($t0)
        li $v0, 11
        syscall
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        j loop_exibir_conta_cad

    exibir_hifen_conta_cad:
        li $v0, 4
        la $a0, hifen
        syscall

        lb $a0, 0($t0)
        li $v0, 11
        syscall

        li $v0, 4
        la $a0, newline
        syscall

        j fim_cadastro_cliente

    erro_limite_clientes:
        li $v0, 4
        la $a0, msg_limite_clientes
        syscall
        j fim_cadastro_cliente

    erro_cpf_duplicado:
        li $v0, 4
        la $a0, msg_cpf_duplicado
        syscall
        j fim_cadastro_cliente

    erro_conta_duplicada:
        li $v0, 4
        la $a0, msg_conta_duplicada
        syscall

    fim_cadastro_cliente:
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

# --- Funções de "Em Construção" ---
# (Elas são todas tratadas pelo 'handle_em_construcao' no main)

##### FUNCOES DE LIMPEZA DE NEWLINE (MANTIDAS) #####

# Limpador genérico para buffer_comando
limpar_newline_comando:
    la $t0, buffer_comando
    loop_limpar_comando:
        lb $t2, 0($t0)
        beq $t2, '\n', fim_limpar_comando
        beqz $t2, fim_limpar_comando
        addi $t0, $t0, 1
        j loop_limpar_comando
    fim_limpar_comando:
        sb $zero, 0($t0)
        jr $ra

limpar_newline_cpf:
    la $t0, buffer_cpf
    li $t1, 0
    loop_limpar_cpf:
        lb $t2, 0($t0)
        beq $t2, '\n', fim_limpar_cpf
        beqz $t2, fim_limpar_cpf
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        blt $t1, 11, loop_limpar_cpf
    fim_limpar_cpf:
        sb $zero, 0($t0)
        jr $ra

limpar_newline_cpf_busca:
    la $t0, buffer_cpf_busca
    li $t1, 0
    loop_limpar_cpf_busca:
        lb $t2, 0($t0)
        beq $t2, '\n', fim_limpar_cpf_busca
        beqz $t2, fim_limpar_cpf_busca
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        blt $t1, 11, loop_limpar_cpf_busca
    fim_limpar_cpf_busca:
        sb $zero, 0($t0)
        jr $ra

limpar_newline_conta:
    la $t0, buffer_conta
    li $t1, 0
    loop_limpar_conta:
        lb $t2, 0($t0)
        beq $t2, '\n', fim_limpar_conta
        beqz $t2, fim_limpar_conta
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        blt $t1, 6, loop_limpar_conta
    fim_limpar_conta:
        sb $zero, 0($t0)
        jr $ra

limpar_newline_nome:
    la $t0, buffer_nome
    loop_limpar_nome:
        lb $t2, 0($t0)
        beq $t2, '\n', fim_limpar_nome
        beqz $t2, fim_limpar_nome
        addi $t0, $t0, 1
        j loop_limpar_nome
    fim_limpar_nome:
        sb $zero, 0($t0)
        jr $ra

limpar_newline_temp:
    la $t0, buffer_temp
    loop_limpar_temp:
        lb $t2, 0($t0)
        beq $t2, '\n', fim_limpar_temp
        beqz $t2, fim_limpar_temp
        addi $t0, $t0, 1
        j loop_limpar_temp
    fim_limpar_temp:
        sb $zero, 0($t0)
        jr $ra

##### FUNCAO Calcular Digito Verificador (MANTIDA) #####
calcular_digito_verificador:
    move $t0, $a0
    li $t1, 0

    # d0 (pos 5) * 2
    lb $t2, 5($t0)
    addi $t2, $t2, -48
    mul $t2, $t2, 2
    add $t1, $t1, $t2

    # d1 (pos 4) * 3
    lb $t2, 4($t0)
    addi $t2, $t2, -48
    mul $t2, $t2, 3
    add $t1, $t1, $t2

    # d2 (pos 3) * 4
    lb $t2, 3($t0)
    addi $t2, $t2, -48
    mul $t2, $t2, 4
    add $t1, $t1, $t2

    # d3 (pos 2) * 5
    lb $t2, 2($t0)
    addi $t2, $t2, -48
    mul $t2, $t2, 5
    add $t1, $t1, $t2

    # d4 (pos 1) * 6
    lb $t2, 1($t0)
    addi $t2, $t2, -48
    mul $t2, $t2, 6
    add $t1, $t1, $t2

    # d5 (pos 0) * 7
    lb $t2, 0($t0)
    addi $t2, $t2, -48
    mul $t2, $t2, 7
    add $t1, $t1, $t2

    # Resto da divisão por 11
    li $t3, 11
    div $t1, $t3
    mfhi $v0

    jr $ra


##### FUNCAO Verificar CPF Existe #####
verificar_cpf_existe:
    la $t0, clientes
    la $t1, num_clientes
    lw $t2, 0($t1)
    li $t3, 0

    loop_verif_cpf:
        bge $t3, $t2, cpf_nao_existe
        lw $t4, 84($t0) # Offset 84 = status
        beqz $t4, proximo_cliente_cpf

        move $t5, $t0
        move $t6, $a0
        li $t7, 0

        loop_cmp_cpf:
            lb $t8, 0($t5)
            lb $t9, 0($t6)
            bne $t8, $t9, proximo_cliente_cpf
            beqz $t8, cpf_existe
            addi $t5, $t5, 1
            addi $t6, $t6, 1
            addi $t7, $t7, 1
            blt $t7, 11, loop_cmp_cpf

        cpf_existe:
            li $v0, 1
            jr $ra

        proximo_cliente_cpf:
            addi $t0, $t0, 128
            addi $t3, $t3, 1
            j loop_verif_cpf

    cpf_nao_existe:
        li $v0, 0
        jr $ra

##### FUNCAO Verificar Conta Existe (MANTIDA E CORRIGIDA) #####
verificar_conta_existe:
    la $t0, clientes
    la $t1, num_clientes
    lw $t2, 0($t1)
    li $t3, 0

    loop_verif_conta:
        bge $t3, $t2, conta_nao_existe
        lw $t4, 84($t0) # Offset 84 = status
        beqz $t4, proximo_cliente_conta

        addi $t5, $t0, 12
        move $t6, $a0
        li $t7, 0

        loop_cmp_conta:
            lb $t8, 0($t5)
            lb $t9, 0($t6)
            bne $t8, $t9, proximo_cliente_conta
            beqz $t9, conta_existe
            addi $t5, $t5, 1
            addi $t6, $t6, 1
            addi $t7, $t7, 1
            blt $t7, 6, loop_cmp_conta

        conta_existe:
            li $v0, 1
            jr $ra

        proximo_cliente_conta:
            addi $t0, $t0, 128
            addi $t3, $t3, 1
            j loop_verif_conta

      conta_nao_existe:
        li $v0, 0
        jr $ra

##### FUNCAO Buscar Cliente por Conta Completa #####
# Esta função é um HELPER, chamada por handle_conta_buscar
# Entrada: $a0 = endereço da string conta (ex: 123456-7) NO BUFFER_TEMP
# Saída: $v0 = ponteiro para o cliente, 0 se não existe
buscar_cliente_por_conta_completa:
 addi $sp, $sp, -4
 sw $ra, 0($sp)

 # Formatar a conta de busca (123456-7) para o formato salvo (1234567\0)
 # A conta já está em $a0 (buffer_temp), vamos formatá-la no buffer_conta_completa
 la $t0, buffer_conta_completa # Buffer de destino (limpo)
 move $t1, $a0                 # Buffer de origem (com hifen)
 li $t2, 0                     # Contador

 loop_formatar_conta_busca_interno: # Renomeado para evitar conflito
  lb $t3, 0($t1)
  beqz $t3, fim_formatar_conta_busca_interno
  beq $t3, '-', proximo_char_conta_busca_interno # Pula o hifen

  sb $t3, 0($t0)
  addi $t0, $t0, 1
  addi $t2, $t2, 1

 proximo_char_conta_busca_interno:
  addi $t1, $t1, 1
  j loop_formatar_conta_busca_interno

 fim_formatar_conta_busca_interno:
  sb $zero, 0($t0) # Termina a string formatada

 # Agora, $a0 (buffer_conta_completa) contém "1234567"
 la $a0, buffer_conta_completa

 # Loop principal de busca
 la $t0, clientes
 la $t1, num_clientes
 lw $t2, 0($t1)  # número de clientes
 li $t3, 0   # contador

 loop_buscar_conta_comp_interno: # Renomeado para evitar conflito
  bge $t3, $t2, buscar_conta_comp_nao_existe_interno
  lw $t4, 84($t0) # Offset 84 = status
  beqz $t4, proximo_buscar_conta_comp_interno

  addi $t5, $t0, 12 # ponteiro conta cliente
  move $t6, $a0  # ponteiro conta busca (formatada)

  loop_cmp_buscar_conta_comp_interno:
   lb $t8, 0($t5)
   lb $t9, 0($t6)
   bne $t8, $t9, proximo_buscar_conta_comp_interno
   beqz $t8, buscar_conta_comp_encontrado_interno # fim da string e iguais
   addi $t5, $t5, 1
   addi $t6, $t6, 1
   j loop_cmp_buscar_conta_comp_interno

  buscar_conta_comp_encontrado_interno:
   move $v0, $t0
   j fim_buscar_conta_comp_interno

  proximo_buscar_conta_comp_interno:
   addi $t0, $t0, 128  # próximo cliente
   addi $t3, $t3, 1
   j loop_buscar_conta_comp_interno

 buscar_conta_comp_nao_existe_interno:
  li $v0, 0

 fim_buscar_conta_comp_interno:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

##### FUNCAO Adicionar Cliente (MANTIDA E CORRIGIDA) #####
adicionar_cliente:
    la $t0, clientes
    la $t1, num_clientes
    lw $t2, 0($t1)

    mul $t3, $t2, 128
    add $t0, $t0, $t3

    move $t4, $a0
    move $t5, $t0
    li $t6, 0
    loop_copy_cpf:
        lb $t7, 0($t4)
        sb $t7, 0($t5)
        beqz $t7, fim_copy_cpf
        addi $t4, $t4, 1
        addi $t5, $t5, 1
        addi $t6, $t6, 1
        blt $t6, 11, loop_copy_cpf
    fim_copy_cpf:

    move $t4, $a1
    addi $t5, $t0, 12
    li $t6, 0
    loop_copy_conta:
        lb $t7, 0($t4)
        sb $t7, 0($t5)
        beqz $t7, fim_copy_conta
        addi $t4, $t4, 1
        addi $t5, $t5, 1
        addi $t6, $t6, 1
        blt $t6, 7, loop_copy_conta
    fim_copy_conta:

    move $t4, $a2
    addi $t5, $t0, 20
    loop_copy_nome:
        lb $t7, 0($t4)
        sb $t7, 0($t5)
        beqz $t7, fim_copy_nome
        addi $t4, $t4, 1
        addi $t5, $t5, 1
        j loop_copy_nome
    fim_copy_nome:

    sw $zero, 72($t0) # Saldo

    la $t4, limite_credito_padrao
    lw $t5, 0($t4)
    sw $t5, 76($t0) # Limite

    sw $zero, 80($t0) # Credito Usado

    li $t4, 1
    sw $t4, 84($t0) # Status

    addi $t2, $t2, 1
    sw $t2, 0($t1)

    jr $ra

# --- Funções de Persistência Comentadas ---
# ##### FUNCAO Salvar Dados (COMENTADA) #####
# salvar_dados:
#     addi $sp, $sp, -4
#     sw $ra, 0($sp)
#     li $v0, 4
#     la $a0, msg_em_construcao
#     syscall
#     lw $ra, 0($sp)
#     addi $sp, $sp, 4
#     jr $ra
#
# ##### Helpers de Escrita em Arquivo (COMENTADOS) #####
# escrever_string_arquivo: jr $ra
# escrever_nome_arquivo: jr $ra
# escrever_inteiro_arquivo: jr $ra
#
# ##### FUNCAO Recarregar Dados (COMENTADA) #####
# recarregar_dados:
#  addi $sp, $sp, -12
#  sw $ra, 0($sp)
#  sw $s0, 4($sp)
#  sw $s1, 8($sp)
#  li $v0, 4
#  la $a0, msg_em_construcao
#  syscall
#  lw $s1, 8($sp)
#  lw $s0, 4($sp)
#  lw $ra, 0($sp)
#  addi $sp, $sp, 12
#  jr $ra
#
# ##### FUNCAO Formatar Sistema (COMENTADA) #####
# formatar_sistema:
#  addi $sp, $sp, -4
#  sw $ra, 0($sp)
#  li $v0, 4
#  la $a0, msg_em_construcao
#  syscall
#  lw $ra, 0($sp)
#  addi $sp, $sp, 4
#  jr $ra

##### Helper parse_campo (MANTIDO) #####
# $a0 = dest buffer, $a1 = delimiter (char), $a2 = source buffer
# $v0 = novo ponteiro source
parse_campo:
 move $t0, $a0
 move $t1, $a1
 move $t2, $a2

 loop_parse_campo:
  lb $t3, 0($t2)
  beq $t3, $t1, fim_parse_campo
  beqz $t3, fim_parse_campo_null # Se for \0, não pule

  sb $t3, 0($t0)
  addi $t0, $t0, 1
  addi $t2, $t2, 1
  j loop_parse_campo

 fim_parse_campo:
  sb $zero, 0($t0)
  addi $t2, $t2, 1 # Pula o delimitador
  move $v0, $t2
  jr $ra

 fim_parse_campo_null:
  sb $zero, 0($t0) # Termina a string
  move $v0, $t2    # Retorna o ponteiro no \0
  jr $ra

##### Helper parse_campo_nome (MANTIDO) #####
parse_campo_nome:
 move $t0, $a0
 move $t1, $a1
 move $t2, $a2

 loop_parse_nome:
  lb $t3, 0($t2)
  beq $t3, $t1, fim_parse_nome
  beqz $t3, fim_parse_nome_null

  beq $t3, '_', parse_nome_espaco

  sb $t3, 0($t0)
  j parse_nome_prox

 parse_nome_espaco:
  li $t4, ' '
  sb $t4, 0($t0)

 parse_nome_prox:
  addi $t0, $t0, 1
  addi $t2, $t2, 1
  j loop_parse_nome

 fim_parse_nome:
  sb $zero, 0($t0)
  addi $t2, $t2, 1
  move $v0, $t2
  jr $ra

 fim_parse_nome_null:
  sb $zero, 0($t0)
  move $v0, $t2
  jr $ra

##### Helper atoi (MANTIDO) #####
atoi:
 li $v0, 0
 move $t0, $a0

 atoi_loop:
  lb $t1, 0($t0)
  beqz $t1, atoi_fim

  blt $t1, '0', atoi_fim
  bgt $t1, '9', atoi_fim

  addi $t1, $t1, -48

  mul $v0, $v0, 10
  add $v0, $v0, $t1

  addi $t0, $t0, 1
  j atoi_loop

 atoi_fim:
  jr $ra
  
##### FUNCAO Print Moeda (CORRIGIDA) #####
# $a0 = valor em centavos (Entrada)
print_moeda:
 addi $sp, $sp, -12
 sw $ra, 0($sp)
 sw $s0, 4($sp) # Salva $s0 do chamador
 sw $s1, 8($sp) # Salva $s1 do chamador
 sw $t0, 12($sp) # Salva $t0 do chamador (vamos usar $t0) <-- ADICIONADO ESPAÇO

 move $t0, $a0     # <-- SALVA o valor original de $a0 em $t0 PRIMEIRO!

 # Agora podemos usar $a0 para imprimir "R$ "
 li $v0, 4
 la $a0, msg_str_rs
 syscall

 # Calcula reais e centavos a partir do valor salvo em $t0
 li $t1, 100
 div $t0, $t1      # Divide o valor ORIGINAL ($t0) por 100
 mflo $s0          # Reais (usando $s0 temporariamente)
 mfhi $s1          # Centavos (usando $s1 temporariamente)

 # Print reais
 li $v0, 1
 move $a0, $s0     # Move reais para $a0 para imprimir
 syscall

 # Print ","
 li $v0, 4
 la $a0, msg_str_virgula
 syscall

 # Print 0 se centavos < 10
 blt $s1, 10, print_moeda_zero

 j print_moeda_centavos

 print_moeda_zero:
  li $v0, 4
  la $a0, msg_str_zero
  syscall

 print_moeda_centavos:
 # Print centavos
 li $v0, 1
 move $a0, $s1     # Move centavos para $a0 para imprimir
 syscall

 # Print newline no final
 li $v0, 4
 la $a0, newline
 syscall

 # Restaura os registradores salvos
 lw $t0, 12($sp) # <-- RESTAURA $t0
 lw $s1, 8($sp)
 lw $s0, 4($sp)
 lw $ra, 0($sp)
 addi $sp, $sp, 16 # <-- AJUSTADO TAMANHO DA PILHA (16 bytes agora)
 jr $ra

##### NOVOS Helpers de CLI #####

# strcmp: Compara duas strings
# $a0: str1, $a1: str2
# $v0: 0 se igual, 1 se diferente
strcmp:
    li $v0, 0 # Assume que são iguais

    loop_strcmp:
        lb $t0, 0($a0)
        lb $t1, 0($a1)

        bne $t0, $t1, strcmp_diferente

        beqz $t0, fim_strcmp # Se $t0 é \0 (e são iguais), fim

        addi $a0, $a0, 1
        addi $a1, $a1, 1
        j loop_strcmp

    strcmp_diferente:
        li $v0, 1 # Marca como diferente

    fim_strcmp:
        jr $ra

# strcpy: Copia string
# $a0: dest, $a1: src
strcpy:
    loop_strcpy:
        lb $t0, 0($a1)
        sb $t0, 0($a0)
        beqz $t0, fim_strcpy
        addi $a0, $a0, 1
        addi $a1, $a1, 1
        j loop_strcpy
    fim_strcpy:
        jr $ra