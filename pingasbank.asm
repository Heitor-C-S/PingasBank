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
    buffer_confirmar_opcao: .space 4 #buffer para o S/N (estava com problemas de nao rodar)

    # Constantes globais
    limite_credito_padrao: .word 150000 # R$1500,00
    max_clientes: .word 50

    # Estrutura para extrato de debito
    # Cada transacao ocupara 20 bytes:	
    # Offset 0: Conta (8 bytes) - A conta (com digito verificador) a quem pertence a transacao.
    # Offset 8: Valor (4 bytes) - Em centavos (positivo para entrada, negativo para saida).
    # Offset 12: Tipo (4 bytes) - (ex: 1=Deposito, 2=Saque, 3=Transf. Debito).
    # Offset 16: Data (4 bytes) - AAAAMMDD
    # Offset 20: Hora (4 bytes) - HHMMSS
    
    transacoes_debito: .space 24000      # 1000 transacoes * 24 bytes cada
    num_transacoes_debito: .word 0
    max_transacoes_debito: .word 1000
    
        # # # ESTRUTURA DE TRANSAÇÕES DE CRÉDITO # # #
    # Cada transação ocupará 24 bytes:
    # Offset 0: Conta (8 bytes) - Conta do cliente
    # Offset 8: Valor (4 bytes) - Valor em centavos
    # Offset 12: Tipo (4 bytes) - 4=Pagamento, 5=Uso Crédito, 6=Juros
    # Offset 16: Data (4 bytes) - AAAAMMDD
    # Offset 20: Hora (4 bytes) - HHMMSS
    
    transacoes_credito: .space 1200      # 50 transações * 24 bytes (máx. por cliente)
    num_transacoes_credito: .word 0
    max_transacoes_credito: .word 50

    ##### Mensagens de Crédito #####
    msg_credito_extrato_cabecalho: .asciiz "\n=== EXTRATO DE CRÉDITO da conta "
    msg_extrato_credito_tipo4: .asciiz "\nTipo: PAGAMENTO FATURA"
    msg_extrato_credito_tipo5: .asciiz "\nTipo: USO CRÉDITO (Transferência)"
    msg_extrato_credito_tipo6: .asciiz "\nTipo: JUROS"
    msg_str_credito_limite: .asciiz "\nLimite de Crédito: "
    msg_str_credito_disponivel: .asciiz "\nCrédito Disponível: "
    
    msg_pagamento_sucesso: .asciiz "\nPagamento realizado com sucesso\n"
    msg_valor_maior_que_divida: .asciiz "\nFalha: valor maior que a dívida\n"

    #####  Mensagens do sistema #####
    msg_sucesso_cadastro: .asciiz "\nCliente cadastrado com sucesso. Numero da conta "
    msg_cpf_duplicado: .asciiz "\nJa existe conta neste CPF\n"
    msg_conta_duplicada: .asciiz "\nNumero da conta ja em uso\n"
    msg_limite_clientes: .asciiz "\nLimite maximo de clientes atingido\n"
    msg_comando_invalido: .asciiz "\nComando invalido\n"
    msg_conta_origem_inexistente: .asciiz "\nFalha: conta origem inexistente\n"
    msg_conta_destino_inexistente: .asciiz "\nFalha: conta destino inexistente\n"
    msg_transferencia_sucesso: .asciiz "\nTransferencia realizada com sucesso\n"
    newline: .asciiz "\n"
    hifen: .asciiz "-"
    msg_str_zero: .asciiz "0"
    msg_str_rs: .asciiz "R$" 
    msg_str_virgula: .asciiz ","
    msg_limite_insuficiente: .asciiz "\nFalha: limite insuficente\n"
    
    # Strings conta_formatar
    msg_confirmar_formatacao: .asciiz "\nATENCAO: Todas as transacoes de debito desta conta serao apagadas. Confirmar (S/N)? "
    msg_formatacao_cancelada: .asciiz "\nOperacao cancelada.\n"
    msg_conta_invalida: .asciiz "\nFalha: conta invalida\n"
    msg_formatacao_sucesso: .asciiz "\nConta formatada com sucesso. Todas as transacoes de debito foram removidas.\n"

    # Strings para impressï¿½o em conta_buscar
    msg_str_cpf: .asciiz "\nCPF: "
    msg_str_conta: .asciiz "\nConta: "
    msg_str_nome: .asciiz "\nNome: "
    msg_str_saldo: .asciiz "\nSaldo: "
    msg_str_limite: .asciiz "\nLimite de Credito: "
    msg_str_credito_usado: .asciiz "\nCredito Usado: "

    msg_deposito_sucesso: .asciiz "\nDeposito realizado com sucesso. Saldo atual: "
    msg_saque_sucesso: .asciiz "\nSaque realizado com sucesso\n"
    msg_saldo_insuficiente: .asciiz "\nFalha: saldo insuficente\n"
    msg_cliente_inexistente: .asciiz "\nFalha: cliente inexistente\n"

    msg_extrato_cabecalho: .asciiz "\nExtrato da conta "
    msg_extrato_tipo1: .asciiz "\nTipo: Deposito"
    msg_extrato_tipo2: .asciiz "\nTipo: Saque"
    msg_extrato_tipo3: .asciiz "\nTipo: Transferencia"
    msg_extrato_valor: .asciiz " | Valor: "

    msg_em_construcao: .asciiz "\nEm construcao...\n"

    # Nome do arquivo # ainda nï¿½o implementado, sujeito a mucanï¿½as
    arquivo_nome: .asciiz "pingasbank_data.txt"

    # Delimitadores # (Mantidos mas funï¿½ï¿½es comentadas)
    virgula: .asciiz ","
    ponto_virgula: .asciiz ";"
    abre_parentese: .asciiz "("
    abre_chave: .asciiz "{"
    fecha_chave: .asciiz "}"
    fecha_parentese: .asciiz ")"
    underscore: .asciiz "_"
##### Strings para formatação de data/hora no extrato #####
    msg_data_hora_prefix: .asciiz " | Data/Hora: "
    msg_barra_data: .asciiz "/"
    msg_espaco: .asciiz " "
    msg_dois_pontos: .asciiz ":"


    # Menu Principal - CLI #
    prompt_cli: .asciiz "\nPingasBank> "
    goodbye: .asciiz "\nEncerrando o programa, ate mais!\n"

    # Nomes dos Comandos para Comparaï¿½ï¿½o #
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
    
    
    ##### VARIAVEIS DE DATA E HORA #####
    data_atual: .word 0          # Formato DDMMAAAA (inteiro)
    hora_atual: .word 0          # Formato HHMMSS (inteiro)
    tempo_ultimo_incremento: .word 0  # Tempo em ms desde o início do programa
    
    ##### Mensagens de Data/Hora #####
    msg_data_hora_sucesso: .asciiz "\nData e hora configuradas com sucesso\n"
    msg_data_invalida: .asciiz "\nErro: Data invalida\n"
    msg_hora_invalida: .asciiz "\nErro: Hora invalida\n"
    msg_data_hora_nao_configurada: .asciiz "\nErro: Data e hora nao configuradas\n"
    msg_extrato_data_hora: .asciiz " | Data/Hora: "
    
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

    # Ler o comando inteiro do usuï¿½rio
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

    # -- Inï¿½cio do Bloco de Comparaï¿½ï¿½o de Comandos --

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

    la $a0, buffer_temp
    la $a1, str_conta_format
    jal strcmp
    beqz $v0, handle_conta_format
    
    la $a0, buffer_temp
    la $a1, str_debito_extrato
    jal strcmp
    beqz $v0, handle_debito_extrato
    
    la $a0, buffer_temp
    la $a1, str_transferir_debito
    jal strcmp
    beqz $v0, handle_transferir_debito
    
    la $a0, buffer_temp
    la $a1, str_transferir_credito
    jal strcmp
    beqz $v0, handle_transferir_credito
    
    la $a0, buffer_temp
    la $a1, str_pagar_fatura
    jal strcmp
    beqz $v0, handle_pagar_fatura 
    
    la $a0, buffer_temp
    la $a1, str_sacar
    jal strcmp
    beqz $v0, handle_sacar
    
    la $a0, buffer_temp
    la $a1, str_depositar
    jal strcmp
    beqz $v0, handle_depositar
    
    la $a0, buffer_temp
    la $a1, str_data_hora
    jal strcmp
    beqz $v0, handle_data_hora

    # --- Comandos "Em Construï¿½ï¿½o" --- #



    la $a0, buffer_temp
    la $a1, str_conta_fechar
    jal strcmp
    beqz $v0, handle_em_construcao


    la $a0, buffer_temp
    la $a1, str_credito_extrato
    jal strcmp
    beqz $v0, handle_credito_extrato
    
    



    

    la $a0, buffer_temp
    la $a1, str_alterar_limite
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

    # Se chegou aqui, o comando ï¿½ invï¿½lido
    li $v0, 4
    la $a0, msg_comando_invalido
    syscall
    j cli_loop

# --- Handlers de Comandos ---


# Função para imprimir número com dois dígitos (com zero à esquerda se < 10)
# Entrada: $a0 = número
print_dois_digitos:
    blt $a0, 10, print_dd_zero
    li $v0, 1
    syscall
    jr $ra
    
print_dd_zero:
    move $t0, $a0           # SALVA o valor original
    li $v0, 4
    la $a0, msg_str_zero  # Imprime "0"
    syscall
    li $v0, 1
    move $a0, $t0         # RESTAURA o valor original
    syscall
    jr $ra

# FUNCAO Handler para credito_extrato (cmd_4)
# Comando: credito_extrato-<conta>
# Exibe extrato de crédito com todas transações, limites e datas (R5)
handle_credito_extrato:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)         # ponteiro cliente
    sw $s1, 8($sp)          # contador i
    sw $s2, 4($sp)          # limite transações
    sw $s3, 0($sp)          # ponteiro string conta

    # 1. Parsear CONTA
    la $a0, buffer_temp
    li $a1, '-'
    move $a2, $s1
    jal parse_campo

    # 2. Buscar cliente
    la $a0, buffer_temp
    jal buscar_cliente_por_conta_completa
    beqz $v0, credito_extrato_falha_cliente
    move $s0, $v0

    # 3. Imprimir CABEÇALHO com informações atuais
    li $v0, 4
    la $a0, msg_credito_extrato_cabecalho
    syscall
    la $a0, buffer_temp
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # 4. Imprimir LIMITES DE CRÉDITO
    li $v0, 4
    la $a0, msg_str_credito_limite
    syscall
    lw $a0, 76($s0)
    jal print_moeda

    li $v0, 4
    la $a0, msg_str_credito_usado
    syscall
    lw $a0, 80($s0)
    jal print_moeda

    li $v0, 4
    la $a0, msg_str_credito_disponivel
    syscall
    lw $t0, 76($s0)
    lw $t1, 80($s0)
    sub $a0, $t0, $t1
    jal print_moeda

    li $v0, 4
    la $a0, newline
    syscall

    # 5. Preparar loop de transações
    la $s3, 12($s0)         # ponteiro para string da conta cliente
    li $s1, 0               # i = 0
    la $t0, num_transacoes_credito
    lw $s2, 0($t0)          # limite = num_transacoes_credito

credito_extrato_loop:
    bge $s1, $s2, credito_extrato_fim

    # Calcular endereço da transação[i]
    li $t0, 24
    mul $t1, $s1, $t0
    la $t2, transacoes_credito
    add $t2, $t2, $t1

    # Verificar se transação pertence a esta conta
    move $a0, $s3
    move $a1, $t2
    jal strcmp
    bnez $v0, credito_extrato_proxima

    # Imprimir TIPO da transação
    lw $t3, 12($t2)         # tipo
    beq $t3, 4, credito_tipo4
    beq $t3, 5, credito_tipo5
    beq $t3, 6, credito_tipo6
    j credito_imprimir_valor

credito_tipo4:
    li $v0, 4
    la $a0, msg_extrato_credito_tipo4
    syscall
    j credito_imprimir_valor

credito_tipo5:
    li $v0, 4
    la $a0, msg_extrato_credito_tipo5
    syscall
    j credito_imprimir_valor

credito_tipo6:
    li $v0, 4
    la $a0, msg_extrato_credito_tipo6
    syscall

credito_imprimir_valor:
    # Imprimir VALOR
    li $v0, 4
    la $a0, msg_extrato_valor
    syscall
    lw $a0, 8($t2)          # valor
    jal print_moeda

    # Imprimir DATA/HORA formatada
    li $v0, 4
    la $a0, msg_data_hora_prefix
    syscall

    lw $t5, 16($t2)         # data AAAAMMDD
    lw $t6, 20($t2)         # hora HHMMSS

    # === FORMATAR DATA: DD/MM/AAAA ===
    li $t7, 1000000
    div $t5, $t7
    mflo $t4                # Dia
    mfhi $t8                # Resto MMAAAA

    li $t7, 10000
    div $t8, $t7
    mflo $t3                # Mes
    mfhi $t9                # Ano

    li $v0, 1
    move $a0, $t4
    syscall
    li $v0, 4
    la $a0, msg_barra_data
    syscall
    li $v0, 1
    move $a0, $t3
    syscall
    li $v0, 4
    la $a0, msg_barra_data
    syscall
    li $v0, 1
    move $a0, $t9
    syscall

    # Espaço e hora
    li $v0, 4
    la $a0, msg_espaco
    syscall

     # Extrair HH (hora)
    li $t7, 10000
    div $t6, $t7            # Divide HHMMSS por 10000
    mflo $t6                # Hora
    mfhi $t7                # Resto = MMSS

    # Extrair MM (minutos) e SS (segundos)
    li $t8, 100
    div $t7, $t8            # Divide MMSS por 100
    mflo $t8                # Minutos
    mfhi $t9                # Segundos

    # Imprimir formato HH:MM:SS com zeros à esquerda
    move $a0, $t6           # Hora
    jal print_dois_digitos

    li $v0, 4
    la $a0, msg_dois_pontos # ":"
    syscall

    move $a0, $t8           # Minutos
    jal print_dois_digitos

    li $v0, 4
    la $a0, msg_dois_pontos # ":"
    syscall

    move $a0, $t9           # Segundos
    jal print_dois_digitos

    li $v0, 4
    la $a0, newline
    syscall

credito_extrato_proxima:
    addi $s1, $s1, 1
    j credito_extrato_loop

credito_extrato_falha_cliente:
    li $v0, 4
    la $a0, msg_cliente_inexistente
    syscall

credito_extrato_fim:
    # Nova linha final
    li $v0, 4
    la $a0, newline
    syscall

    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    j cli_loop

# FUNCAO Handler para pagar_fatura (cmd_7)
# Comando: pagar_fatura-<conta>-<valor>-<metodo>
# <metodo>: S = saldo, E = externo
# Registra transação de crédito (tipo 4) com data/hora
handle_pagar_fatura:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)         # ponteiro cliente
    sw $s1, 20($sp)         # valor
    sw $s2, 16($sp)         # metodo (1=S, 0=E)
    sw $s3, 12($sp)         # data
    sw $s4, 8($sp)          # hora
    sw $t0, 4($sp)          # temporário
    sw $t1, 0($sp)          # temporário

    # 1. Parsear CONTA
    la $a0, buffer_temp
    li $a1, '-'
    move $a2, $s1
    jal parse_campo
    move $s1, $v0

    # 2. Parsear VALOR
    la $a0, buffer_args
    li $a1, '-'
    move $a2, $s1
    jal parse_campo
    move $s1, $v0

    # 3. Parsear MÉTODO (S ou E)
    la $a0, buffer_conta_completa
    li $a1, '-'
    move $a2, $s1
    jal parse_campo

    # 4. Converter valor
    la $a0, buffer_args
    jal atoi
    move $s1, $v0

    # 5. Verificar método
    la $t0, buffer_conta_completa
    lb $t0, 0($t0)
    li $t1, 'S'
    beq $t0, $t1, metodo_saldo_ok
    li $t1, 's'
    beq $t0, $t1, metodo_saldo_ok
    li $t1, 'E'
    beq $t0, $t1, metodo_externo_ok
    li $t1, 'e'
    beq $t0, $t1, metodo_externo_ok
    
    # Método inválido
    li $v0, 4
    la $a0, msg_comando_invalido
    syscall
    j pagar_fatura_fim

metodo_saldo_ok:
    li $s2, 1
    j buscar_cliente_fatura
metodo_externo_ok:
    li $s2, 0

buscar_cliente_fatura:
    # 6. Buscar cliente
    la $a0, buffer_temp
    jal buscar_cliente_por_conta_completa
    beqz $v0, pagar_falha_cliente
    move $s0, $v0

    # 7. Verificar se valor <= crédito usado
    lw $t0, 80($s0)         # Crédito usado
    blt $t0, $s1, pagar_falha_valor_maior_que_divida

    # 8. Se método=S, verificar saldo suficiente
    beqz $s2, pagar_sem_verificar_saldo
    lw $t0, 72($s0)         # Saldo
    blt $t0, $s1, pagar_falha_saldo_insuficiente

    # 9. Método S: Reduzir saldo
    sub $t0, $t0, $s1
    sw $t0, 72($s0)

pagar_sem_verificar_saldo:
    # 10. Reduzir crédito usado
    lw $t0, 80($s0)
    sub $t0, $t0, $s1
    sw $t0, 80($s0)

    # 11. OBTER DATA/HORA
    jal obter_data_hora_atual
    move $s3, $v0
    move $s4, $v1

    # 12. Registrar TRANSAÇÃO DE CRÉDITO (tipo 4 = Pagamento)
    la $a0, 12($s0)         # Conta
    sub $a1, $zero, $s1     # Valor negativo (reduz dívida)
    li $a2, 4               # Tipo 4: Pagamento Fatura
    move $a3, $s3           # Data
    
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    jal registrar_transacao_credito
    addi $sp, $sp, 4

    # 13. Sucesso
    li $v0, 4
    la $a0, msg_pagamento_sucesso
    syscall
    j pagar_fatura_fim

pagar_falha_cliente:
    li $v0, 4
    la $a0, msg_cliente_inexistente
    syscall
    j pagar_fatura_fim

pagar_falha_valor_maior_que_divida:
    li $v0, 4
    la $a0, msg_valor_maior_que_divida
    syscall
    j pagar_fatura_fim

pagar_falha_saldo_insuficiente:
    li $v0, 4
    la $a0, msg_saldo_insuficiente
    syscall

pagar_fatura_fim:
    lw $t1, 0($sp)
    lw $t0, 4($sp)
    lw $s4, 8($sp)
    lw $s3, 12($sp)
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32
    j cli_loop

# FUNCAO Handler para transferir_credito
# Comando: transferir_credito-<conta_destino>-<conta_origem>-<valor>
# Transfere crédito do limite da origem para o saldo da destino
handle_transferir_credito:
    addi $sp, $sp, -24
    sw $ra, 20($sp)         
    sw $s0, 16($sp)         # $s0 = ponteiro cliente destino
    sw $s1, 12($sp)         # $s1 = ponteiro cliente origem
    sw $s2, 8($sp)          # $s2 = valor da transferência
    sw $s3, 4($sp)          # $s3 = data
    sw $s4, 0($sp)          # $s4 = hora

    # 1. Parsear CONTA_DESTINO
    la $a0, buffer_temp
    li $a1, '-'
    move $a2, $s1
    jal parse_campo
    move $s1, $v0

    # 2. Parsear CONTA_ORIGEM
    la $a0, buffer_args
    li $a1, '-'
    move $a2, $s1
    jal parse_campo
    move $s1, $v0

    # 3. Parsear VALOR
    la $a0, buffer_conta_completa
    li $a1, '-'
    move $a2, $s1
    jal parse_campo

    # 4. Converter VALOR string para inteiro
    la $a0, buffer_conta_completa
    jal atoi
    move $s2, $v0

    # 5. Buscar CONTA_DESTINO
    la $a0, buffer_temp
    jal buscar_cliente_por_conta_completa
    beqz $v0, transferir_cred_falha_destino
    move $s0, $v0

    # 6. Buscar CONTA_ORIGEM
    la $a0, buffer_args
    jal buscar_cliente_por_conta_completa
    beqz $v0, transferir_cred_falha_origem
    move $s1, $v0

    # 7. Verificar crédito disponível na conta origem
    lw $t0, 76($s1)         # Limite de crédito
    lw $t1, 80($s1)         # Crédito usado
    sub $t2, $t0, $t1       # Crédito disponível
    blt $t2, $s2, transferir_cred_falha_limite

    # 8. Atualizar SALDO da conta destino
    lw $t3, 72($s0)
    add $t3, $t3, $s2
    sw $t3, 72($s0)

    # 9. Atualizar CREDITO USADO da conta origem
    add $t1, $t1, $s2
    sw $t1, 80($s1)

    # 10. Obter data e hora atuais
    jal obter_data_hora_atual
    move $s3, $v0           # Data
    move $s4, $v1           # Hora

    # 11. Registrar transação na conta DESTINO (Tipo 1 = Depósito no débito)
    la $a0, 12($s0)
    move $a1, $s2           # Valor positivo
    li $a2, 1               # Tipo 1: Depósito
    move $a3, $s3
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    jal registrar_transacao_debito
    addi $sp, $sp, 4

    # 12. Registrar transação na conta ORIGEM (Tipo 5 = Uso Crédito no crédito_extrato)
    la $a0, 12($s1)
    move $a1, $s2           # Valor positivo (uso de crédito)
    li $a2, 5               # Tipo 5: Uso Crédito (Transferência)
    move $a3, $s3
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    jal registrar_transacao_credito  # <-- MUDANÇA AQUI: usar registrar_transacao_credito
    addi $sp, $sp, 4

    # 13. Mensagem de sucesso
    li $v0, 4
    la $a0, msg_transferencia_sucesso
    syscall

    j transferir_cred_fim

transferir_cred_falha_origem:
    li $v0, 4
    la $a0, msg_conta_origem_inexistente
    syscall
    j transferir_cred_fim

transferir_cred_falha_destino:
    li $v0, 4
    la $a0, msg_conta_destino_inexistente
    syscall
    j transferir_cred_fim

transferir_cred_falha_limite:
    li $v0, 4
    la $a0, msg_limite_insuficiente
    syscall

transferir_cred_fim:
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    j cli_loop
    
# FUNCAO registrar_transacao_credito
# Entrada: $a0 = conta, $a1 = valor, $a2 = tipo, $a3 = data
#            pilha[0] = hora (argumento extra)
# Registra transação de crédito com sobrescrita circular (R3)
registrar_transacao_credito:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $t9, 0($sp)

    move $s0, $a0           # Conta
    move $s1, $a1           # Valor
    move $s2, $a2           # Tipo
    move $s3, $a3           # Data
    lw $s4, 28($sp)         # Hora da pilha

    # Verifica limite (máx. 50 transações)
    la $s5, num_transacoes_credito
    lw $t1, 0($s5)
    la $t2, max_transacoes_credito
    lw $t2, 0($t2)
    
    # Se atingiu limite, sobrescreve transações antigas (circular buffer)
    blt $t1, $t2, registrar_credito_normal
    li $t1, 0               # Reseta para posição 0 (sobrescreve mais antiga)

registrar_credito_normal:
    # Calcula offset (24 bytes por transação)
    li $t3, 24
    mul $t4, $t1, $t3
    la $t5, transacoes_credito
    add $t5, $t5, $t4

    # Salva dados da transação
    move $a0, $t5
    move $a1, $s0
    jal strcpy              # Copia conta (8 bytes)
    sw $s1, 8($t5)          # Valor
    sw $s2, 12($t5)         # Tipo
    sw $s3, 16($t5)         # Data
    sw $s4, 20($t5)         # Hora

    # Incrementa contador circularmente
    addi $t1, $t1, 1
    blt $t1, $t2, salvar_contador_credito
    li $t1, 0               # Volta ao início do buffer

salvar_contador_credito:
    sw $t1, 0($s5)

fim_registrar_transacao_credito:
    lw $t9, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra

##### FUNCAO Handler para data_hora #####
# Comando: data_hora-<option1>-<option2>
# <option1> = DDMMAAAA, <option2> = HHMMSS
handle_data_hora:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    # 1. Parsear DATA (formato DDMMAAAA)
    la $a0, buffer_temp     # Destino para string da data
    li $a1, '-'             # Delimitador
    move $a2, $s1           # Argumentos do comando
    jal parse_campo
    move $s1, $v0           # Atualiza ponteiro para próximo argumento

    # 2. Parsear HORA (formato HHMMSS)
    la $a0, buffer_args     # Destino para string da hora
    li $a1, '-'             # Delimitador
    move $a2, $s1           # Resto dos argumentos
    jal parse_campo

    # 3. Converter strings para inteiros
	la $a0, buffer_temp
	jal atoi
	move $s0, $v0           # $s0 = data inteira

	la $a0, buffer_args
	jal atoi
	move $s1, $v0           # $s1 = hora inteira

	# 4. Validar data
	move $a0, $s0
	jal validar_data
	beqz $v0, data_hora_invalida

	# 5. Validar hora
	move $a0, $s1
	jal validar_hora
	beqz $v0, hora_hora_invalida

# 6. Salvar data e hora
la $t0, data_atual
sw $s0, 0($t0)
la $t0, hora_atual
sw $s1, 0($t0)          # SALVA A HORA CONFIGURADA

# 7. Inicializar tempo_ultimo_incremento com syscall 30
li $v0, 30              # Syscall 30: get time in milliseconds
syscall
la $t0, tempo_ultimo_incremento
sw $a0, 0($t0)          # $a0 contém os milissegundos atuais

    # Mensagem de sucesso
    li $v0, 4
    la $a0, msg_data_hora_sucesso
    syscall
    j data_hora_fim

data_hora_invalida:
    li $v0, 4
    la $a0, msg_data_invalida
    syscall
    j data_hora_fim

hora_hora_invalida:
    li $v0, 4
    la $a0, msg_hora_invalida
    syscall

data_hora_fim:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    j cli_loop
    
##### FUNCAO Validar Data #####
# Entrada: $a0 = data como inteiro (DDMMAAAA)
# Saída: $v0 = 1 se válida, 0 se inválida
validar_data:
    li $t0, 1000000
    div $a0, $t0
    mflo $t0                # DD
    mfhi $t1                # MMAAAA
    
    li $t2, 10000
    div $t1, $t2
    mflo $t3                # MM
    mfhi $t4                # AAAA

    # Validar ano (1950-2100)
    blt $t4, 1950, validar_data_falso
    bgt $t4, 2100, validar_data_falso

    # Validar mês (1-12)
    blt $t3, 1, validar_data_falso
    bgt $t3, 12, validar_data_falso

    # Validar dias
    li $t5, 31              # Máximo dias padrão
    
    # Fevereiro
    li $t6, 2
    beq $t3, $t6, validar_fevereiro
    
    # Abril, Junho, Setembro, Novembro (30 dias)
    li $t6, 4
    beq $t3, $t6, validar_data_30dias
    li $t6, 6
    beq $t3, $t6, validar_data_30dias
    li $t6, 9
    beq $t3, $t6, validar_data_30dias
    li $t6, 11
    beq $t3, $t6, validar_data_30dias
    
    j validar_data_dia

validar_fevereiro:
    # Verificar ano bissexto
    li $t7, 4
    div $t4, $t7
    mfhi $t8
    bnez $t8, validar_fevereiro_nao_bissexto
    li $t5, 29              # Ano bissexto
    j validar_data_dia

validar_fevereiro_nao_bissexto:
    li $t5, 28

validar_data_30dias:
    li $t5, 30

validar_data_dia:
    blt $t0, 1, validar_data_falso
    bgt $t0, $t5, validar_data_falso

validar_data_verdadeiro:
    li $v0, 1
    jr $ra

validar_data_falso:
    li $v0, 0
    jr $ra

##### FUNCAO Validar Hora #####
# Entrada: $a0 = hora como inteiro (HHMMSS)
# Saída: $v0 = 1 se válida, 0 se inválida
validar_hora:
    li $t0, 10000
    div $a0, $t0
    mflo $t1                # HH
    mfhi $t2                # MMSS
    
    li $t3, 100
    div $t2, $t3
    mflo $t4                # MM
    mfhi $t5                # SS

    blt $t1, 0, validar_hora_falso
    bgt $t1, 23, validar_hora_falso
    blt $t4, 0, validar_hora_falso
    bgt $t4, 59, validar_hora_falso
    blt $t5, 0, validar_hora_falso
    bgt $t5, 59, validar_hora_falso

    li $v0, 1
    jr $ra

validar_hora_falso:
    li $v0, 0
    jr $ra

##### FUNCAO Obter Data e Hora Atual #####
# Usa syscall 30 para incrementar automaticamente
# Saída: $v0 = data, $v1 = hora
obter_data_hora_atual:
    addi $sp, $sp, -8
    sw $s0, 4($sp)
    sw $ra, 0($sp)

    # Carregar tempo_ultimo_incremento
    la $t0, tempo_ultimo_incremento
    lw $s0, 0($t0)

    # Se tempo_ultimo_incremento for 0, data/hora não foi configurada
    beqz $s0, data_hora_nao_configurada

    # Obter tempo atual
    li $v0, 30
    syscall
    move $t1, $a0

    # Calcular diferença
    sub $t2, $t1, $s0
    li $t3, 1000            # 1000ms = 1 segundo
    blt $t2, $t3, obter_data_hora_fim  # Se < 1s, não incrementa

    # Atualizar tempo_ultimo_incremento
    sw $t1, 0($t0)

    # Incrementar segundos
    la $t0, hora_atual
    lw $t4, 0($t0)
    
    # Extrair componentes
    li $t5, 100
    div $t4, $t5
    mfhi $t6                # SS
    mflo $t7                # HHMM
    
    div $t7, $t5
    mfhi $t8                # MM
    mflo $t9                # HH

    addi $t6, $t6, 1        # SS + 1

    # Verificar overflow de segundos
    li $t5, 60
    blt $t6, $t5, atualizar_hora
    li $t6, 0               # SS = 0
    addi $t8, $t8, 1        # MM + 1

    # Verificar overflow de minutos
    blt $t8, $t5, atualizar_hora
    li $t8, 0               # MM = 0
    addi $t9, $t9, 1        # HH + 1

    # Verificar overflow de horas
    li $t5, 24
    blt $t9, $t5, atualizar_hora
    li $t9, 0               # HH = 0
    
    # Incrementar dia (simplificado - não verifica meses)
    # Para fins acadêmicos, vamos apenas incrementar o dia
    # (uma implementação completa seria muito extensa)
    la $t0, data_atual
    lw $t4, 0($t0)
    addi $t4, $t4, 1        # Incrementa dia (pode gerar data inválida)
    sw $t4, 0($t0)

atualizar_hora:
    # Reconstruir hora no formato HHMMSS
    li $t5, 100
    mul $t4, $t9, $t5       # HH * 100
    add $t4, $t4, $t8       # HHMM
    mul $t4, $t4, $t5       # HHMM * 100
    add $t4, $t4, $t6       # HHMMSS
    
    la $t0, hora_atual
    sw $t4, 0($t0)

obter_data_hora_fim:
    # Retornar data e hora
    la $t0, data_atual
    lw $v0, 0($t0)
    la $t0, hora_atual
    lw $v1, 0($t0)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

data_hora_nao_configurada:
    li $v0, 0
    li $v1, 0
    j obter_data_hora_fim



handle_conta_format:
    addi $sp, $sp, -16          # Aloca espaço na pilha
    sw $ra, 12($sp)
    sw $s0, 8($sp)              # Ponteiro do cliente
    sw $s1, 4($sp)              # Contador de transações
    sw $s2, 0($sp)              # Endereço de escrita

    # 1. Parsear conta (único argumento)
    la $a0, buffer_temp
    li $a1, '-'
    move $a2, $s1               # $s1 contém argumentos do main
    jal parse_campo
    move $s1, $v0               # Atualiza ponteiro (não usado mais)

    # 2. Buscar cliente pela conta
    la $a0, buffer_temp
    jal buscar_cliente_por_conta_completa
    beqz $v0, format_conta_invalida  # Conta não existe
    
    move $s0, $v0               # Salva ponteiro do cliente

    # 3. Solicitar confirmação
    li $v0, 4
    la $a0, msg_confirmar_formatacao
    syscall

    # Ler resposta do usuário
    li $v0, 8
    la $a0, buffer_confirmar_opcao
    li $a1, 4                   # Máx 3 chars + \0
    syscall

    # Limpar newline da resposta
    la $a0, buffer_confirmar_opcao
    jal limpar_newline_comando

    # Verificar se confirmou (S ou s)
    la $t0, buffer_confirmar_opcao
    lb $t0, 0($t0)
    beq $t0, 'S', format_confirmado
    beq $t0, 's', format_confirmado
    
    # Não confirmado
    li $v0, 4
    la $a0, msg_formatacao_cancelada
    j format_fim

format_confirmado:
    # 4. Formatar transações de débito
    la $a0, 12($s0)             # Ponteiro para string da conta (offset 12)
    jal limpar_transacoes_debito_cliente

    # 5. Mensagem de sucesso
    li $v0, 4
    la $a0, msg_formatacao_sucesso
    syscall
    j format_fim

format_conta_invalida:
    li $v0, 4
    la $a0, msg_conta_invalida
    syscall

format_fim:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    j cli_loop

handle_conta_cadastrar:
    # $s1 jï¿½ contï¿½m o ponteiro para os argumentos

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

    # 3. Parsear Nome (arg3 - ï¿½ o resto da string)
    la $a0, buffer_nome
    move $a1, $s1
    jal strcpy # Copia o resto da string

    # 4. Executar a lï¿½gica de cadastro
    jal logica_cadastro_cliente

    j cli_loop

##### NOVA FUNCAO Handler para conta_buscar #####
handle_conta_buscar:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp) # Salvar $s0 (ponteiro do cliente)

    # $s1 jï¿½ contï¿½m o ponteiro para os argumentos (a conta XXXXXX-X)

    # 1. Copiar o argumento (conta) para um buffer temporï¿½rio
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
        lb $a0, 0($t0) # Exibe o 7ï¿½ caractere (DV)
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
    jal print_moeda # print_moeda jï¿½ imprime newline no final

    # Limite de Crï¿½dito
    li $v0, 4
    la $a0, msg_str_limite
    syscall
    lw $a0, 76($s0) # Offset 76 = Limite
    jal print_moeda # print_moeda jï¿½ imprime newline no final

    # Crï¿½dito Usado
    li $v0, 4
    la $a0, msg_str_credito_usado
    syscall
    lw $a0, 80($s0) # Offset 80 = Credito Usado
    jal print_moeda # print_moeda jï¿½ imprime newline no final

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
    j cli_loop 

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
    
# FUNCAO: limpar_transacoes_debito_cliente
# Entrada: $a0 = ponteiro para string da conta (7 chars + \0)
# Remove todas as transacoes de debito desta conta do array
limpar_transacoes_debito_cliente:
    addi $sp, $sp, -24          # Aloca 24 bytes na pilha
    sw $ra, 20($sp)             # Salva $ra
    sw $s0, 16($sp)             # Salva $s0
    sw $s1, 12($sp)             # Salva $s1
    sw $s2, 8($sp)              # Salva $s2
    sw $s3, 4($sp)              # Salva $s3
    sw $s4, 0($sp)              # Salva $s4

    move $s0, $a0               # $s0 = ponteiro para string da conta
    li $s1, 0                   # $s1 = índice leitor (i)
    li $s2, 0                   # $s2 = índice escritor
    li $s3, 0                   # $s3 = contador de transações removidas
    
    # Carregar endereço do contador em $s4 (registrador salvo)
    la $s4, num_transacoes_debito  # $s4 = endereço do contador
    lw $t4, 0($s4)              # $t4 = número total de transações

format_transacao_loop:
    bge $s1, $t4, format_transacao_fim

    # Calcular offset da transação atual
    li $t1, 20
    mul $t5, $s1, $t1
    la $t6, transacoes_debito
    add $t6, $t6, $t5           # Endereço da transação[i]

    # Comparar conta da transação com conta do cliente
    move $a0, $s0               # Conta do cliente
    move $a1, $t6               # Conta da transação
    jal strcmp

    # Se igual (v0=0), pular e contar remoção
    beqz $v0, format_conta_encontrada

    # Se diferente, copiar para posição do escritor
    mul $t5, $s2, $t1           # Offset do escritor
    la $t7, transacoes_debito
    add $t7, $t7, $t5           # Endereço destino

    # Copiar 20 bytes (bloco de transação)
    li $t8, 0
format_copiar_bloco:
    lb $t9, 0($t6)
    sb $t9, 0($t7)
    addi $t6, $t6, 1
    addi $t7, $t7, 1
    addi $t8, $t8, 1
    blt $t8, 20, format_copiar_bloco

    addi $s2, $s2, 1            # Incrementa escritor
    j format_proxima_transacao

format_conta_encontrada:
    addi $s3, $s3, 1            # Incrementa contador de removidos

format_proxima_transacao:
    addi $s1, $s1, 1            # Incrementa leitor
    j format_transacao_loop

format_transacao_fim:
    # Atualizar contador total
    sub $t4, $t4, $s3
    sw $t4, 0($s4)              # Salva usando $s4 que guarda o endereço

    lw $s4, 0($sp)              # Restaura $s4
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24           # Libera espaço na pilha
    jr $ra
    
# FUNCAO registrar_transacao_debito (SEM $a4)
# Entrada: $a0 = conta, $a1 = valor, $a2 = tipo, $a3 = data
#            pilha[0] = hora (argumento extra)
registrar_transacao_debito:
    addi $sp, $sp, -28      # Aloca 28 bytes
    sw $ra, 24($sp)         
    sw $s0, 20($sp)         
    sw $s1, 16($sp)        
    sw $s2, 12($sp)
    sw $s3, 8($sp)          # Data
    sw $s4, 4($sp)          # Hora
    sw $t9, 0($sp)          # Preserva $t9

    move $s0, $a0           # Conta
    move $s1, $a1           # Valor
    move $s2, $a2           # Tipo
    move $s3, $a3           # Data
    lw $s4, 28($sp)         # Carrega HORA da pilha (offset 0 do frame anterior)

    # Verifica limite
    la $s5, num_transacoes_debito
    lw $t1, 0($s5)
    la $t2, max_transacoes_debito
    lw $t2, 0($t2)
    bge $t1, $t2, fim_registrar_transacao

    # Calcula offset (24 bytes por transacao)
    li $t3, 24
    mul $t4, $t1, $t3
    la $t5, transacoes_debito
    add $t5, $t5, $t4

    # Salva dados
    move $a0, $t5
    move $a1, $s0
    jal strcpy              # Copia conta (8 bytes)
    sw $s1, 8($t5)          # Valor
    sw $s2, 12($t5)         # Tipo
    sw $s3, 16($t5)         # Data
    sw $s4, 20($t5)         # Hora

    # Incrementa contador
    addi $t1, $t1, 1
    sw $t1, 0($s5)

fim_registrar_transacao:
    lw $t9, 0($sp)
    lw $s4, 4($sp)
    lw $s3, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra
handle_depositar:
    # Aloca 16 bytes na pilha (4 registradores x 4 bytes)
    addi $sp, $sp, -20
    
    # Salva registradores que serão usados
    sw $ra, 16($sp)         # Salva endereço de retorno (offset 12)
    sw $s0, 12($sp)          # Salva $s0 - será usado para ponteiro do cliente (offset 8)
    sw $s1, 8($sp)          # Salva $s1 - será usado para valor do depósito (offset 4)
    sw $s2, 4($sp)          # Salva $s2 - será usado para ponteiro dos argumentos (offset 0)
    sw $s3, 0($sp)	    # $s3 - timestamp

    # CRÍTICO: Preserva o ponteiro dos argumentos vindos do main
    # $s1 chega aqui apontando para "CONTA-VALOR" (ex: "123456X-50000")
    move $s2, $s1           # Copia para $s2 antes de qualquer operação

    # 1. Extrair a CONTA
    la $a0, buffer_temp     # Destino
    li $a1, '-'             # Delimitador
    move $a2, $s2           # Fonte (usando $s2 agora)
    jal parse_campo         
    move $s2, $v0           # Atualiza $s2 com ponteiro para "VALOR"

    # 2. Extrair o VALOR
    la $a0, buffer_args     # Destino
    li $a1, '-'             # Delimitador
    move $a2, $s2           # Fonte (usando $s2)
    jal parse_campo         

    # 3. Buscar o cliente
    la $a0, buffer_temp     
    jal buscar_cliente_por_conta_completa

    # 4. Verificar se encontrou
    beqz $v0, depositar_falha_cliente
    move $s0, $v0           # Salva ponteiro do cliente

    # 5. Converter VALOR para inteiro
    la $a0, buffer_args     
    jal atoi                
    move $s1, $v0           # Salva valor em $s1

    # 6. Atualizar Saldo
    lw $t0, 72($s0)         
    add $t0, $t0, $s1       
    sw $t0, 72($s0)         

    # NOVO: Obter data e hora atuais
    jal obter_data_hora_atual
    move $s3, $v0           # Data
    move $s4, $v1           # Hora

    # Empilha HORA antes da chamada
    addi $sp, $sp, -4
    sw $s4, 0($sp)

    # Chama funcao com 4 argumentos normais + 1 na pilha
    la $a0, 12($s0)         # Conta
    move $a1, $s1           # Valor
    li $a2, 1               # Tipo
    move $a3, $s3           # Data
    jal registrar_transacao_debito
    
    # Desempilha
    addi $sp, $sp, 4

    # 8. Imprimir Sucesso
    li $v0, 4               
    la $a0, msg_deposito_sucesso 
    syscall                

    # 9. Imprimir Saldo
    lw $a0, 72($s0)         
    jal print_moeda         

    j depositar_fim         

depositar_falha_cliente:
    li $v0, 4            
    la $a0, msg_cliente_inexistente 
    syscall                

depositar_fim: 
    lw $s3, 0($sp)
    lw $s2, 4($sp)          # Restaura $s2
    lw $s1, 8($sp)          
    lw $s0, 12($sp)          
    lw $ra, 16($sp)         
    addi $sp, $sp, 20       # Ajusta para 16 bytes

    j cli_loop
    
handle_sacar:
    # Aloca 16 bytes na pilha (4 registradores x 4 bytes)
    addi $sp, $sp, -20
    
    # Salva registradores que serão usados
    sw $ra, 16($sp)         # Salva endereço de retorno (offset 12)
    sw $s0, 12($sp)          # Salva $s0 - será usado para ponteiro do cliente
    sw $s1, 8($sp)          # Salva $s1 - será usado para valor do saque
    sw $s2, 4($sp)          # Salva $s2 - será usado para ponteiro dos argumentos
    sw $s3, 0($sp)          # Salva $s3 - timestamp
    
    # $s1 chega aqui apontando para "CONTA-VALOR" (ex: "123456X-20000")
    move $s2, $s1           # Copia para $s2 antes de qualquer operação

    # 1. PARSEAR A CONTA (primeiro argumento antes do '-')
    # Objetivo: Extrair "123456X" de "123456X-20000"
    la $a0, buffer_temp     # $a0 (destino) = onde será salva a conta extraída
    li $a1, '-'             # $a1 (delimitador) = caractere que separa conta do valor
    move $a2, $s2           # $a2 (fonte) = ponteiro para string completa
    jal parse_campo         # Chama função que extrai até o delimitador
    move $s2, $v0           # Atualiza $s2 para apontar para o valor após o '-'
    
    # 2. PARSEAR O VALOR (segundo argumento)
    # Objetivo: Extrair "20000" do resto da string
    la $a0, buffer_args     # $a0 (destino) = onde será salvo o valor extraído
    li $a1, '-'             # $a1 (delimitador) = não importa, é o último campo
    move $a2, $s2           # $a2 (fonte) = ponteiro para o valor
    jal parse_campo         # Extrai o valor como string
    # Agora: buffer_temp tem "123456X\0" e buffer_args tem "20000\0"
    
    # 3. BUSCAR O CLIENTE NO SISTEMA
    # Objetivo: Localizar o registro do cliente pela conta
    la $a0, buffer_temp     # $a0 = passa a conta como argumento
    jal buscar_cliente_por_conta_completa # Busca no array 'clientes'
    # Retorna em $v0: ponteiro para o cliente, ou 0 se não existe
    
    # 4. VERIFICAR SE CLIENTE FOI ENCONTRADO
    beqz $v0, sacar_falha_cliente # Se $v0 == 0, pula para mensagem de erro
    
    # Cliente existe, continua o processamento
    move $s0, $v0           # Salva ponteiro do cliente em $s0
    
    # 5. CONVERTER STRING DO VALOR PARA INTEIRO
    # Objetivo: Transformar "20000" (string) em 20000 (número)
    la $a0, buffer_args     # $a0 = endereço da string do valor
    jal atoi                # Chama função de conversão ASCII para inteiro
    move $s1, $v0           # Salva valor numérico em $s1
    
    # 6. VERIFICAR SALDO SUFICIENTE
    # Estrutura do cliente: Saldo está no offset 72
    lw $t0, 72($s0)         # Carrega saldo atual do cliente
    blt $t0, $s1, sacar_falha_saldo_insuficiente # Se saldo < valor, pula para erro
    # Se chegou aqui, saldo é suficiente

    # 7. ATUALIZAR SALDO DO CLIENTE
    sub $t0, $t0, $s1       # Subtrai valor do saque: saldo_novo = saldo_atual - valor
    sw $t0, 72($s0)         # Salva novo saldo de volta na memória

     # NOVO: Obter data e hora atuais
    jal obter_data_hora_atual
    move $s3, $v0
    move $s4, $v1

    # Empilha HORA
    addi $sp, $sp, -4
    sw $s4, 0($sp)

    la $a0, 12($s0)
    sub $a1, $zero, $s1
    li $a2, 2
    move $a3, $s3
    jal registrar_transacao_debito
    
    addi $sp, $sp, 4

    # 9. IMPRIMIR MENSAGEM DE SUCESSO
    li $v0, 4               # Syscall 4 = print string
    la $a0, msg_saque_sucesso # Carrega "Saque realizado com sucesso\n"
    syscall                 # Imprime mensagem

    j sacar_fim             # Pula para o fim (evita executar código de erro)

# --- TRATAMENTO DE ERRO: CLIENTE NÃO ENCONTRADO ---
sacar_falha_cliente:
    li $v0, 4               # Syscall 4 = print string
    la $a0, msg_cliente_inexistente # Carrega "Falha: cliente inexistente\n"
    syscall                 # Imprime mensagem de erro
    j sacar_fim             # Vai para finalização

# --- TRATAMENTO DE ERRO: SALDO INSUFICIENTE ---
sacar_falha_saldo_insuficiente:
    li $v0, 4               # Syscall 4 = print string
    la $a0, msg_saldo_insuficiente # Carrega "Falha: saldo insuficente\n"
    syscall                 # Imprime mensagem de erro
    # Fluxo continua para sacar_fim

# --- FINALIZAÇÃO E LIMPEZA DA FUNÇÃO ---
sacar_fim:
    # Restaura valores originais dos registradores (ordem inversa do salvamento)
    lw $s3, 0($sp)          # Restaura $s3 da pilha
    lw $s2, 4($sp)          # Restaura $s2 da pilha
    lw $s1, 8($sp)          # Restaura $s1 da pilha
    lw $s0, 12($sp)          # Restaura $s0 da pilha
    lw $ra, 16($sp)         # Restaura endereço de retorno da pilha
    addi $sp, $sp, 20       # Libera 16 bytes da pilha (volta ao estado original)
    j cli_loop              # Retorna ao loop principal do programa
    
# FUNCAO Handler para transferir_debito
handle_transferir_debito:
    addi $sp, $sp, -24      # MUDADO: Aloca 24 bytes (6 registradores)
    sw $ra, 20($sp)         
    sw $s0, 16($sp)          
    sw $s1, 12($sp)          
    sw $s2, 8($sp)
    sw $s3, 4($sp)          # NOVO: para data
    sw $s4, 0($sp)          # NOVO: para hora

    # 1. Parsear CONTA_ORIGEM
    la $a0, buffer_temp     
    li $a1, '-'             
    move $a2, $s1           
    jal parse_campo         
    move $s1, $v0           

    # 2. Parsear CONTA_DESTINO
    la $a0, buffer_args     
    li $a1, '-'             
    move $a2, $s1           
    jal parse_campo         
    move $s1, $v0           

    # 3. Parsear VALOR
    la $a0, buffer_conta_completa 
    li $a1, '-'             
    move $a2, $s1           
    jal parse_campo         

    # 4. Converter VALOR para inteiro ANTES das buscas
    la $a0, buffer_conta_completa 
    jal atoi
    move $s2, $v0           # Valor salvo em $s2 antes que o buffer seja sobrescrito

    # 5. Buscar cliente ORIGEM (conta em buffer_temp)
    la $a0, buffer_temp     
    jal buscar_cliente_por_conta_completa
    beqz $v0, transferir_falha_origem
    move $s0, $v0           

    # 6. Buscar cliente DESTINO (conta em buffer_args)
    la $a0, buffer_args     
    jal buscar_cliente_por_conta_completa
    beqz $v0, transferir_falha_destino
    move $s1, $v0           

    # 7. Verificar saldo e prosseguir...
    lw $t0, 72($s0)         
    blt $t0, $s2, transferir_falha_saldo

    # Saldo OK, continua
    sub $t0, $t0, $s2       # Subtrai o valor ($s2) do saldo da origem ($t0)
    sw $t0, 72($s0)         # Salva o novo saldo na origem

    # 8. Logica de DEPOSITO (no cliente DESTINO, $s1)
    lw $t1, 72($s1)         # Carrega o saldo do destino
    add $t1, $t1, $s2       # Adiciona o valor ($s2) ao saldo do destino ($t1)
    sw $t1, 72($s1)         # Salva o novo saldo no destino

    # NOVO: Obter data e hora atuais
    jal obter_data_hora_atual
    move $s3, $v0
    move $s4, $v1

    # 9. Registrar SAIDA (Origem)
    la $a0, 12($s0)
    sub $a1, $zero, $s2
    li $a2, 3
    move $a3, $s3
    
    addi $sp, $sp, -4
    sw $s4, 0($sp)          # Hora na pilha
    jal registrar_transacao_debito
    addi $sp, $sp, 4

    # 10. Registrar ENTRADA (Destino)
    la $a0, 12($s1)
    move $a1, $s2
    li $a2, 1
    move $a3, $s3
    
    addi $sp, $sp, -4
    sw $s4, 0($sp)          # Hora na pilha
    jal registrar_transacao_debito
    addi $sp, $sp, 4

    # 11. Imprimir Sucesso
    li $v0, 4
    la $a0, msg_transferencia_sucesso # Carrega a mensagem "Transferencia realizada com sucesso\n"
    syscall
    j transferir_fim                # Pula para o fim

transferir_falha_origem:
    li $v0, 4
    la $a0, msg_conta_origem_inexistente # Carrega a mensagem "Falha: conta origem inexistente\n"
    syscall
    j transferir_fim                # Pula para o fim

transferir_falha_destino:
    li $v0, 4
    la $a0, msg_conta_destino_inexistente # Carrega a mensagem "Falha: conta destino inexistente\n"
    syscall
    j transferir_fim                # Pula para o fim

transferir_falha_saldo:
    li $v0, 4
    la $a0, msg_saldo_insuficiente # Carrega a mensagem "Falha: saldo insuficente\n"
    syscall
    # (O fluxo continua para 'transferir_fim' logo abaixo)
    
transferir_fim:
    lw $s4, 0($sp)              # Restaura $s4
    lw $s3, 4($sp)              # Restaura $s3
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24           # Libera 24 bytes
    j cli_loop
    
    ##### FUNCAO Combinar Data e Hora #####
# Entrada: $a0 = data (DDMMAAAA), $a1 = hora (HHMMSS)
# Sa?da: $v0 = timestamp combinado (AAAAMMDDHHMMSS)
combinar_data_hora:
    # Extrair componentes da data
    li $t0, 1000000
    div $a0, $t0
    mflo $t1          # DD
    mfhi $t2          # MMAAAA
    
    li $t3, 10000
    div $t2, $t3
    mflo $t4          # MM
    mfhi $t5          # AAAA
    
    # Reconstruir data no formato AAAAMMDD
    mul $v0, $t5, 10000  # AAAA * 10000
    add $v0, $v0, $t4    # + MM
    mul $v0, $v0, 100    # * 100
    add $v0, $v0, $t1    # + DD = AAAAMMDD
    
    # Combinar com hora (HHMMSS)
    mul $v0, $v0, 1000000  # AAAAMMDD * 1000000
    add $v0, $v0, $a1      # + HHMMSS = AAAAMMDDHHMMSS
    
    jr $ra
    
# Funcao Handler para debito_extrato
handle_debito_extrato:
    addi $sp, $sp, -20      # Aloca 20 bytes na pilha
    sw $ra, 16($sp)         # Salva o endereco de retorno ($ra)
    sw $s0, 12($sp)         # Salva $s0 (para o ponteiro do cliente)
    sw $s1, 8($sp)          # Salva $s1 (para o contador 'i' do loop)
    sw $s2, 4($sp)          # Salva $s2 (para o limite do loop)
    sw $s3, 0($sp)          # Salva $s3 (para o ponteiro da string da conta)

    # 1. Parsear CONTA (unico argumento)
    la $a0, buffer_temp     # $a0 (destino) = buffer_temp
    li $a1, '-'             # $a1 (delimitador)
    move $a2, $s1           # $a2 (fonte) = $s1 vindo do main (com "CONTA")
    jal parse_campo         # Extrai a conta

    # 2. Buscar cliente
    la $a0, buffer_temp     # Passa a string da conta
    jal buscar_cliente_por_conta_completa
    beqz $v0, extrato_falha_cliente # Se $v0 for 0, pula para falha
    move $s0, $v0           # Salva o ponteiro do cliente em $s0

    # 3. Imprimir Cabecalho do Extrato
    li $v0, 4
    la $a0, msg_extrato_cabecalho # Imprime "Extrato da conta "
    syscall
    la $a0, buffer_temp     # Imprime a conta (XXXXXX-X) que o usuario digitou
    syscall
    la $a0, newline         # Imprime uma nova linha
    syscall

    # 4. Preparar o Loop
    la $s3, 12($s0)         # $s3 = ponteiro para a string da conta do cliente
    li $s1, 0               # $s1 = i = 0
    la $t0, num_transacoes_debito
    lw $s2, 0($t0)          # $s2 = limite (numero total de transacoes registradas)

extrato_loop:
    bge $s1, $s2, extrato_fim_loop # Se (i >= limite), termina o loop

    # Calcula endereco da transacao[i] (24 bytes cada)
    li $t0, 24
    mul $t1, $s1, $t0
    la $t2, transacoes_debito
    add $t2, $t2, $t1

    # 6. Comparar a conta da transacao[i] com a conta do cliente
    move $a0, $s3           # $a0 = conta do cliente (de $s3)
    move $a1, $t2           # $a1 = conta da transacao (Offset 0 do slot $t2)
    jal strcmp              # Compara as duas strings

    bnez $v0, extrato_proxima_transacao # Se $v0 != 0, pula esta transacao

    # 7. CONTAS IGUAIS: Imprimir os dados da transacao
    # Imprimir TIPO
    lw $t3, 12($t2)         # Carrega o Tipo da transacao
    beq $t3, 1, extrato_tipo1 # Se tipo 1, pula para imprimir "Deposito"
    beq $t3, 2, extrato_tipo2 # Se tipo 2, pula para imprimir "Saque"
    beq $t3, 3, extrato_tipo3 # Se tipo 3, pula para imprimir "Transferencia"
    j extrato_imprimir_valor # Pula se for um tipo desconhecido (ou 0)

extrato_tipo1:
    li $v0, 4
    la $a0, msg_extrato_tipo1 # Imprime "Tipo: Deposito"
    syscall
    j extrato_imprimir_valor

extrato_tipo2:
    li $v0, 4
    la $a0, msg_extrato_tipo2 # Imprime "Tipo: Saque"
    syscall
    j extrato_imprimir_valor

extrato_tipo3:
    li $v0, 4
    la $a0, msg_extrato_tipo3 # Imprime "Tipo: Transferencia"
    syscall

extrato_imprimir_valor:
    # Imprimir Valor
    li $v0, 4
    la $a0, msg_extrato_valor
    syscall

    lw $a0, 8($t2)          # Carrega o Valor
    jal print_moeda

# === CORREÇÃO DA EXIBIÇÃO DE DATA E HORA ===
li $v0, 4
la $a0, msg_data_hora_prefix
syscall

lw $t5, 16($t2)         # Data (AAAAMMDD) - Ex: 20251111
lw $t6, 20($t2)         # Hora (HHMMSS)   - Ex: 173000

# ========== EXTRAIR E IMPRIMIR DATA (DD/MM/AAAA) ==========
# Data está em $t5 como DDMMAAAA (ex: 11112025)
# Extrair DD (dia)
li $t7, 1000000
div $t5, $t7
mflo $t4                # Dia = DD
mfhi $t8                # Resto = MMAAAA

# Extrair MM (mes) e AAAA (ano) do resto
li $t7, 10000
div $t8, $t7
mflo $t3                # Mes = MM
mfhi $t9                # Ano = AAAA

# Imprimir formato DD/MM/AAAA
li $v0, 1
move $a0, $t4           # Dia
syscall

li $v0, 4
la $a0, msg_barra_data  # "/"
syscall

li $v0, 1
move $a0, $t3           # Mes
syscall

li $v0, 4
la $a0, msg_barra_data  # "/"
syscall

li $v0, 1
move $a0, $t9           # Ano
syscall

# Espaco antes da hora
li $v0, 4
la $a0, msg_espaco
syscall

# ========== EXTRAIR E IMPRIMIR HORA (HH:MM:SS) ==========
# Extrair HH (hora)
li $t7, 10000
div $t6, $t7            # Divide HHMMSS por 10000
mflo $t6                # Hora
mfhi $t7                # Resto = MMSS

# Extrair MM (minutos) e SS (segundos)
li $t8, 100
div $t7, $t8            # Divide MMSS por 100
mflo $t8                # Minutos
mfhi $t9                # Segundos

# Imprimir formato HH:MM:SS
move $a0, $t6           # Hora
jal print_dois_digitos

li $v0, 4
la $a0, msg_dois_pontos # ":"
syscall

move $a0, $t8           # Minutos
jal print_dois_digitos

li $v0, 4
la $a0, msg_dois_pontos # ":"
syscall

move $a0, $t9           # Segundos
jal print_dois_digitos

# Nova linha
li $v0, 4
la $a0, newline
syscall

j extrato_proxima_transacao
    
extrato_proxima_transacao:
    addi $s1, $s1, 1        # i++ (incrementa o contador do loop)
    j extrato_loop          # Volta ao inicio do loop

extrato_falha_cliente:
    li $v0, 4
    la $a0, msg_cliente_inexistente # Imprime "Falha: cliente inexistente\n"
    syscall
    # (O fluxo continua para 'extrato_fim_loop' logo abaixo)

extrato_fim_loop:
    # Imprime um newline extra para formatacao
    li $v0, 4
    la $a0, newline
    syscall

    # Restaurar a pilha
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20       # Libera os 20 bytes alocados
    j cli_loop              # Retorna ao loop principal
    
# FUNCAO logica_cadastro_cliente
# Esta funï¿½ï¿½o assume que buffer_cpf, buffer_conta, e buffer_nome
# jï¿½ foram preenchidos pelo 'main'
logica_cadastro_cliente:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Verificar limite de clientes
    la $t0, num_clientes
    lw $t1, 0($t0)
    la $t2, max_clientes
    lw $t3, 0($t2)
    bge $t1, $t3, erro_limite_clientes

    # Verificar se CPF jï¿½ existe
    la $a0, buffer_cpf
    jal verificar_cpf_existe
    beq $v0, 1, erro_cpf_duplicado

    # Verificar se conta jï¿½ existe
    la $a0, buffer_conta
    jal verificar_conta_existe
    beq $v0, 1, erro_conta_duplicada

    # Calcular dï¿½gito verificador
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

# --- Funï¿½ï¿½es de "Em Construï¿½ï¿½o" ---
# (Elas sï¿½o todas tratadas pelo 'handle_em_construcao' no main)

##### FUNCOES DE LIMPEZA DE NEWLINE (MANTIDAS) #####

# Limpador genï¿½rico para buffer_comando
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

##### Funcao Calcular Digito Verificador #####
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

    # Resto da divisï¿½o por 11
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
# Esta funï¿½ï¿½o ï¿½ um HELPER, chamada por handle_conta_buscar
# Entrada: $a0 = endereï¿½o da string conta (ex: 123456-7) NO BUFFER_TEMP
# Saï¿½da: $v0 = ponteiro para o cliente, 0 se nï¿½o existe
buscar_cliente_por_conta_completa:
 addi $sp, $sp, -4
 sw $ra, 0($sp)

 # Formatar a conta de busca (123456-7) para o formato salvo (1234567\0)
 # A conta jï¿½ estï¿½ em $a0 (buffer_temp), vamos formatï¿½-la no buffer_conta_completa
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

 # Agora, $a0 (buffer_conta_completa) contï¿½m "1234567"
 la $a0, buffer_conta_completa

 # Loop principal de busca
 la $t0, clientes
 la $t1, num_clientes
 lw $t2, 0($t1)  # nï¿½mero de clientes
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
   addi $t0, $t0, 128  # prï¿½ximo cliente
   addi $t3, $t3, 1
   j loop_buscar_conta_comp_interno

 buscar_conta_comp_nao_existe_interno:
  li $v0, 0

 fim_buscar_conta_comp_interno:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

##### FUNCAO Adicionar Cliente #####
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

# --- Funï¿½ï¿½es de Persistï¿½ncia Comentadas ---
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
  beqz $t3, fim_parse_campo_null # Se for \0, nï¿½o pule

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
 addi $sp, $sp, -16   # CORREÇÃO: Alocar 16 bytes para 4 registradores
 sw $ra, 0($sp)
 sw $s0, 4($sp)
 sw $s1, 8($sp)
 sw $t0, 12($sp) # <-- Agora esta escrita é segura

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
    li $v0, 0 # Assume que sï¿½o iguais

    loop_strcmp:
        lb $t0, 0($a0)
        lb $t1, 0($a1)

        bne $t0, $t1, strcmp_diferente

        beqz $t0, fim_strcmp # Se $t0 ï¿½ \0 (e sï¿½o iguais), fim

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


