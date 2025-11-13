# PingasBank
# Integrantes: Heitor, Joao Ricardo, Emanuel, Henrique.
#
.data
# ===== ATRIBUTOS E BUFFERS (.data) =====
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

    clientes: .space 6400           # 50 clientes * 128 bytes cada
    num_clientes: .word 0           # Contador de clientes ativos

    ## Buffers de conta e arquivo: ##
    buffer_comando: .space 256      # Buffer para o comando completo do CLI
    buffer_cpf: .space 12           # Buffer para CPF (cadastro)
    buffer_conta: .space 8          # Buffer para Conta (cadastro, sem DV)
    buffer_conta_completa: .space 10 # Buffer para Conta (formato XXXXXX-D\0)
    buffer_nome: .space 51          # Buffer para Nome (cadastro)
    buffer_temp: .space 200         # Buffer temporário para parsear comandos
    buffer_args: .space 200         # Buffer para guardar ponteiros de argumentos
    buffer_arquivo: .space 8000     # Buffer grande para ler o arquivo de dados
    buffer_confirmar_opcao: .space 4 # Buffer para confirmação (S/N)
    buffer_linha: .space 256        # Buffer para ler uma linha do arquivo

    ## Constantes globais ##
    limite_credito_padrao: .word 150000 # R$1500,00 (em centavos)
    max_clientes: .word 50          # Limite de clientes no sistema

    ## Estrutura para extrato de debito ##
    # Cada transacao ocupara 24 bytes:	
    # Offset 0: Conta (8 bytes) - A conta (com digito verificador) a quem pertence a transacao.
    # Offset 8: Valor (4 bytes) - Em centavos (positivo para entrada, negativo para saida).
    # Offset 12: Tipo (4 bytes) - (ex: 1=Deposito, 2=Saque, 3=Transf. Debito).
    # Offset 16: Data (4 bytes) - AAAAMMDD
    # Offset 20: Hora (4 bytes) - HHMMSS
    .align 2                        # Alinha os dados em 4 bytes
    transacoes_debito: .space 24000 # 1000 transacoes * 24 bytes cada
    num_transacoes_debito: .word 0  # Contador de transações de débito
    max_transacoes_debito: .word 1000 # Limite de transações de débito
    
    ## ESTRUTURA DE TRANSAÇÕES DE CRÉDITO ##
    # Cada transação ocupará 24 bytes:
    # Offset 0: Conta (8 bytes) - Conta do cliente
    # Offset 8: Valor (4 bytes) - Valor em centavos
    # Offset 12: Tipo (4 bytes) - 4=Pagamento, 5=Uso Crédito, 6=Juros
    # Offset 16: Data (4 bytes) - AAAAMMDD
    # Offset 20: Hora (4 bytes) - HHMMSS
    .align 2                        # Alinha os dados em 4 bytes
    transacoes_credito: .space 1200 # 50 transações * 24 bytes
    num_transacoes_credito: .word 0 # Contador de transações de crédito
    max_transacoes_credito: .word 50 # Limite de transações de crédito

# ===== MENSAGENS DO SISTEMA (.data) =====
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
    
    ##### Strings conta_formatar #####
    msg_confirmar_formatacao: .asciiz "\nATENCAO: Todas as transacoes de debito desta conta serao apagadas. Confirmar (S/N)? "
    msg_formatacao_cancelada: .asciiz "\nOperacao cancelada.\n"
    msg_conta_invalida: .asciiz "\nFalha: conta invalida\n"
    msg_formatacao_sucesso: .asciiz "\nConta formatada com sucesso. Todas as transacoes de debito foram removidas.\n"

    ##### Strings para impressão em conta_buscar #####
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

    ##### Strings do Extrato de Débito #####
    msg_extrato_cabecalho: .asciiz "\nExtrato da conta "
    msg_extrato_tipo1: .asciiz "\nTipo: Deposito"
    msg_extrato_tipo2: .asciiz "\nTipo: Saque"
    msg_extrato_tipo3: .asciiz "\nTipo: Transferencia"
    msg_extrato_valor: .asciiz " | Valor: "
    
    msg_em_construcao: .asciiz "\nEm construcao...\n"

    ##### Strings para formatação de data/hora no extrato #####
    msg_data_hora_prefix: .asciiz " | Data/Hora: "
    msg_barra_data: .asciiz "/"
    msg_espaco: .asciiz " "
    msg_dois_pontos: .asciiz ":"

    ##### Menu Principal - CLI #####
    prompt_cli: .asciiz "\nPingasBank> "
    goodbye: .asciiz "\nEncerrando o programa, ate mais!\n"

# ===== COMANDOS E TEMPO (.data) =====
    ##### Nomes dos Comandos para Comparação #####
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
    tempo_ultimo_incremento: .word 0  # Tempo em ms (syscall 30) desde o último incremento
    
    ##### Mensagens de Data/Hora #####
    msg_data_hora_sucesso: .asciiz "\nData e hora configuradas com sucesso\n"
    msg_data_invalida: .asciiz "\nErro: Data invalida\n"
    msg_hora_invalida: .asciiz "\nErro: Hora invalida\n"
    msg_data_hora_nao_configurada: .asciiz "\nErro: Data e hora nao configuradas\n"
    msg_extrato_data_hora: .asciiz " | Data/Hora: "
    
    ##### Mensagem de alteração de limite #####
    msg_limite_alterado_sucesso: .asciiz "\nLimite de credito alterado com sucesso\n"
    
    ##### Mensagens de encerramento de conta #####
    msg_conta_fechada_sucesso: .asciiz "\nConta fechada com sucesso\n"
    msg_cpf_nao_cadastrado: .asciiz "\nFalha: CPF nao possui cadastro\n"
    msg_saldo_devedor: .asciiz "\nFalha: saldo devedor ainda nao quitado. Saldo da conta corrente R$ "
    msg_limite_devido: .asciiz " / Limite de credito devido: R$ "
    
# ===== PERSISTÊNCIA E JUROS (.data) =====
    ##### Mensagens de persistência de dados #####
    msg_salvar_sucesso: .asciiz "\nDados salvos com sucesso no arquivo pingasbank_data.txt\n"
    msg_salvar_erro: .asciiz "\nErro ao salvar dados no arquivo\n"
    msg_recarregar_sucesso: .asciiz "\nDados recarregados com sucesso do arquivo pingasbank_data.txt\n"
    msg_recarregar_erro: .asciiz "\nErro ao recarregar dados do arquivo\n"
    msg_arquivo_nao_existe: .asciiz "\nArquivo nao existe. Sistema iniciado sem dados salvos.\n"
    msg_formatar_confirmacao: .asciiz "\nATENCAO: Todos os dados serao apagados. Confirmar (S/N)? "
    msg_formatar_sucesso: .asciiz "\nSistema formatado com sucesso. Todos os dados foram apagados.\n"
    msg_formatar_cancelado: .asciiz "\nFormatacao cancelada.\n"
    
    ##### Nome do arquivo #####
    arquivo_nome: .asciiz "pingasbank_data.txt"

    ##### Formatação para persistencia de dados #####
    arquivo_marcador_cab:    .asciiz "<CAB>"
    arquivo_marcador_fim_cab: .asciiz "</CAB>"
    arquivo_marcador_cli:    .asciiz "<CLI>"
    arquivo_marcador_fim_cli: .asciiz "</CLI>"
    arquivo_marcador_trd:    .asciiz "<TRD>"
    arquivo_marcador_fim_trd: .asciiz "</TRD>"
    arquivo_marcador_trc:    .asciiz "<TRC>"
    arquivo_marcador_fim_trc: .asciiz "</TRC>"
    
    .align 2 # Alinha a próxima variável
    
    ##### Juros #####
    # Estrutura de controle de juros (um por cliente)
    # Cada entrada: 12 bytes
    # Offset 0: Conta (8 bytes)
    # Offset 8: Última aplicação de juros - timestamp (4 bytes) formato AAAAMMDDHHMMSS compactado
    ultimo_calculo_juros: .space 600  # 50 clientes * 12 bytes

    # Mensagem de juros aplicados
    msg_juros_aplicados: .asciiz "\n[SISTEMA] Juros de 1% aplicados na conta "
    
.text
.globl main

# ===== FUNCAO Main - LOOP CLI =====
main:
    ## Salva o ponteiro para os argumentos (se houver, do S.O.)
    addi $sp, $sp, -4       # Aloca espaço na pilha
    sw $s1, 0($sp)          # Salva $s1 (será usado para argumentos do CLI)
    
    ## Recarregar dados automaticamente ao iniciar
    jal recarregar_dados    # Chama a função para carregar dados do arquivo

cli_loop:
    ## Mostrar o prompt
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, prompt_cli      # Carrega o endereço do prompt "PingasBank> "
    syscall                 # Executa a syscall

    ## Ler o comando inteiro do usuário
    li $v0, 8               # Syscall 8 (read_string)
    la $a0, buffer_comando  # Buffer de destino
    li $a1, 256             # Tamanho máximo
    syscall                 # Executa a syscall

    ## Limpar o newline do comando
    la $a0, buffer_comando  # Passa o buffer como argumento
    jal limpar_newline_comando # Chama a função de limpeza

    ## Parsear o COMANDO (a parte antes do primeiro '-')
    la $a0, buffer_temp     # $a0 = Destino (comando)
    li $a1, '-'             # $a1 = Delimitador
    la $a2, buffer_comando  # $a2 = Fonte (linha completa)
    jal parse_campo         # Chama a função de parse
    move $s1, $v0           # Salva o ponteiro para o RESTO (argumentos) em $s1

    ## -- Início do Bloco de Comparação de Comandos -- ##
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_conta_cadastrar # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_conta_cadastrar # Se $v0 == 0 (iguais), pula para o handler

    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_conta_buscar # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_conta_buscar # Se $v0 == 0 (iguais), pula para o handler

    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_encerrar    # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_encerrar # Se $v0 == 0 (iguais), pula para o handler

    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_conta_format # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_conta_format # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_debito_extrato # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_debito_extrato # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_transferir_debito # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_transferir_debito # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_transferir_credito # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_transferir_credito # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_pagar_fatura # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_pagar_fatura # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_sacar       # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_sacar  # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_depositar   # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_depositar # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_data_hora   # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_data_hora # Se $v0 == 0 (iguais), pula para o handler

    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_credito_extrato # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_credito_extrato # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_alterar_limite # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_alterar_limite # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_conta_fechar # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_conta_fechar # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_salvar      # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_salvar # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_recarregar  # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_recarregar # Se $v0 == 0 (iguais), pula para o handler
    
    la $a0, buffer_temp     # Carrega o comando extraído
    la $a1, str_formatar    # Carrega a string de comparação
    jal strcmp              # Compara as strings
    beqz $v0, handle_formatar # Se $v0 == 0 (iguais), pula para o handler
    
    ## Se chegou aqui, o comando é inválido
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_comando_invalido # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j cli_loop              # Volta ao início do loop

# ===== HANDLERS DE COMANDOS =====

#### Handler para o comando 'conta_fechar'
#### Comando: conta_fechar-<conta>
#### Desativa uma conta, zerando seu status, se os saldos estiverem zerados.
handle_conta_fechar:
    ## Salvar registradores na pilha
    addi $sp, $sp, -12      # Aloca 12 bytes
    sw $ra, 8($sp)          # Salva o endereço de retorno
    sw $s0, 4($sp)          # Salva $s0 (ponteiro do cliente)
    sw $s1, 0($sp)          # Salva $s1 (argumentos do main)

    ## 1. Parsear CONTA
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos)
    jal parse_campo         # Extrai a conta

    ## 2. Buscar cliente
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, fechar_falha_cpf # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva o ponteiro do cliente em $s0

    ## 3. Verificar saldo da conta corrente (offset 72)
    lw $t0, 72($s0)         # Carrega o saldo
    bnez $t0, fechar_falha_saldo_devedor # Se saldo != 0, pula para o erro

    ## 4. Verificar crédito usado (offset 80)
    lw $t1, 80($s0)         # Carrega o crédito usado
    bnez $t1, fechar_falha_saldo_devedor # Se crédito != 0, pula para o erro

    ## 5. Saldos zerados: desativar conta
    sw $zero, 84($s0)       # Define Status = 0 (inativo)

    ## 6. Limpar transações de débito associadas
    la $a0, 12($s0)         # Passa o ponteiro da string da conta (offset 12)
    jal limpar_transacoes_debito_cliente # Chama a limpeza

    ## 7. Limpar transações de crédito associadas
    la $a0, 12($s0)         # Passa o ponteiro da string da conta (offset 12)
    jal limpar_transacoes_credito_cliente # Chama a limpeza

    ## 8. Mensagem de sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_conta_fechada_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall

    j fechar_fim            # Pula para o fim

fechar_falha_cpf:
    ## Mensagem de erro: CPF (conta) não encontrado
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cpf_nao_cadastrado # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j fechar_fim            # Pula para o fim

fechar_falha_saldo_devedor:
    ## Mensagem de erro: Cliente ainda possui dívidas
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_saldo_devedor # Carrega mensagem de erro (parte 1)
    syscall                 # Executa a syscall

    ## Imprimir saldo da conta corrente
    lw $a0, 72($s0)         # $a0 = saldo
    jal print_moeda         # Imprime o valor formatado

    ## Imprimir separador
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_limite_devido # Carrega mensagem (parte 2)
    syscall                 # Executa a syscall

    ## Imprimir crédito devido
    lw $a0, 80($s0)         # $a0 = crédito usado
    jal print_moeda         # Imprime o valor formatado

fechar_fim:
    ## Restaurar registradores da pilha
    lw $s1, 0($sp)          # Restaura $s1
    lw $s0, 4($sp)          # Restaura $s0
    lw $ra, 8($sp)          # Restaura $ra
    addi $sp, $sp, 12       # Libera 12 bytes da pilha
    j cli_loop              # Retorna ao loop principal

#### Função auxiliar para limpar transações de crédito de um cliente
#### Entrada: $a0 = ponteiro para a string da conta do cliente
limpar_transacoes_credito_cliente:
    ## Salvar registradores na pilha
    addi $sp, $sp, -24      # Aloca 24 bytes
    sw $ra, 20($sp)         # Salva $ra
    sw $s0, 16($sp)         # Salva $s0 (conta)
    sw $s1, 12($sp)         # Salva $s1 (índice leitor)
    sw $s2, 8($sp)          # Salva $s2 (índice escritor)
    sw $s3, 4($sp)          # Salva $s3 (contador removidos)
    sw $s4, 0($sp)          # Salva $s4 (ponteiro num_transacoes)

    move $s0, $a0           # $s0 = conta do cliente
    li $s1, 0               # $s1 = índice leitor
    li $s2, 0               # $s2 = índice escritor
    li $s3, 0               # $s3 = contador de removidos
    
    la $s4, num_transacoes_credito # $s4 = endereço do contador
    lw $t4, 0($s4)          # $t4 = total de transações

limpar_cred_loop:
    ## Loop principal (algoritmo de "gap compacting")
    bge $s1, $t4, limpar_cred_fim # Se leitor >= total, fim

    ## Calcular offset da transação de leitura (24 bytes por transação)
    li $t1, 24              # Tamanho da transação
    mul $t5, $s1, $t1       # offset = leitor * 24
    la $t6, transacoes_credito # Endereço base
    add $t6, $t6, $t5       # Endereço da transação[leitor]

    ## Comparar conta
    move $a0, $s0           # $a0 = conta do cliente
    move $a1, $t6           # $a1 = conta da transação[leitor]
    jal strcmp              # Compara as strings

    beqz $v0, limpar_cred_encontrada # Se $v0 == 0 (iguais), é para remover

    ## Diferente: copiar transação da posição [leitor] para [escritor]
    mul $t5, $s2, $t1       # offset = escritor * 24
    la $t7, transacoes_credito # Endereço base
    add $t7, $t7, $t5       # Endereço da transação[escritor]

    ## Copiar 24 bytes
    li $t8, 0               # Contador de bytes
limpar_cred_copiar:
    lb $t9, 0($t6)          # Carrega byte da [leitor]
    sb $t9, 0($t7)          # Salva byte na [escritor]
    addi $t6, $t6, 1        # Avança ponteiro [leitor]
    addi $t7, $t7, 1        # Avança ponteiro [escritor]
    addi $t8, $t8, 1        # Incrementa contador de bytes
    blt $t8, 24, limpar_cred_copiar # Loop até 24 bytes

    addi $s2, $s2, 1        # Incrementa índice escritor
    j limpar_cred_proxima   # Pula para próxima iteração

limpar_cred_encontrada:
    ## Transação encontrada, incrementar contador de removidos
    addi $s3, $s3, 1        # Apenas "pula" esta transação (não copia, não incrementa escritor)

limpar_cred_proxima:
    addi $s1, $s1, 1        # Incrementa índice leitor
    j limpar_cred_loop      # Volta ao loop

limpar_cred_fim:
    ## Atualizar contador
    sub $t4, $t4, $s3       # novo_total = total_antigo - removidos
    sw $t4, 0($s4)          # Salva o novo total

    ## Restaurar registradores da pilha
    lw $s4, 0($sp)          # Restaura $s4
    lw $s3, 4($sp)          # Restaura $s3
    lw $s2, 8($sp)          # Restaura $s2
    lw $s1, 12($sp)         # Restaura $s1
    lw $s0, 16($sp)         # Restaura $s0
    lw $ra, 20($sp)         # Restaura $ra
    addi $sp, $sp, 24       # Libera 24 bytes
    jr $ra                  # Retorna

#### Handler para o comando 'alterar_limite'
#### Comando: alterar_limite-<conta>-<novo_limite>
#### Altera o limite de crédito do cliente especificado.
handle_alterar_limite:
    ## Salvar registradores na pilha
    addi $sp, $sp, -16      # Aloca 16 bytes
    sw $ra, 12($sp)         # Salva $ra
    sw $s0, 8($sp)          # Salva $s0 (ponteiro cliente)
    sw $s1, 4($sp)          # Salva $s1 (novo limite)
    sw $s2, 0($sp)          # Salva $s2 (argumentos do main)

    ## 1. Parsear CONTA
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos)
    jal parse_campo         # Extrai a conta
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 2. Parsear NOVO_LIMITE
    la $a0, buffer_args     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte
    jal parse_campo         # Extrai o novo limite (string)

    ## 3. Converter NOVO_LIMITE para inteiro
    la $a0, buffer_args     # $a0 = string do limite
    jal atoi                # Converte para inteiro
    move $s1, $v0           # Salva novo limite (int) em $s1

    ## 4. Buscar cliente
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, alterar_limite_falha_cliente # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 5. Atualizar limite de crédito (offset 76)
    sw $s1, 76($s0)         # Salva o novo limite no registro do cliente

    ## 6. Mensagem de sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_limite_alterado_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall

    ## Exibir novo limite
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_limite  # Carrega "Limite de Credito: "
    syscall                 # Executa a syscall
    move $a0, $s1           # $a0 = novo limite
    jal print_moeda         # Imprime o valor formatado

    j alterar_limite_fim    # Pula para o fim

alterar_limite_falha_cliente:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall

alterar_limite_fim:
    ## Restaurar registradores da pilha
    lw $s2, 0($sp)          # Restaura $s2
    lw $s1, 4($sp)          # Restaura $s1
    lw $s0, 8($sp)          # Restaura $s0
    lw $ra, 12($sp)         # Restaura $ra
    addi $sp, $sp, 16       # Libera 16 bytes
    j cli_loop              # Retorna ao loop principal

#### Função para imprimir número com dois dígitos (ex: 07, 12)
#### Entrada: $a0 = número
print_dois_digitos:
    blt $a0, 10, print_dd_zero # Se $a0 < 10, precisa imprimir o '0'
    li $v0, 1               # Syscall 1 (print_int)
    syscall                 # Imprime o número
    jr $ra                  # Retorna
    
print_dd_zero:
    move $t0, $a0           # Salva o valor original em $t0
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_zero    # Carrega "0"
    syscall                 # Imprime "0"
    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t0           # Restaura o valor original para $a0
    syscall                 # Imprime o número (ex: 7)
    jr $ra                  # Retorna

# ===== FUNÇÕES DE TRANSAÇÃO (CRÉDITO) =====

#### Handler para o comando 'credito_extrato'
#### Comando: credito_extrato-<conta>
#### Exibe o extrato de transações de crédito (fatura) do cliente.
handle_credito_extrato:
    ## Salvar registradores na pilha
    addi $sp, $sp, -20      # Aloca 20 bytes
    sw $ra, 16($sp)         # Salva $ra
    sw $s0, 12($sp)         # Salva $s0 (ponteiro cliente)
    sw $s1, 8($sp)          # Salva $s1 (índice loop)
    sw $s2, 4($sp)          # Salva $s2 (total transações)
    sw $s3, 0($sp)          # Salva $s3 (ponteiro string conta cliente)

    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros

    ## 1. Parsear CONTA
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos do main)
    jal parse_campo         # Extrai a conta

    ## 2. Buscar cliente
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, credito_extrato_falha_cliente # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 3. Imprimir CABEÇALHO
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_credito_extrato_cabecalho # Carrega "=== EXTRATO DE CRÉDITO da conta "
    syscall                 # Executa a syscall
    la $a0, buffer_temp     # $a0 = conta (string)
    syscall                 # Imprime a conta
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Carrega "\n"
    syscall                 # Imprime "\n"

    ## 4. Imprimir LIMITES DE CRÉDITO
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_credito_limite # Carrega "Limite de Crédito: "
    syscall                 # Executa a syscall
    lw $a0, 76($s0)         # $a0 = limite (offset 76)
    jal print_moeda         # Imprime o valor formatado

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_credito_usado # Carrega "Crédito Usado: "
    syscall                 # Executa a syscall
    lw $a0, 80($s0)         # $a0 = crédito usado (offset 80)
    jal print_moeda         # Imprime o valor formatado

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_credito_disponivel # Carrega "Crédito Disponível: "
    syscall                 # Executa a syscall
    lw $t0, 76($s0)         # $t0 = limite
    lw $t1, 80($s0)         # $t1 = crédito usado
    sub $a0, $t0, $t1       # $a0 = disponível (limite - usado)
    jal print_moeda         # Imprime o valor formatado

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Carrega "\n"
    syscall                 # Imprime "\n"

    ## 5. Preparar loop de transações
    la $s3, 12($s0)         # $s3 = ponteiro para string da conta do cliente (offset 12)
    li $s1, 0               # $s1 = índice (i = 0)
    la $t0, num_transacoes_credito # Endereço do contador
    lw $s2, 0($t0)          # $s2 = total de transações de crédito

credito_extrato_loop:
    ## Loop por todas as transações de crédito
    bge $s1, $s2, credito_extrato_fim # Se i >= total, fim

    ## Calcular endereço da transação[i]
    li $t0, 24              # Tamanho da transação
    mul $t1, $s1, $t0       # offset = i * 24
    la $t2, transacoes_credito # Endereço base
    add $t2, $t2, $t1       # $t2 = endereço da transação[i]

    ## Verificar se transação pertence a esta conta
    move $a0, $s3           # $a0 = conta do cliente
    move $a1, $t2           # $a1 = conta da transação[i] (offset 0)
    jal strcmp              # Compara as strings
    bnez $v0, credito_extrato_proxima # Se $v0 != 0 (diferentes), pula

    ## Imprimir TIPO da transação
    lw $t3, 12($t2)         # $t3 = tipo (offset 12)
    beq $t3, 4, credito_tipo4 # Se tipo 4 (Pagamento)
    beq $t3, 5, credito_tipo5 # Se tipo 5 (Uso Crédito)
    beq $t3, 6, credito_tipo6 # Se tipo 6 (Juros)
    j credito_imprimir_valor # Tipo desconhecido (imprime só valor)

credito_tipo4:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_credito_tipo4 # Carrega "Tipo: PAGAMENTO FATURA"
    syscall                 # Executa a syscall
    j credito_imprimir_valor # Pula para imprimir valor

credito_tipo5:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_credito_tipo5 # Carrega "Tipo: USO CRÉDITO"
    syscall                 # Executa a syscall
    j credito_imprimir_valor # Pula para imprimir valor

credito_tipo6:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_credito_tipo6 # Carrega "Tipo: JUROS"
    syscall                 # Executa a syscall

credito_imprimir_valor:
    ## Imprimir VALOR
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_valor # Carrega " | Valor: "
    syscall                 # Executa a syscall
    lw $a0, 8($t2)          # $a0 = valor (offset 8)
    jal print_moeda         # Imprime o valor formatado

    ## Imprimir DATA/HORA
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_data_hora_prefix # Carrega " | Data/Hora: "
    syscall                 # Executa a syscall

    lw $t5, 16($t2)         # $t5 = data AAAAMMDD (offset 16)
    lw $t6, 20($t2)         # $t6 = hora HHMMSS (offset 20)

    ## Extrair DD/MM/AAAA
    li $t7, 1000000         # Divisor
    div $t5, $t7            # data / 1000000
    mflo $t4                # $t4 = Dia
    mfhi $t8                # $t8 = Resto MMAAAA

    li $t7, 10000           # Divisor
    div $t8, $t7            # MMAAAA / 10000
    mflo $t3                # $t3 = Mes
    mfhi $t9                # $t9 = Ano

    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t4           # Imprime Dia
    syscall                 # Executa a syscall
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_barra_data  # Imprime "/"
    syscall                 # Executa a syscall
    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t3           # Imprime Mes
    syscall                 # Executa a syscall
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_barra_data  # Imprime "/"
    syscall                 # Executa a syscall
    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t9           # Imprime Ano
    syscall                 # Executa a syscall

    ## Espaço e hora
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_espaco      # Imprime " "
    syscall                 # Executa a syscall

    ## Extrair HH:MM:SS
    li $t7, 10000           # Divisor
    div $t6, $t7            # hora / 10000
    mflo $t6                # $t6 = Hora
    mfhi $t7                # $t7 = Resto MMSS

    li $t8, 100             # Divisor
    div $t7, $t8            # MMSS / 100
    mflo $t8                # $t8 = Minutos
    mfhi $t9                # $t9 = Segundos

    ## Imprimir HH:MM:SS com dois dígitos
    move $a0, $t6           # $a0 = Hora
    jal print_dois_digitos  # Imprime (ex: 09)

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_dois_pontos # Imprime ":"
    syscall                 # Executa a syscall

    move $a0, $t8           # $a0 = Minutos
    jal print_dois_digitos  # Imprime (ex: 05)

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_dois_pontos # Imprime ":"
    syscall                 # Executa a syscall

    move $a0, $t9           # $a0 = Segundos
    jal print_dois_digitos  # Imprime (ex: 30)

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Imprime "\n"
    syscall                 # Executa a syscall

    j credito_extrato_proxima # Pula para a próxima iteração

credito_extrato_proxima:
    addi $s1, $s1, 1        # i++
    j credito_extrato_loop  # Volta ao loop

credito_extrato_falha_cliente:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall

credito_extrato_fim:
    ## Imprime newline final
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Carrega "\n"
    syscall                 # Executa a syscall

    ## Restaurar registradores da pilha
    lw $s3, 0($sp)          # Restaura $s3
    lw $s2, 4($sp)          # Restaura $s2
    lw $s1, 8($sp)          # Restaura $s1
    lw $s0, 12($sp)         # Restaura $s0
    lw $ra, 16($sp)         # Restaura $ra
    addi $sp, $sp, 20       # Libera 20 bytes
    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'pagar_fatura'
#### Comando: pagar_fatura-<conta>-<valor>-<metodo>
#### <metodo>: S = saldo, E = externo
#### Registra um pagamento (Tipo 4) no extrato de crédito.
handle_pagar_fatura:
    ## Salvar registradores na pilha
    addi $sp, $sp, -32      # Aloca 32 bytes
    sw $ra, 28($sp)         # Salva $ra
    sw $s0, 24($sp)         # Salva $s0 (ponteiro cliente)
    sw $s1, 20($sp)         # Salva $s1 (valor)
    sw $s2, 16($sp)         # Salva $s2 (metodo: 1=S, 0=E)
    sw $s3, 12($sp)         # Salva $s3 (data)
    sw $s4, 8($sp)          # Salva $s4 (hora)
    sw $t0, 4($sp)          # Salva $t0
    sw $t1, 0($sp)          # Salva $t1

    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros
    
    ## 1. Parsear CONTA
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos do main)
    jal parse_campo         # Extrai a conta
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 2. Parsear VALOR
    la $a0, buffer_args     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte
    jal parse_campo         # Extrai o valor (string)
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 3. Parsear MÉTODO (S ou E)
    la $a0, buffer_conta_completa # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte
    jal parse_campo         # Extrai o método (string "S" ou "E")

    ## 4. Converter valor
    la $a0, buffer_args     # $a0 = valor (string)
    jal atoi                # Converte para inteiro
    move $s1, $v0           # Salva valor (int) em $s1

    ## 5. Verificar método
    la $t0, buffer_conta_completa # Endereço da string do método
    lb $t0, 0($t0)          # $t0 = primeiro caractere
    li $t1, 'S'             # 'S' maiúsculo
    beq $t0, $t1, metodo_saldo_ok
    li $t1, 's'             # 's' minúsculo
    beq $t0, $t1, metodo_saldo_ok
    li $t1, 'E'             # 'E' maiúsculo
    beq $t0, $t1, metodo_externo_ok
    li $t1, 'e'             # 'e' minúsculo
    beq $t0, $t1, metodo_externo_ok
    
    ## Método inválido
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_comando_invalido # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j pagar_fatura_fim      # Pula para o fim

metodo_saldo_ok:
    li $s2, 1               # $s2 = 1 (flag para 'Saldo')
    j buscar_cliente_fatura # Pula para busca
metodo_externo_ok:
    li $s2, 0               # $s2 = 0 (flag para 'Externo')

buscar_cliente_fatura:
    ## 6. Buscar cliente
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, pagar_falha_cliente # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 7. Verificar se valor <= crédito usado
    lw $t0, 80($s0)         # $t0 = Crédito usado (offset 80)
    blt $t0, $s1, pagar_falha_valor_maior_que_divida # Se divida < valor, erro

    ## 8. Se método=S, verificar saldo suficiente
    beqz $s2, pagar_sem_verificar_saldo # Se $s2 == 0 (Externo), pula verificação
    lw $t0, 72($s0)         # $t0 = Saldo (offset 72)
    blt $t0, $s1, pagar_falha_saldo_insuficiente # Se saldo < valor, erro

    ## 9. Método S: Reduzir saldo
    sub $t0, $t0, $s1       # saldo = saldo - valor
    sw $t0, 72($s0)         # Salva novo saldo

pagar_sem_verificar_saldo:
    ## 10. Reduzir crédito usado
    lw $t0, 80($s0)         # $t0 = crédito usado
    sub $t0, $t0, $s1       # crédito_usado = crédito_usado - valor
    sw $t0, 80($s0)         # Salva novo crédito usado

    ## 11. OBTER DATA/HORA
    jal obter_data_hora_atual # Obtém data e hora
    move $s3, $v0           # $s3 = data
    move $s4, $v1           # $s4 = hora

    ## 12. Registrar TRANSAÇÃO DE CRÉDITO (tipo 4 = Pagamento)
    la $a0, 12($s0)         # $a0 = Conta (string)
    sub $a1, $zero, $s1     # $a1 = Valor (negativo, pois reduz a dívida)
    li $a2, 4               # $a2 = Tipo 4 (Pagamento Fatura)
    move $a3, $s3           # $a3 = Data
    
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva a hora na pilha
    jal registrar_transacao_credito # Chama a função de registro
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 13. Sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_pagamento_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall
    j pagar_fatura_fim      # Pula para o fim

pagar_falha_cliente:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j pagar_fatura_fim      # Pula para o fim

pagar_falha_valor_maior_que_divida:
    ## Mensagem de erro: Valor maior que a dívida
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_valor_maior_que_divida # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j pagar_fatura_fim      # Pula para o fim

pagar_falha_saldo_insuficiente:
    ## Mensagem de erro: Saldo insuficiente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_saldo_insuficiente # Carrega mensagem de erro
    syscall                 # Executa a syscall

pagar_fatura_fim:
    ## Restaurar registradores da pilha
    lw $t1, 0($sp)          # Restaura $t1
    lw $t0, 4($sp)          # Restaura $t0
    lw $s4, 8($sp)          # Restaura $s4
    lw $s3, 12($sp)         # Restaura $s3
    lw $s2, 16($sp)         # Restaura $s2
    lw $s1, 20($sp)         # Restaura $s1
    lw $s0, 24($sp)         # Restaura $s0
    lw $ra, 28($sp)         # Restaura $ra
    addi $sp, $sp, 32       # Libera 32 bytes
    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'transferir_credito'
#### Comando: transferir_credito-<conta_destino>-<conta_origem>-<valor>
#### Transfere <valor> do limite de crédito da <conta_origem> para o saldo da <conta_destino>.
handle_transferir_credito:
    ## Salvar registradores na pilha
    addi $sp, $sp, -24      # Aloca 24 bytes
    sw $ra, 20($sp)         # Salva $ra
    sw $s0, 16($sp)         # Salva $s0 (ponteiro cliente destino)
    sw $s1, 12($sp)         # Salva $s1 (ponteiro cliente origem)
    sw $s2, 8($sp)          # Salva $s2 (valor)
    sw $s3, 4($sp)          # Salva $s3 (data)
    sw $s4, 0($sp)          # Salva $s4 (hora)

    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros

    ## 1. Parsear CONTA_DESTINO
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos do main)
    jal parse_campo         # Extrai a conta destino
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 2. Parsear CONTA_ORIGEM
    la $a0, buffer_args     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte
    jal parse_campo         # Extrai a conta origem
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 3. Parsear VALOR
    la $a0, buffer_conta_completa # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte
    jal parse_campo         # Extrai o valor (string)

    ## 4. Converter VALOR string para inteiro
    la $a0, buffer_conta_completa # $a0 = valor (string)
    jal atoi                # Converte para inteiro
    move $s2, $v0           # Salva valor (int) em $s2

    ## 5. Buscar CONTA_DESTINO
    la $a0, buffer_temp     # $a0 = conta destino (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, transferir_cred_falha_destino # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro cliente destino em $s0

    ## 6. Buscar CONTA_ORIGEM
    la $a0, buffer_args     # $a0 = conta origem (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, transferir_cred_falha_origem # Se $v0 == 0, pula para o erro
    move $s1, $v0           # Salva ponteiro cliente origem em $s1

    ## 7. Verificar crédito disponível na conta origem
    lw $t0, 76($s1)         # $t0 = Limite de crédito (origem)
    lw $t1, 80($s1)         # $t1 = Crédito usado (origem)
    sub $t2, $t0, $t1       # $t2 = Crédito disponível
    blt $t2, $s2, transferir_cred_falha_limite # Se disponível < valor, erro

    ## 8. Atualizar SALDO da conta destino
    lw $t3, 72($s0)         # $t3 = saldo destino
    add $t3, $t3, $s2       # saldo = saldo + valor
    sw $t3, 72($s0)         # Salva novo saldo destino

    ## 9. Atualizar CREDITO USADO da conta origem
    add $t1, $t1, $s2       # crédito_usado = crédito_usado + valor
    sw $t1, 80($s1)         # Salva novo crédito usado origem

    ## 10. Obter data e hora atuais
    jal obter_data_hora_atual # Obtém data e hora
    move $s3, $v0           # $s3 = Data
    move $s4, $v1           # $s4 = Hora

    ## 11. Registrar transação na conta DESTINO (Tipo 1 = Depósito no débito)
    la $a0, 12($s0)         # $a0 = Conta destino (string)
    move $a1, $s2           # $a1 = Valor (positivo)
    li $a2, 1               # $a2 = Tipo 1 (Depósito)
    move $a3, $s3           # $a3 = Data
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva hora na pilha
    jal registrar_transacao_debito # Chama registro de débito
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 12. Registrar transação na conta ORIGEM (Tipo 5 = Uso Crédito)
    la $a0, 12($s1)         # $a0 = Conta origem (string)
    move $a1, $s2           # $a1 = Valor (positivo, indica uso)
    li $a2, 5               # $a2 = Tipo 5 (Uso Crédito)
    move $a3, $s3           # $a3 = Data
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva hora na pilha
    jal registrar_transacao_credito # Chama registro de crédito
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 13. Mensagem de sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_transferencia_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall

    j transferir_cred_fim   # Pula para o fim

transferir_cred_falha_origem:
    ## Mensagem de erro: Conta origem inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_conta_origem_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j transferir_cred_fim   # Pula para o fim

transferir_cred_falha_destino:
    ## Mensagem de erro: Conta destino inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_conta_destino_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j transferir_cred_fim   # Pula para o fim

transferir_cred_falha_limite:
    ## Mensagem de erro: Limite insuficiente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_limite_insuficiente # Carrega mensagem de erro
    syscall                 # Executa a syscall

transferir_cred_fim:
    ## Restaurar registradores da pilha
    lw $s4, 0($sp)          # Restaura $s4
    lw $s3, 4($sp)          # Restaura $s3
    lw $s2, 8($sp)          # Restaura $s2
    lw $s1, 12($sp)         # Restaura $s1
    lw $s0, 16($sp)         # Restaura $s0
    lw $ra, 20($sp)         # Restaura $ra
    addi $sp, $sp, 24       # Libera 24 bytes
    j cli_loop              # Retorna ao loop principal
    
#### Função para registrar uma transação de crédito
#### Entrada: $a0 = conta (string), $a1 = valor, $a2 = tipo, $a3 = data
####            pilha[0] = hora (argumento extra)
#### Utiliza um buffer circular (sobrescreve antigas se cheio).
registrar_transacao_credito:
    ## Salvar registradores na pilha
    addi $sp, $sp, -28      # Aloca 28 bytes
    sw $ra, 24($sp)         # Salva $ra
    sw $s0, 20($sp)         # Salva $s0 (conta)
    sw $s1, 16($sp)         # Salva $s1 (valor)
    sw $s2, 12($sp)         # Salva $s2 (tipo)
    sw $s3, 8($sp)          # Salva $s3 (data)
    sw $s4, 4($sp)          # Salva $s4 (hora)
    sw $t9, 0($sp)          # Salva $t9

    move $s0, $a0           # $s0 = Conta
    move $s1, $a1           # $s1 = Valor
    move $s2, $a2           # $s2 = Tipo
    move $s3, $a3           # $s3 = Data
    lw $s4, 28($sp)         # $s4 = Hora (carrega da pilha)

    ## Verifica limite (máx. 50 transações)
    la $s5, num_transacoes_credito # Endereço do contador
    lw $t1, 0($s5)          # $t1 = índice atual (próxima posição)
    la $t2, max_transacoes_credito # Endereço do limite
    lw $t2, 0($t2)          # $t2 = limite (50)
    
    ## Se atingiu limite, sobrescreve transações antigas (buffer circular)
    blt $t1, $t2, registrar_credito_normal # Se índice < limite, OK
    li $t1, 0               # Se índice >= limite, reseta para 0 (sobrescreve)

registrar_credito_normal:
    ## Calcula offset (24 bytes por transação)
    li $t3, 24              # Tamanho da transação
    mul $t4, $t1, $t3       # offset = índice * 24
    la $t5, transacoes_credito # Endereço base
    add $t5, $t5, $t4       # $t5 = endereço da transação[índice]

    ## Salva dados da transação
    move $a0, $t5           # $a0 = destino
    move $a1, $s0           # $a1 = fonte (conta)
    jal strcpy              # Copia conta (8 bytes)
    sw $s1, 8($t5)          # Salva Valor (offset 8)
    sw $s2, 12($t5)         # Salva Tipo (offset 12)
    sw $s3, 16($t5)         # Salva Data (offset 16)
    sw $s4, 20($t5)         # Salva Hora (offset 20)

    ## Incrementa contador circularmente
    addi $t1, $t1, 1        # índice = índice + 1
    blt $t1, $t2, salvar_contador_credito # Se índice < limite, OK
    li $t1, 0               # Se índice >= limite, volta ao início (0)

salvar_contador_credito:
    sw $t1, 0($s5)          # Salva o novo índice

fim_registrar_transacao_credito:
    ## Restaurar registradores da pilha
    lw $t9, 0($sp)          # Restaura $t9
    lw $s4, 4($sp)          # Restaura $s4
    lw $s3, 8($sp)          # Restaura $s3
    lw $s2, 12($sp)         # Restaura $s2
    lw $s1, 16($sp)         # Restaura $s1
    lw $s0, 20($sp)         # Restaura $s0
    lw $ra, 24($sp)         # Restaura $ra
    addi $sp, $sp, 28       # Libera 28 bytes
    jr $ra                  # Retorna

# ===== FUNÇÕES DE DATA & HORA =====

#### Handler para o comando 'data_hora'
#### Comando: data_hora-<DDMMAAAA>-<HHMMSS>
#### Configura a data e hora iniciais do sistema.
handle_data_hora:
    ## Salvar registradores na pilha
    addi $sp, $sp, -16      # Aloca 16 bytes
    sw $ra, 12($sp)         # Salva $ra
    sw $s0, 8($sp)          # Salva $s0 (data)
    sw $s1, 4($sp)          # Salva $s1 (hora)
    sw $s2, 0($sp)          # Salva $s2 (argumentos do main)

    ## 1. Parsear DATA (formato DDMMAAAA)
    la $a0, buffer_temp     # $a0 = Destino (string da data)
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s1           # $a2 = Fonte (argumentos do comando)
    jal parse_campo         # Extrai a data (string)
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 2. Parsear HORA (formato HHMMSS)
    la $a0, buffer_args     # $a0 = Destino (string da hora)
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s1           # $a2 = Resto dos argumentos
    jal parse_campo         # Extrai a hora (string)

    ## 3. Converter strings para inteiros
	la $a0, buffer_temp     # $a0 = data (string)
	jal atoi                # Converte para inteiro
	move $s0, $v0           # $s0 = data (int)

	la $a0, buffer_args     # $a0 = hora (string)
	jal atoi                # Converte para inteiro
	move $s1, $v0           # $s1 = hora (int)

	## 4. Validar data
	move $a0, $s0           # $a0 = data (int)
	jal validar_data        # Chama a função de validação
	beqz $v0, data_hora_invalida # Se $v0 == 0, pula para o erro

	## 5. Validar hora
	move $a0, $s1           # $a0 = hora (int)
	jal validar_hora        # Chama a função de validação
	beqz $v0, hora_hora_invalida # Se $v0 == 0, pula para o erro

    ## 6. Salvar data e hora
    la $t0, data_atual      # Endereço da variável global
    sw $s0, 0($t0)          # Salva a data
    la $t0, hora_atual      # Endereço da variável global
    sw $s1, 0($t0)          # Salva a hora

    ## 7. Inicializar tempo_ultimo_incremento com syscall 30
    li $v0, 30              # Syscall 30 (get time in milliseconds)
    syscall                 # Executa a syscall
    la $t0, tempo_ultimo_incremento # Endereço da variável global
    sw $a0, 0($t0)          # Salva o timestamp atual (em ms)

    ## Mensagem de sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_data_hora_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall
    j data_hora_fim         # Pula para o fim

data_hora_invalida:
    ## Mensagem de erro: Data inválida
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_data_invalida # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j data_hora_fim         # Pula para o fim

hora_hora_invalida:
    ## Mensagem de erro: Hora inválida
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_hora_invalida # Carrega mensagem de erro
    syscall                 # Executa a syscall

data_hora_fim:
    ## Restaurar registradores da pilha
    lw $s2, 0($sp)          # Restaura $s2
    lw $s1, 4($sp)          # Restaura $s1
    lw $s0, 8($sp)          # Restaura $s0
    lw $ra, 12($sp)         # Restaura $ra
    addi $sp, $sp, 16       # Libera 16 bytes
    j cli_loop              # Retorna ao loop principal
    
#### Função para validar data (DDMMAAAA)
#### Entrada: $a0 = data como inteiro (DDMMAAAA)
#### Saída: $v0 = 1 se válida, 0 se inválida
validar_data:
    ## Extrair DD, MM, AAAA
    li $t0, 1000000         # Divisor
    div $a0, $t0            # data / 1000000
    mflo $t0                # $t0 = DD (Dia)
    mfhi $t1                # $t1 = MMAAAA
    
    li $t2, 10000           # Divisor
    div $t1, $t2            # MMAAAA / 10000
    mflo $t3                # $t3 = MM (Mês)
    mfhi $t4                # $t4 = AAAA (Ano)

    ## Validar ano (1950-2100)
    blt $t4, 1950, validar_data_falso # Se ano < 1950, falso
    bgt $t4, 2100, validar_data_falso # Se ano > 2100, falso

    ## Validar mês (1-12)
    blt $t3, 1, validar_data_falso # Se mês < 1, falso
    bgt $t3, 12, validar_data_falso # Se mês > 12, falso

    ## Validar dias
    li $t5, 31              # $t5 = Máximo dias padrão (31)
    
    ## Fevereiro
    li $t6, 2               # 2
    beq $t3, $t6, validar_fevereiro # Se mês == 2, pula para validar Fev
    
    ## Abril, Junho, Setembro, Novembro (30 dias)
    li $t6, 4               # 4
    beq $t3, $t6, validar_data_30dias # Se mês == 4, 30 dias
    li $t6, 6               # 6
    beq $t3, $t6, validar_data_30dias # Se mês == 6, 30 dias
    li $t6, 9               # 9
    beq $t3, $t6, validar_data_30dias # Se mês == 9, 30 dias
    li $t6, 11              # 11
    beq $t3, $t6, validar_data_30dias # Se mês == 11, 30 dias
    
    j validar_data_dia      # Outros meses (Jan, Mar, Mai, Jul, Ago, Out, Dez) usam 31 dias

validar_fevereiro:
    ## Verificar ano bissexto
    li $t7, 4               # 4
    div $t4, $t7            # ano / 4
    mfhi $t8                # $t8 = resto
    bnez $t8, validar_fevereiro_nao_bissexto # Se resto != 0, não é bissexto
    li $t5, 29              # É bissexto, $t5 = 29 dias
    j validar_data_dia      # Pula para validar o dia

validar_fevereiro_nao_bissexto:
    li $t5, 28              # Não é bissexto, $t5 = 28 dias
    j validar_data_dia      # Pula para validar o dia

validar_data_30dias:
    li $t5, 30              # $t5 = 30 dias

validar_data_dia:
    ## Validação final do dia
    blt $t0, 1, validar_data_falso # Se dia < 1, falso
    bgt $t0, $t5, validar_data_falso # Se dia > max_dias ($t5), falso

validar_data_verdadeiro:
    li $v0, 1               # $v0 = 1 (Verdadeiro)
    jr $ra                  # Retorna

validar_data_falso:
    li $v0, 0               # $v0 = 0 (Falso)
    jr $ra                  # Retorna

#### Função para validar hora (HHMMSS)
#### Entrada: $a0 = hora como inteiro (HHMMSS)
#### Saída: $v0 = 1 se válida, 0 se inválida
validar_hora:
    ## Extrair HH, MM, SS
    li $t0, 10000           # Divisor
    div $a0, $t0            # hora / 10000
    mflo $t1                # $t1 = HH (Horas)
    mfhi $t2                # $t2 = MMSS
    
    li $t3, 100             # Divisor
    div $t2, $t3            # MMSS / 100
    mflo $t4                # $t4 = MM (Minutos)
    mfhi $t5                # $t5 = SS (Segundos)

    ## Validar HH (0-23)
    blt $t1, 0, validar_hora_falso # Se HH < 0, falso
    bgt $t1, 23, validar_hora_falso # Se HH > 23, falso
    
    ## Validar MM (0-59)
    blt $t4, 0, validar_hora_falso # Se MM < 0, falso
    bgt $t4, 59, validar_hora_falso # Se MM > 59, falso

    ## Validar SS (0-59)
    blt $t5, 0, validar_hora_falso # Se SS < 0, falso
    bgt $t5, 59, validar_hora_falso # Se SS > 59, falso

    li $v0, 1               # $v0 = 1 (Verdadeiro)
    jr $ra                  # Retorna

validar_hora_falso:
    li $v0, 0               # $v0 = 0 (Falso)
    jr $ra                  # Retorna

#### Função para obter data e hora atuais, incrementando o tempo
#### Incrementa o tempo global (data_atual, hora_atual)
#### com base nos milissegundos reais decorridos (syscall 30).
#### Saída: $v0 = data, $v1 = hora
obter_data_hora_atual:
    ## Salvar registradores na pilha
    addi $sp, $sp, -28      # Aloca 28 bytes
    sw $ra, 24($sp)         # Salva $ra
    sw $s0, 20($sp)         # Salva $s0 (tempo_ultimo)
    sw $s1, 16($sp)         # Salva $s1 (ms decorridos)
    sw $s2, 12($sp)         # Salva $s2 (segundos decorridos)
    sw $s3, 8($sp)          # Salva $s3 (hora int)
    sw $s4, 4($sp)          # Salva $s4 (HH)
    sw $s5, 0($sp)          # Salva $s5 (MM)

    ## Carregar tempo_ultimo_incremento
    la $t0, tempo_ultimo_incremento # Endereço da variável global
    lw $s0, 0($t0)          # $s0 = tempo (ms) da última atualização

    ## Se tempo_ultimo_incremento for 0, data/hora não foi configurada
    beqz $s0, data_hora_nao_configurada_v2 # Se == 0, pula

    ## Obter tempo atual
    li $v0, 30              # Syscall 30 (get time in milliseconds)
    syscall                 # Executa a syscall
    move $t1, $a0           # $t1 = tempo atual em ms

    ## Calcular diferença em milissegundos
    sub $s1, $t1, $s0       # $s1 = ms decorridos (atual - ultimo)

    ## Se diferença < 1000ms (1 segundo), não atualiza
    li $t2, 1000            # 1000 ms
    blt $s1, $t2, obter_data_hora_fim_v2 # Se decorridos < 1000, fim

    ## Atualizar tempo_ultimo_incremento
    sw $t1, 0($t0)          # Salva o tempo atual como o último

    ## Calcular quantos segundos se passaram
    div $s1, $t2            # ms_decorridos / 1000
    mflo $s2                # $s2 = segundos inteiros decorridos
    
    ## Se nenhum segundo completo passou, não atualiza
    beqz $s2, obter_data_hora_fim_v2 # Se == 0, fim

    ## Carregar hora atual
    la $t0, hora_atual      # Endereço da variável global
    lw $s3, 0($t0)          # $s3 = HHMMSS

    ## Extrair componentes da hora
    li $t3, 10000           # Divisor
    div $s3, $t3            # HHMMSS / 10000
    mflo $s4                # $s4 = HH (horas)
    mfhi $t4                # $t4 = MMSS

    li $t3, 100             # Divisor
    div $t4, $t3            # MMSS / 100
    mflo $s5                # $s5 = MM (minutos)
    mfhi $t5                # $t5 = SS (segundos)

    ## Adicionar segundos decorridos
    add $t5, $t5, $s2       # SS = SS + segundos_decorridos

    ## Propagar "carry" (vai-um) para minutos
incrementar_minutos_v2:
    li $t6, 60              # 60
    blt $t5, $t6, incrementar_horas_v2 # Se SS < 60, pula
    
    sub $t5, $t5, $t6       # SS = SS - 60
    addi $s5, $s5, 1        # MM = MM + 1
    j incrementar_minutos_v2 # Loop (caso tenha passado > 120 seg)

incrementar_horas_v2:
    ## Propagar "carry" para horas
    li $t6, 60              # 60
    blt $s5, $t6, incrementar_dias_v2 # Se MM < 60, pula
    
    sub $s5, $s5, $t6       # MM = MM - 60
    addi $s4, $s4, 1        # HH = HH + 1
    j incrementar_horas_v2  # Loop

incrementar_dias_v2:
    ## Propagar "carry" para dias
    li $t6, 24              # 24
    blt $s4, $t6, salvar_hora_v2 # Se HH < 24, pula
    
    ## Passou da meia-noite - incrementar dia
    sub $s4, $s4, $t6       # HH = HH - 24
    
    ## Incrementar data
    la $t0, data_atual      # Endereço da variável global
    lw $t7, 0($t0)          # Carrega data (DDMMAAAA)
    move $a0, $t7           # $a0 = data
    jal incrementar_data    # Chama função auxiliar
    sw $v0, 0($t0)          # Salva a nova data (retornada em $v0)
    
    j incrementar_dias_v2   # Loop (caso tenha passado > 48h)

salvar_hora_v2:
    ## Reconstruir hora no formato HHMMSS
    li $t3, 100             # 100
    mul $t4, $s4, $t3       # HH * 100
    add $t4, $t4, $s5       # HHMM
    mul $t4, $t4, $t3       # HHMM * 100
    add $t4, $t4, $t5       # HHMMSS
    
    la $t0, hora_atual      # Endereço da variável global
    sw $t4, 0($t0)          # Salva a nova hora

obter_data_hora_fim_v2:
    ## Retornar data e hora (agora atualizadas)
    la $t0, data_atual      # Endereço da variável global
    lw $v0, 0($t0)          # $v0 = data
    la $t0, hora_atual      # Endereço da variável global
    lw $v1, 0($t0)          # $v1 = hora

    ## Restaurar registradores da pilha
    lw $s5, 0($sp)          # Restaura $s5
    lw $s4, 4($sp)          # Restaura $s4
    lw $s3, 8($sp)          # Restaura $s3
    lw $s2, 12($sp)         # Restaura $s2
    lw $s1, 16($sp)         # Restaura $s1
    lw $s0, 20($sp)         # Restaura $s0
    lw $ra, 24($sp)         # Restaura $ra
    addi $sp, $sp, 28       # Libera 28 bytes
    jr $ra                  # Retorna

data_hora_nao_configurada_v2:
    ## Retorna 0 se data/hora não foram configuradas
    li $v0, 0               # $v0 = 0
    li $v1, 0               # $v1 = 0
    j obter_data_hora_fim_v2 # Pula para o fim (restaurar pilha e retornar)

#### Função Auxiliar: Incrementar Data
#### Entrada: $a0 = data no formato DDMMAAAA
#### Saída: $v0 = data incrementada (próximo dia)
incrementar_data:
    ## Salvar registradores na pilha
    addi $sp, $sp, -16      # Aloca 16 bytes
    sw $ra, 12($sp)         # Salva $ra
    sw $t7, 8($sp)          # Salva $t7 (dia)
    sw $t8, 4($sp)          # Salva $t8 (mês)
    sw $t9, 0($sp)          # Salva $t9 (ano)

    ## Extrair componentes (DDMMAAAA)
    li $t0, 1000000         # Divisor
    div $a0, $t0            # data / 1000000
    mflo $t7                # $t7 = Dia
    mfhi $t1                # $t1 = MMAAAA

    li $t0, 10000           # Divisor
    div $t1, $t0            # MMAAAA / 10000
    mflo $t8                # $t8 = Mês
    mfhi $t9                # $t9 = Ano

    ## Incrementar dia
    addi $t7, $t7, 1        # dia = dia + 1

    ## Verificar limites do mês
    move $a0, $t8           # $a0 = mês
    move $a1, $t9           # $a1 = ano
    jal obter_dias_mes      # Chama função auxiliar
    move $t3, $v0           # $t3 = dias_no_mes

    ## Se dia <= dias_do_mês, OK
    ble $t7, $t3, reconstruir_data # Se dia <= limite, pula

    ## Passou do último dia - ir para próximo mês
    li $t7, 1               # dia = 1
    addi $t8, $t8, 1        # mês = mês + 1

    ## Se mês > 12, ir para próximo ano
    li $t4, 12              # 12
    ble $t8, $t4, reconstruir_data # Se mês <= 12, pula

    li $t8, 1               # mês = 1
    addi $t9, $t9, 1        # ano = ano + 1

reconstruir_data:
    ## Reconstruir data: DDMMAAAA
    li $t0, 10000           # 10000
    mul $v0, $t8, $t0       # Mês * 10000
    add $v0, $v0, $t9       # MMAAAA
    li $t0, 1000000         # 1000000
    mul $t1, $t7, $t0       # Dia * 1000000
    add $v0, $t1, $v0       # DDMMAAAA

    ## Restaurar registradores da pilha
    lw $t9, 0($sp)          # Restaura $t9
    lw $t8, 4($sp)          # Restaura $t8
    lw $t7, 8($sp)          # Restaura $t7
    lw $ra, 12($sp)         # Restaura $ra
    addi $sp, $sp, 16       # Libera 16 bytes
    jr $ra                  # Retorna

#### Função Auxiliar: Obter Dias do Mês
#### Entrada: $a0 = mês (1-12), $a1 = ano
#### Saída: $v0 = número de dias do mês
obter_dias_mes:
    ## Meses com 31 dias: 1, 3, 5, 7, 8, 10, 12
    beq $a0, 1, dias_31     # Jan
    beq $a0, 3, dias_31     # Mar
    beq $a0, 5, dias_31     # Mai
    beq $a0, 7, dias_31     # Jul
    beq $a0, 8, dias_31     # Ago
    beq $a0, 10, dias_31    # Out
    beq $a0, 12, dias_31    # Dez

    ## Fevereiro (mês 2)
    beq $a0, 2, verificar_bissexto # Se mês == 2, pula

    ## Demais meses têm 30 dias (Abr, Jun, Set, Nov)
    li $v0, 30              # $v0 = 30
    jr $ra                  # Retorna

dias_31:
    li $v0, 31              # $v0 = 31
    jr $ra                  # Retorna

verificar_bissexto:
    ## Ano bissexto: divisível por 4
    li $t0, 4               # 4
    div $a1, $t0            # ano / 4
    mfhi $t1                # $t1 = resto
    bnez $t1, fev_28        # Se resto != 0, não é bissexto
    
    ## (Simplificação: não verifica /100 e /400)
fev_29:
    li $v0, 29              # $v0 = 29
    jr $ra                  # Retorna

fev_28:
    li $v0, 28              # $v0 = 28
    jr $ra                  # Retorna

#### Handler para o comando 'conta_format'
#### Comando: conta_format-<conta>
#### Apaga todas as transações de DÉBITO de uma conta específica.
handle_conta_format:
    ## Salvar registradores na pilha
    addi $sp, $sp, -16      # Aloca 16 bytes
    sw $ra, 12($sp)         # Salva $ra
    sw $s0, 8($sp)          # Salva $s0 (ponteiro do cliente)
    sw $s1, 4($sp)          # Salva $s1 (argumentos do main)
    sw $s2, 0($sp)          # Salva $s2

    ## 1. Parsear conta (único argumento)
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos do main)
    jal parse_campo         # Extrai a conta
    move $s1, $v0           # Atualiza $s1 (não usado mais)

    ## 2. Buscar cliente pela conta
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, format_conta_invalida # Se $v0 == 0, pula para o erro
    
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 3. Solicitar confirmação
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_confirmar_formatacao # Carrega "ATENCAO... (S/N)? "
    syscall                 # Executa a syscall

    ## Ler resposta do usuário
    li $v0, 8               # Syscall 8 (read_string)
    la $a0, buffer_confirmar_opcao # Buffer de destino
    li $a1, 4               # Tamanho máximo
    syscall                 # Executa a syscall

    ## Limpar newline da resposta
    la $a0, buffer_confirmar_opcao # $a0 = buffer
    jal limpar_newline_comando # Chama a limpeza

    ## Verificar se confirmou (S ou s)
    la $t0, buffer_confirmar_opcao # Endereço do buffer
    lb $t0, 0($t0)          # $t0 = primeiro caractere
    beq $t0, 'S', format_confirmado # Se 'S', pula
    beq $t0, 's', format_confirmado # Se 's', pula
    
    ## Não confirmado
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_formatacao_cancelada # Carrega "Operacao cancelada."
    syscall                 # Executa a syscall
    j format_fim            # Pula para o fim

format_confirmado:
    ## 4. Formatar transações de débito
    la $a0, 12($s0)         # $a0 = ponteiro para string da conta (offset 12)
    jal limpar_transacoes_debito_cliente # Chama a função de limpeza

    ## 5. Mensagem de sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_formatacao_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall
    j format_fim            # Pula para o fim

format_conta_invalida:
    ## Mensagem de erro: Conta inválida
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_conta_invalida # Carrega mensagem de erro
    syscall                 # Executa a syscall

format_fim:
    ## Restaurar registradores da pilha
    lw $s2, 0($sp)          # Restaura $s2
    lw $s1, 4($sp)          # Restaura $s1
    lw $s0, 8($sp)          # Restaura $s0
    lw $ra, 12($sp)         # Restaura $ra
    addi $sp, $sp, 16       # Libera 16 bytes
    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'conta_cadastrar'
#### Comando: conta_cadastrar-<cpf>-<conta>-<nome>
#### Cadastra um novo cliente no sistema.
handle_conta_cadastrar:
    ## $s1 já contém o ponteiro para os argumentos

    ## 1. Parsear CPF (arg1)
    la $a0, buffer_cpf      # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos)
    jal parse_campo         # Extrai o CPF
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 2. Parsear Conta (arg2)
    la $a0, buffer_conta    # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte
    jal parse_campo         # Extrai a Conta (sem DV)
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 3. Parsear Nome (arg3 - é o resto da string)
    la $a0, buffer_nome     # $a0 = destino
    move $a1, $s1           # $a1 = fonte (resto da string)
    jal strcpy              # Copia o resto (Nome)

    ## 4. Executar a lógica de cadastro
    jal logica_cadastro_cliente # Chama a função principal de cadastro

    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'conta_buscar'
#### Comando: conta_buscar-<conta>
#### Busca e exibe os detalhes de um cliente.
handle_conta_buscar:
    ## Salvar registradores na pilha
    addi $sp, $sp, -8       # Aloca 8 bytes
    sw $ra, 0($sp)          # Salva $ra
    sw $s0, 4($sp)          # Salva $s0 (ponteiro do cliente)

    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros

    ## 1. Copiar o argumento (conta) para um buffer temporário
    la $a0, buffer_temp     # $a0 = Destino
    move $a1, $s1           # $a1 = Fonte (argumentos do main)
    jal strcpy              # Copia a string da conta (ex: "123456-X")

    ## 2. Buscar cliente usando a conta no buffer_temp
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    # Retorna ponteiro em $v0, ou 0 se não encontrado

    ## 3. Verificar se cliente foi encontrado
    beqz $v0, buscar_conta_nao_encontrado # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 4. Imprimir detalhes do cliente encontrado
    ## CPF
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_cpf     # Carrega "CPF: "
    syscall                 # Executa a syscall
    la $a0, 0($s0)          # $a0 = ponteiro para CPF (offset 0)
    syscall                 # Imprime o CPF

    ## Conta Formatada (XXXXXX-X)
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_conta   # Carrega "Conta: "
    syscall                 # Executa a syscall
    la $t0, 12($s0)         # $t0 = ponteiro para Conta Completa (offset 12)
    li $t1, 0               # $t1 = contador
    loop_exibir_conta_busca:
        bge $t1, 6, exibir_hifen_conta_busca # Se i >= 6, imprime hífen
        lb $a0, 0($t0)      # $a0 = caractere
        li $v0, 11          # Syscall 11 (print_char)
        syscall             # Imprime o caractere
        addi $t0, $t0, 1    # Avança ponteiro
        addi $t1, $t1, 1    # i++
        j loop_exibir_conta_busca # Volta ao loop
    exibir_hifen_conta_busca:
        li $v0, 4           # Syscall 4 (print_string)
        la $a0, hifen       # Carrega "-"
        syscall             # Imprime "-"
        lb $a0, 0($t0)      # $a0 = 7º caractere (DV)
        li $v0, 11          # Syscall 11 (print_char)
        syscall             # Imprime o DV

    ## Nome
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_nome    # Carrega "Nome: "
    syscall                 # Executa a syscall
    la $a0, 20($s0)         # $a0 = ponteiro para Nome (offset 20)
    syscall                 # Imprime o Nome

    ## Saldo
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_saldo   # Carrega "Saldo: "
    syscall                 # Executa a syscall
    lw $a0, 72($s0)         # $a0 = Saldo (offset 72)
    jal print_moeda         # Imprime o valor formatado

    ## Limite de Crédito
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_limite  # Carrega "Limite de Credito: "
    syscall                 # Executa a syscall
    lw $a0, 76($s0)         # $a0 = Limite (offset 76)
    jal print_moeda         # Imprime o valor formatado

    ## Crédito Usado
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_str_credito_usado # Carrega "Credito Usado: "
    syscall                 # Executa a syscall
    lw $a0, 80($s0)         # $a0 = Credito Usado (offset 80)
    jal print_moeda         # Imprime o valor formatado

    ## Imprime um newline extra no final da consulta
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Carrega "\n"
    syscall                 # Executa a syscall

    j fim_handle_conta_buscar # Pula a mensagem de erro

buscar_conta_nao_encontrado:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall

fim_handle_conta_buscar:
    ## Restaurar registradores da pilha
    lw $s0, 4($sp)          # Restaura $s0
    lw $ra, 0($sp)          # Restaura $ra
    addi $sp, $sp, 8        # Libera 8 bytes
    j cli_loop              # Retorna ao loop principal

#### Handler para comandos em construção (placeholder)
handle_em_construcao:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_em_construcao # Carrega "Em construcao..."
    syscall                 # Executa a syscall
    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'encerrar'
handle_encerrar:
    ## Restaura $s1 (embora não seja estritamente necessário antes de sair)
    lw $s1, 0($sp)          # Restaura $s1
    addi $sp, $sp, 4        # Libera 4 bytes
    jal encerrar_programa   # Chama a função de encerramento
    # Não volta

#### Função para encerrar o programa
encerrar_programa:
    ## Imprime mensagem de despedida
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, goodbye         # Carrega "Encerrando o programa..."
    syscall                 # Executa a syscall

    ## Encerra o programa
    li $v0, 10              # Syscall 10 (exit)
    syscall                 # Executa a syscall
    
# ===== FUNÇÕES DE TRANSAÇÃO (DÉBITO) =====

#### Função para limpar transações de débito de um cliente
#### Entrada: $a0 = ponteiro para a string da conta do cliente
#### Remove todas as transações de débito desta conta (algoritmo de "gap compacting").
limpar_transacoes_debito_cliente:
    ## Salvar registradores na pilha
    addi $sp, $sp, -24      # Aloca 24 bytes
    sw $ra, 20($sp)         # Salva $ra
    sw $s0, 16($sp)         # Salva $s0 (conta)
    sw $s1, 12($sp)         # Salva $s1 (índice leitor)
    sw $s2, 8($sp)          # Salva $s2 (índice escritor)
    sw $s3, 4($sp)          # Salva $s3 (contador removidos)
    sw $s4, 0($sp)          # Salva $s4 (ponteiro num_transacoes)

    move $s0, $a0           # $s0 = conta do cliente
    li $s1, 0               # $s1 = índice leitor
    li $s2, 0               # $s2 = índice escritor
    li $s3, 0               # $s3 = contador de removidos
    
    la $s4, num_transacoes_debito # $s4 = endereço do contador
    lw $t4, 0($s4)          # $t4 = total de transações

limpar_deb_loop:
    ## Loop principal
    bge $s1, $t4, limpar_deb_fim # Se leitor >= total, fim

    ## Calcular offset da transação de leitura (24 bytes por transação)
    li $t1, 24              # Tamanho da transação
    mul $t5, $s1, $t1       # offset = leitor * 24
    la $t6, transacoes_debito # Endereço base
    add $t6, $t6, $t5       # Endereço da transação[leitor]

    ## Comparar conta
    move $a0, $s0           # $a0 = conta do cliente
    move $a1, $t6           # $a1 = conta da transação[leitor]
    jal strcmp              # Compara as strings

    beqz $v0, limpar_deb_encontrada # Se $v0 == 0 (iguais), é para remover

    ## Diferente: copiar transação da posição [leitor] para [escritor]
    mul $t5, $s2, $t1       # offset = escritor * 24
    la $t7, transacoes_debito # Endereço base
    add $t7, $t7, $t5       # Endereço da transação[escritor]

    ## Copiar 24 bytes
    li $t8, 0               # Contador de bytes
limpar_deb_copiar:
    lb $t9, 0($t6)          # Carrega byte da [leitor]
    sb $t9, 0($t7)          # Salva byte na [escritor]
    addi $t6, $t6, 1        # Avança ponteiro [leitor]
    addi $t7, $t7, 1        # Avança ponteiro [escritor]
    addi $t8, $t8, 1        # Incrementa contador de bytes
    blt $t8, 24, limpar_deb_copiar # Loop até 24 bytes

    addi $s2, $s2, 1        # Incrementa índice escritor
    j limpar_deb_proxima    # Pula para próxima iteração

limpar_deb_encontrada:
    ## Transação encontrada, incrementar contador de removidos
    addi $s3, $s3, 1        # Apenas "pula" esta transação

limpar_deb_proxima:
    addi $s1, $s1, 1        # Incrementa índice leitor
    j limpar_deb_loop       # Volta ao loop

limpar_deb_fim:
    ## Atualizar contador
    sub $t4, $t4, $s3       # novo_total = total_antigo - removidos
    sw $t4, 0($s4)          # Salva o novo total

    ## Restaurar registradores da pilha
    lw $s4, 0($sp)          # Restaura $s4
    lw $s3, 4($sp)          # Restaura $s3
    lw $s2, 8($sp)          # Restaura $s2
    lw $s1, 12($sp)         # Restaura $s1
    lw $s0, 16($sp)         # Restaura $s0
    lw $ra, 20($sp)         # Restaura $ra
    addi $sp, $sp, 24       # Libera 24 bytes
    jr $ra                  # Retorna

#### Função para registrar uma transação de débito
#### Entrada: $a0 = conta (string), $a1 = valor, $a2 = tipo, $a3 = data
####            pilha[0] = hora (argumento extra)
#### Adiciona uma nova transação ao final do array (se houver espaço).
registrar_transacao_debito:
    ## Salvar registradores na pilha
    addi $sp, $sp, -28      # Aloca 28 bytes
    sw $ra, 24($sp)         # Salva $ra
    sw $s0, 20($sp)         # Salva $s0 (conta)
    sw $s1, 16($sp)         # Salva $s1 (valor)
    sw $s2, 12($sp)         # Salva $s2 (tipo)
    sw $s3, 8($sp)          # Salva $s3 (data)
    sw $s4, 4($sp)          # Salva $s4 (hora)
    sw $t9, 0($sp)          # Salva $t9

    move $s0, $a0           # $s0 = Conta
    move $s1, $a1           # $s1 = Valor
    move $s2, $a2           # $s2 = Tipo
    move $s3, $a3           # $s3 = Data
    lw $s4, 28($sp)         # $s4 = Hora (carrega da pilha)

    ## Verifica limite
    la $s5, num_transacoes_debito # Endereço do contador
    lw $t1, 0($s5)          # $t1 = total atual
    la $t2, max_transacoes_debito # Endereço do limite
    lw $t2, 0($t2)          # $t2 = limite
    bge $t1, $t2, fim_registrar_transacao # Se total >= limite, fim (não registra)

    ## Calcula offset (24 bytes por transacao)
    li $t3, 24              # Tamanho da transação
    mul $t4, $t1, $t3       # offset = total * 24
    la $t5, transacoes_debito # Endereço base
    add $t5, $t5, $t4       # $t5 = endereço da transação[total]

    ## Salva dados
    move $a0, $t5           # $a0 = destino
    move $a1, $s0           # $a1 = fonte (conta)
    jal strcpy              # Copia conta (8 bytes)
    sw $s1, 8($t5)          # Salva Valor (offset 8)
    sw $s2, 12($t5)         # Salva Tipo (offset 12)
    sw $s3, 16($t5)         # Salva Data (offset 16)
    sw $s4, 20($t5)         # Salva Hora (offset 20)

    ## Incrementa contador
    addi $t1, $t1, 1        # total = total + 1
    sw $t1, 0($s5)          # Salva o novo total

fim_registrar_transacao:
    ## Restaurar registradores da pilha
    lw $t9, 0($sp)          # Restaura $t9
    lw $s4, 4($sp)          # Restaura $s4
    lw $s3, 8($sp)          # Restaura $s3
    lw $s2, 12($sp)         # Restaura $s2
    lw $s1, 16($sp)         # Restaura $s1
    lw $s0, 20($sp)         # Restaura $s0
    lw $ra, 24($sp)         # Restaura $ra
    addi $sp, $sp, 28       # Libera 28 bytes
    jr $ra                  # Retorna

#### Handler para o comando 'depositar'
#### Comando: depositar-<conta>-<valor>
#### Adiciona <valor> ao saldo da <conta>.
handle_depositar:
    ## Salvar registradores na pilha
    addi $sp, $sp, -20      # Aloca 20 bytes
    sw $ra, 16($sp)         # Salva $ra
    sw $s0, 12($sp)         # Salva $s0 (ponteiro cliente)
    sw $s1, 8($sp)          # Salva $s1 (valor)
    sw $s2, 4($sp)          # Salva $s2 (argumentos do main)
    sw $s3, 0($sp)	        # Salva $s3 (data)
   
    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros

    ## Preserva o ponteiro dos argumentos
    move $s2, $s1           # Copia $s1 (argumentos) para $s2

    ## 1. Extrair a CONTA
    la $a0, buffer_temp     # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s2           # $a2 = Fonte (usando $s2)
    jal parse_campo         # Extrai a conta
    move $s2, $v0           # Atualiza $s2 com ponteiro para "VALOR"

    ## 2. Extrair o VALOR
    la $a0, buffer_args     # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s2           # $a2 = Fonte (usando $s2)
    jal parse_campo         # Extrai o valor (string)

    ## 3. Buscar o cliente
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente

    ## 4. Verificar se encontrou
    beqz $v0, depositar_falha_cliente # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 5. Converter VALOR para inteiro
    la $a0, buffer_args     # $a0 = valor (string)
    jal atoi                # Converte para inteiro
    move $s1, $v0           # Salva valor (int) em $s1

    ## 6. Atualizar Saldo
    lw $t0, 72($s0)         # $t0 = saldo atual (offset 72)
    add $t0, $t0, $s1       # saldo = saldo + valor
    sw $t0, 72($s0)         # Salva novo saldo

    ## 7. Obter data e hora atuais
    jal obter_data_hora_atual # Obtém data e hora
    move $s3, $v0           # $s3 = Data
    move $s4, $v1           # $s4 = Hora (em $s4 temporário)

    ## 8. Registrar transação de débito (Tipo 1 = Depósito)
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva hora na pilha

    la $a0, 12($s0)         # $a0 = Conta (string)
    move $a1, $s1           # $a1 = Valor (positivo)
    li $a2, 1               # $a2 = Tipo 1 (Depósito)
    move $a3, $s3           # $a3 = Data
    jal registrar_transacao_debito # Chama a função de registro
    
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 9. Imprimir Sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_deposito_sucesso # Carrega "Deposito realizado com sucesso..."
    syscall                 # Executa a syscall

    ## 10. Imprimir Saldo
    lw $a0, 72($s0)         # $a0 = novo saldo
    jal print_moeda         # Imprime o valor formatado

    j depositar_fim         # Pula para o fim

depositar_falha_cliente:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall

depositar_fim: 
    ## Restaurar registradores da pilha
    lw $s3, 0($sp)          # Restaura $s3
    lw $s2, 4($sp)          # Restaura $s2
    lw $s1, 8($sp)          # Restaura $s1
    lw $s0, 12($sp)         # Restaura $s0
    lw $ra, 16($sp)         # Restaura $ra
    addi $sp, $sp, 20       # Libera 20 bytes

    j cli_loop              # Retorna ao loop principal
    
#### Handler para o comando 'sacar'
#### Comando: sacar-<conta>-<valor>
#### Subtrai <valor> do saldo da <conta>.
handle_sacar:
    ## Salvar registradores na pilha
    addi $sp, $sp, -20      # Aloca 20 bytes
    sw $ra, 16($sp)         # Salva $ra
    sw $s0, 12($sp)         # Salva $s0 (ponteiro cliente)
    sw $s1, 8($sp)          # Salva $s1 (valor)
    sw $s2, 4($sp)          # Salva $s2 (argumentos do main)
    sw $s3, 0($sp)          # Salva $s3 (data)
    
    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros
    
    ## Preserva o ponteiro dos argumentos
    move $s2, $s1           # Copia $s1 (argumentos) para $s2

    ## 1. PARSEAR A CONTA
    la $a0, buffer_temp     # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s2           # $a2 = Fonte (usando $s2)
    jal parse_campo         # Extrai a conta
    move $s2, $v0           # Atualiza $s2 com ponteiro para "VALOR"
    
    ## 2. PARSEAR O VALOR
    la $a0, buffer_args     # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s2           # $a2 = Fonte (usando $s2)
    jal parse_campo         # Extrai o valor (string)
    
    ## 3. BUSCAR O CLIENTE
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    
    ## 4. VERIFICAR SE CLIENTE FOI ENCONTRADO
    beqz $v0, sacar_falha_cliente # Se $v0 == 0, pula para o erro
    
    move $s0, $v0           # Salva ponteiro do cliente em $s0
    
    ## 5. CONVERTER STRING DO VALOR PARA INTEIRO
    la $a0, buffer_args     # $a0 = valor (string)
    jal atoi                # Converte para inteiro
    move $s1, $v0           # Salva valor (int) em $s1
    
    ## 6. VERIFICAR SALDO SUFICIENTE
    lw $t0, 72($s0)         # $t0 = saldo atual (offset 72)
    blt $t0, $s1, sacar_falha_saldo_insuficiente # Se saldo < valor, erro

    ## 7. ATUALIZAR SALDO DO CLIENTE
    sub $t0, $t0, $s1       # saldo = saldo - valor
    sw $t0, 72($s0)         # Salva novo saldo

    ## 8. Obter data e hora atuais
    jal obter_data_hora_atual # Obtém data e hora
    move $s3, $v0           # $s3 = Data
    move $s4, $v1           # $s4 = Hora (em $s4 temporário)

    ## 9. Registrar transação de débito (Tipo 2 = Saque)
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva hora na pilha

    la $a0, 12($s0)         # $a0 = Conta (string)
    sub $a1, $zero, $s1     # $a1 = Valor (negativo)
    li $a2, 2               # $a2 = Tipo 2 (Saque)
    move $a3, $s3           # $a3 = Data
    jal registrar_transacao_debito # Chama a função de registro
    
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 10. IMPRIMIR MENSAGEM DE SUCESSO
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_saque_sucesso # Carrega "Saque realizado com sucesso\n"
    syscall                 # Executa a syscall

    j sacar_fim             # Pula para o fim

sacar_falha_cliente:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j sacar_fim             # Pula para o fim

sacar_falha_saldo_insuficiente:
    ## Mensagem de erro: Saldo insuficiente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_saldo_insuficiente # Carrega mensagem de erro
    syscall                 # Executa a syscall

sacar_fim:
    ## Restaurar registradores da pilha
    lw $s3, 0($sp)          # Restaura $s3
    lw $s2, 4($sp)          # Restaura $s2
    lw $s1, 8($sp)          # Restaura $s1
    lw $s0, 12($sp)         # Restaura $s0
    lw $ra, 16($sp)         # Restaura $ra
    addi $sp, $sp, 20       # Libera 20 bytes
    j cli_loop              # Retorna ao loop principal
    
#### Handler para o comando 'transferir_debito'
#### Comando: transferir_debito-<conta_origem>-<conta_destino>-<valor>
#### Transfere <valor> do saldo da <conta_origem> para o saldo da <conta_destino>.
handle_transferir_debito:
    ## Salvar registradores na pilha
    addi $sp, $sp, -24      # Aloca 24 bytes
    sw $ra, 20($sp)         # Salva $ra
    sw $s0, 16($sp)         # Salva $s0 (ponteiro cliente origem)
    sw $s1, 12($sp)         # Salva $s1 (ponteiro cliente destino)
    sw $s2, 8($sp)          # Salva $s2 (valor)
    sw $s3, 4($sp)          # Salva $s3 (data)
    sw $s4, 0($sp)          # Salva $s4 (hora)

    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros

    ## 1. Parsear CONTA_ORIGEM
    la $a0, buffer_temp     # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s1           # $a2 = Fonte (argumentos do main)
    jal parse_campo         # Extrai a conta origem
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 2. Parsear CONTA_DESTINO
    la $a0, buffer_args     # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s1           # $a2 = Fonte
    jal parse_campo         # Extrai a conta destino
    move $s1, $v0           # Atualiza $s1 para o resto dos argumentos

    ## 3. Parsear VALOR
    la $a0, buffer_conta_completa # $a0 = Destino
    li $a1, '-'             # $a1 = Delimitador
    move $a2, $s1           # $a2 = Fonte
    jal parse_campo         # Extrai o valor (string)

    ## 4. Converter VALOR para inteiro
    la $a0, buffer_conta_completa # $a0 = valor (string)
    jal atoi                # Converte para inteiro
    move $s2, $v0           # Salva valor (int) em $s2

    ## 5. Buscar cliente ORIGEM
    la $a0, buffer_temp     # $a0 = conta origem (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, transferir_falha_origem # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro cliente origem em $s0

    ## 6. Buscar cliente DESTINO
    la $a0, buffer_args     # $a0 = conta destino (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, transferir_falha_destino # Se $v0 == 0, pula para o erro
    move $s1, $v0           # Salva ponteiro cliente destino em $s1

    ## 7. Verificar saldo da origem
    lw $t0, 72($s0)         # $t0 = saldo origem (offset 72)
    blt $t0, $s2, transferir_falha_saldo # Se saldo < valor, erro

    ## Saldo OK, continuar
    sub $t0, $t0, $s2       # saldo_origem = saldo_origem - valor
    sw $t0, 72($s0)         # Salva novo saldo origem

    ## 8. Atualizar saldo destino
    lw $t1, 72($s1)         # $t1 = saldo destino
    add $t1, $t1, $s2       # saldo_destino = saldo_destino + valor
    sw $t1, 72($s1)         # Salva novo saldo destino

    ## 9. Obter data e hora atuais
    jal obter_data_hora_atual # Obtém data e hora
    move $s3, $v0           # $s3 = Data
    move $s4, $v1           # $s4 = Hora

    ## 10. Registrar SAIDA (Origem, Tipo 3 = Transferência)
    la $a0, 12($s0)         # $a0 = Conta origem (string)
    sub $a1, $zero, $s2     # $a1 = Valor (negativo)
    li $a2, 3               # $a2 = Tipo 3 (Transferência)
    move $a3, $s3           # $a3 = Data
    
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva hora na pilha
    jal registrar_transacao_debito # Chama a função de registro
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 11. Registrar ENTRADA (Destino, Tipo 1 = Depósito)
    la $a0, 12($s1)         # $a0 = Conta destino (string)
    move $a1, $s2           # $a1 = Valor (positivo)
    li $a2, 1               # $a2 = Tipo 1 (Depósito)
    move $a3, $s3           # $a3 = Data
    
    addi $sp, $sp, -4       # Aloca espaço na pilha para a hora
    sw $s4, 0($sp)          # Salva hora na pilha
    jal registrar_transacao_debito # Chama a função de registro
    addi $sp, $sp, 4        # Libera espaço da hora

    ## 12. Imprimir Sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_transferencia_sucesso # Carrega "Transferencia realizada com sucesso\n"
    syscall                 # Executa a syscall
    j transferir_fim        # Pula para o fim

transferir_falha_origem:
    ## Mensagem de erro: Conta origem inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_conta_origem_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j transferir_fim        # Pula para o fim

transferir_falha_destino:
    ## Mensagem de erro: Conta destino inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_conta_destino_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    j transferir_fim        # Pula para o fim

transferir_falha_saldo:
    ## Mensagem de erro: Saldo insuficiente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_saldo_insuficiente # Carrega mensagem de erro
    syscall                 # Executa a syscall
    
transferir_fim:
    ## Restaurar registradores da pilha
    lw $s4, 0($sp)          # Restaura $s4
    lw $s3, 4($sp)          # Restaura $s3
    lw $s2, 8($sp)          # Restaura $s2
    lw $s1, 12($sp)         # Restaura $s1
    lw $s0, 16($sp)         # Restaura $s0
    lw $ra, 20($sp)         # Restaura $ra
    addi $sp, $sp, 24       # Libera 24 bytes
    j cli_loop              # Retorna ao loop principal
    
#### Handler para o comando 'debito_extrato'
#### Comando: debito_extrato-<conta>
#### Exibe o extrato de transações de débito (conta corrente) do cliente.
handle_debito_extrato:
    ## Salvar registradores na pilha
    addi $sp, $sp, -20      # Aloca 20 bytes
    sw $ra, 16($sp)         # Salva $ra
    sw $s0, 12($sp)         # Salva $s0 (ponteiro cliente)
    sw $s1, 8($sp)          # Salva $s1 (índice loop)
    sw $s2, 4($sp)          # Salva $s2 (total transações)
    sw $s3, 0($sp)          # Salva $s3 (ponteiro string conta cliente)

    ## Calcular juros pendentes
    jal calcular_juros_automatico # Chama a função de cálculo de juros

    ## 1. Parsear CONTA
    la $a0, buffer_temp     # $a0 = destino
    li $a1, '-'             # $a1 = delimitador
    move $a2, $s1           # $a2 = fonte (argumentos do main)
    jal parse_campo         # Extrai a conta

    ## 2. Buscar cliente
    la $a0, buffer_temp     # $a0 = conta (string)
    jal buscar_cliente_por_conta_completa # Busca o cliente
    beqz $v0, extrato_falha_cliente # Se $v0 == 0, pula para o erro
    move $s0, $v0           # Salva ponteiro do cliente em $s0

    ## 3. Imprimir Cabecalho do Extrato
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_cabecalho # Carrega "Extrato da conta "
    syscall                 # Executa a syscall
    la $a0, buffer_temp     # $a0 = conta (string)
    syscall                 # Imprime a conta
    la $a0, newline         # Carrega "\n"
    syscall                 # Imprime "\n"

    ## 4. Preparar o Loop
    la $s3, 12($s0)         # $s3 = ponteiro para string da conta do cliente (offset 12)
    li $s1, 0               # $s1 = índice (i = 0)
    la $t0, num_transacoes_debito # Endereço do contador
    lw $s2, 0($t0)          # $s2 = total de transações de débito

extrato_loop:
    ## Loop por todas as transações de débito
    bge $s1, $s2, extrato_fim_loop # Se i >= total, fim

    ## Calcula endereco da transacao[i] (24 bytes cada)
    li $t0, 24              # Tamanho da transação
    mul $t1, $s1, $t0       # offset = i * 24
    la $t2, transacoes_debito # Endereço base
    add $t2, $t2, $t1       # $t2 = endereço da transação[i]

    ## 6. Comparar a conta da transacao[i] com a conta do cliente
    move $a0, $s3           # $a0 = conta do cliente
    move $a1, $t2           # $a1 = conta da transação[i] (offset 0)
    jal strcmp              # Compara as strings

    bnez $v0, extrato_proxima_transacao # Se $v0 != 0 (diferentes), pula

    ## 7. CONTAS IGUAIS: Imprimir os dados da transacao
    lw $t3, 12($t2)         # $t3 = tipo (offset 12)
    beq $t3, 1, extrato_tipo1 # Se tipo 1 (Depósito)
    beq $t3, 2, extrato_tipo2 # Se tipo 2 (Saque)
    beq $t3, 3, extrato_tipo3 # Se tipo 3 (Transferência)
    j extrato_imprimir_valor # Tipo desconhecido

extrato_tipo1:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_tipo1 # Carrega "Tipo: Deposito"
    syscall                 # Executa a syscall
    j extrato_imprimir_valor # Pula para imprimir valor

extrato_tipo2:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_tipo2 # Carrega "Tipo: Saque"
    syscall                 # Executa a syscall
    j extrato_imprimir_valor # Pula para imprimir valor

extrato_tipo3:
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_tipo3 # Carrega "Tipo: Transferencia"
    syscall                 # Executa a syscall

extrato_imprimir_valor:
    ## Imprimir Valor
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_extrato_valor # Carrega " | Valor: "
    syscall                 # Executa a syscall

    lw $a0, 8($t2)          # $a0 = valor (offset 8)
    jal print_moeda         # Imprime o valor formatado

    ## Imprimir Data/Hora
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_data_hora_prefix # Carrega " | Data/Hora: "
    syscall                 # Executa a syscall

    lw $t5, 16($t2)         # $t5 = Data (DDMMAAAA) (offset 16)
    lw $t6, 20($t2)         # $t6 = Hora (HHMMSS) (offset 20)

    ## Extrair DD/MM/AAAA
    li $t7, 1000000         # Divisor
    div $t5, $t7            # data / 1000000
    mflo $t4                # $t4 = Dia
    mfhi $t8                # $t8 = Resto MMAAAA

    li $t7, 10000           # Divisor
    div $t8, $t7            # MMAAAA / 10000
    mflo $t3                # $t3 = Mes
    mfhi $t9                # $t9 = Ano

    ## Imprimir DD/MM/AAAA
    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t4           # Imprime Dia
    syscall                 # Executa a syscall

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_barra_data  # Imprime "/"
    syscall                 # Executa a syscall

    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t3           # Imprime Mes
    syscall                 # Executa a syscall

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_barra_data  # Imprime "/"
    syscall                 # Executa a syscall

    li $v0, 1               # Syscall 1 (print_int)
    move $a0, $t9           # Imprime Ano
    syscall                 # Executa a syscall

    ## Espaco antes da hora
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_espaco      # Imprime " "
    syscall                 # Executa a syscall

    ## Extrair HH:MM:SS
    li $t7, 10000           # Divisor
    div $t6, $t7            # hora / 10000
    mflo $t6                # $t6 = Hora
    mfhi $t7                # $t7 = Resto MMSS

    li $t8, 100             # Divisor
    div $t7, $t8            # MMSS / 100
    mflo $t8                # $t8 = Minutos
    mfhi $t9                # $t9 = Segundos

    ## Imprimir HH:MM:SS com dois dígitos
    move $a0, $t6           # $a0 = Hora
    jal print_dois_digitos  # Imprime (ex: 09)

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_dois_pontos # Imprime ":"
    syscall                 # Executa a syscall

    move $a0, $t8           # $a0 = Minutos
    jal print_dois_digitos  # Imprime (ex: 05)

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_dois_pontos # Imprime ":"
    syscall                 # Executa a syscall

    move $a0, $t9           # $a0 = Segundos
    jal print_dois_digitos  # Imprime (ex: 30)

    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Imprime "\n"
    syscall                 # Executa a syscall

    j extrato_proxima_transacao # Pula para a próxima iteração
    
extrato_proxima_transacao:
    addi $s1, $s1, 1        # i++
    j extrato_loop          # Volta ao loop

extrato_falha_cliente:
    ## Mensagem de erro: Cliente inexistente
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_cliente_inexistente # Carrega mensagem de erro
    syscall                 # Executa a syscall

extrato_fim_loop:
    ## Imprime newline final
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, newline         # Carrega "\n"
    syscall                 # Executa a syscall

    ## Restaurar registradores da pilha
    lw $s3, 0($sp)          # Restaura $s3
    lw $s2, 4($sp)          # Restaura $s2
    lw $s1, 8($sp)          # Restaura $s1
    lw $s0, 12($sp)         # Restaura $s0
    lw $ra, 16($sp)         # Restaura $ra
    addi $sp, $sp, 20       # Libera 20 bytes
    j cli_loop              # Retorna ao loop principal
    
# ===== FUNÇÕES DE CADASTRO E BUSCA =====

#### Função principal da lógica de cadastro
#### Assume que buffer_cpf, buffer_conta, e buffer_nome já estão preenchidos.
logica_cadastro_cliente:
    ## Salvar registradores na pilha
    addi $sp, $sp, -4       # Aloca 4 bytes
    sw $ra, 0($sp)          # Salva $ra

    ## Verificar limite de clientes
    la $t0, num_clientes    # Endereço do contador
    lw $t1, 0($t0)          # $t1 = total atual
    la $t2, max_clientes    # Endereço do limite
    lw $t3, 0($t2)          # $t3 = limite
    bge $t1, $t3, erro_limite_clientes # Se total >= limite, erro

    ## Verificar se CPF já existe
    la $a0, buffer_cpf      # $a0 = CPF (string)
    jal verificar_cpf_existe # Chama a verificação
    beq $v0, 1, erro_cpf_duplicado # Se $v0 == 1 (existe), erro

    ## Verificar se conta já existe
    la $a0, buffer_conta    # $a0 = Conta (string, sem DV)
    jal verificar_conta_existe # Chama a verificação
    beq $v0, 1, erro_conta_duplicada # Se $v0 == 1 (existe), erro

    ## Calcular dígito verificador
    la $a0, buffer_conta    # $a0 = Conta (string, 6 dígitos)
    jal calcular_digito_verificador # Calcula o DV
    # $v0 retorna o DV (0-10)

    ## Adicionar DV ao final da conta (no buffer_conta)
    la $t0, buffer_conta    # Endereço do buffer
    addi $t0, $t0, 6        # Pula para a 7ª posição (índice 6)

    beq $v0, 10, dv_x_cadastrar # Se DV == 10, usa 'X'
    addi $t1, $v0, 48       # $t1 = DV + '0' (ASCII)
    sb $t1, 0($t0)          # Salva o caractere do DV
    j fim_dv_cadastrar      # Pula

    dv_x_cadastrar:
        li $t1, 'X'         # $t1 = 'X'
        sb $t1, 0($t0)      # Salva 'X'

    fim_dv_cadastrar:
        addi $t0, $t0, 1    # Avança para a 8ª posição
        sb $zero, 0($t0)    # Adiciona o terminador nulo '\0'

    ## Adicionar cliente ao array 'clientes'
    la $a0, buffer_cpf      # $a0 = CPF (string)
    la $a1, buffer_conta    # $a1 = Conta (string, com DV)
    la $a2, buffer_nome     # $a2 = Nome (string)
    jal adicionar_cliente   # Chama a função para adicionar

    ## Mensagem de sucesso
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_sucesso_cadastro # Carrega "Cliente cadastrado com sucesso..."
    syscall                 # Executa a syscall

    ## Exibir conta com DV (formato XXXXXX-X)
    la $t0, buffer_conta    # $t0 = ponteiro para Conta (com DV)
    li $t1, 0               # $t1 = contador
    loop_exibir_conta_cad:
        bge $t1, 6, exibir_hifen_conta_cad # Se i >= 6, imprime hífen
        lb $a0, 0($t0)      # $a0 = caractere
        li $v0, 11          # Syscall 11 (print_char)
        syscall             # Imprime o caractere
        addi $t0, $t0, 1    # Avança ponteiro
        addi $t1, $t1, 1    # i++
        j loop_exibir_conta_cad # Volta ao loop

    exibir_hifen_conta_cad:
        li $v0, 4           # Syscall 4 (print_string)
        la $a0, hifen       # Carrega "-"
        syscall             # Imprime "-"

        lb $a0, 0($t0)      # $a0 = 7º caractere (DV)
        li $v0, 11          # Syscall 11 (print_char)
        syscall             # Imprime o DV

        li $v0, 4           # Syscall 4 (print_string)
        la $a0, newline     # Carrega "\n"
        syscall             # Imprime "\n"

        j fim_cadastro_cliente # Pula para o fim

    erro_limite_clientes:
        ## Mensagem de erro: Limite de clientes
        li $v0, 4           # Syscall 4 (print_string)
        la $a0, msg_limite_clientes # Carrega mensagem de erro
        syscall             # Executa a syscall
        j fim_cadastro_cliente # Pula para o fim

    erro_cpf_duplicado:
        ## Mensagem de erro: CPF duplicado
        li $v0, 4           # Syscall 4 (print_string)
        la $a0, msg_cpf_duplicado # Carrega mensagem de erro
        syscall             # Executa a syscall
        j fim_cadastro_cliente # Pula para o fim

    erro_conta_duplicada:
        ## Mensagem de erro: Conta duplicada
        li $v0, 4           # Syscall 4 (print_string)
        la $a0, msg_conta_duplicada # Carrega mensagem de erro
        syscall             # Executa a syscall

    fim_cadastro_cliente:
        ## Restaurar registradores da pilha
        lw $ra, 0($sp)      # Restaura $ra
        addi $sp, $sp, 4    # Libera 4 bytes
        jr $ra              # Retorna

#### Função para limpar newline de um buffer
#### (Usada especificamente para buffer_comando)
limpar_newline_comando:
    la $t0, buffer_comando  # $t0 = ponteiro para o buffer
    loop_limpar_comando:
        lb $t2, 0($t0)      # $t2 = caractere
        beq $t2, '\n', fim_limpar_comando # Se '\n', fim
        beqz $t2, fim_limpar_comando # Se '\0', fim
        addi $t0, $t0, 1    # Avança ponteiro
        j loop_limpar_comando # Volta ao loop
    fim_limpar_comando:
        sb $zero, 0($t0)    # Substitui '\n' ou '\0' por '\0'
        jr $ra              # Retorna

#### Função para calcular dígito verificador (Módulo 11)
#### Entrada: $a0 = ponteiro para string da conta (6 dígitos)
#### Saída: $v0 = DV (0-10)
calcular_digito_verificador:
    move $t0, $a0           # $t0 = ponteiro para a conta
    li $t1, 0               # $t1 = soma (acumulador)

    ## d0 (pos 5) * 2
    lb $t2, 5($t0)          # Carrega caractere (ASCII)
    addi $t2, $t2, -48      # Converte para int
    mul $t2, $t2, 2         # Multiplica pelo peso
    add $t1, $t1, $t2       # Acumula na soma

    ## d1 (pos 4) * 3
    lb $t2, 4($t0)          # Carrega caractere
    addi $t2, $t2, -48      # Converte para int
    mul $t2, $t2, 3         # Multiplica pelo peso
    add $t1, $t1, $t2       # Acumula na soma

    ## d2 (pos 3) * 4
    lb $t2, 3($t0)          # Carrega caractere
    addi $t2, $t2, -48      # Converte para int
    mul $t2, $t2, 4         # Multiplica pelo peso
    add $t1, $t1, $t2       # Acumula na soma

    ## d3 (pos 2) * 5
    lb $t2, 2($t0)          # Carrega caractere
    addi $t2, $t2, -48      # Converte para int
    mul $t2, $t2, 5         # Multiplica pelo peso
    add $t1, $t1, $t2       # Acumula na soma

    ## d4 (pos 1) * 6
    lb $t2, 1($t0)          # Carrega caractere
    addi $t2, $t2, -48      # Converte para int
    mul $t2, $t2, 6         # Multiplica pelo peso
    add $t1, $t1, $t2       # Acumula na soma

    ## d5 (pos 0) * 7
    lb $t2, 0($t0)          # Carrega caractere
    addi $t2, $t2, -48      # Converte para int
    mul $t2, $t2, 7         # Multiplica pelo peso
    add $t1, $t1, $t2       # Acumula na soma

    ## Resto da divisão por 11
    li $t3, 11              # Divisor 11
    div $t1, $t3            # soma / 11
    mfhi $v0                # $v0 = resto (DV)

    jr $ra                  # Retorna

#### Função para verificar se um CPF já existe
#### Entrada: $a0 = ponteiro para string do CPF (11 dígitos)
#### Saída: $v0 = 1 se existe, 0 se não existe
verificar_cpf_existe:
    la $t0, clientes        # $t0 = ponteiro para o início do array 'clientes'
    la $t1, num_clientes    # Endereço do contador
    lw $t2, 0($t1)          # $t2 = total de clientes
    li $t3, 0               # $t3 = índice (i = 0)

    loop_verif_cpf:
        bge $t3, $t2, cpf_nao_existe # Se i >= total, fim (não existe)
        
        ## Verificar se cliente está ativo (Offset 84)
        lw $t4, 84($t0)     # $t4 = status
        beqz $t4, proximo_cliente_cpf # Se status == 0 (inativo), pula

        ## Cliente ativo, comparar CPF (Offset 0)
        move $t5, $t0       # $t5 = ponteiro para CPF do cliente[i]
        move $t6, $a0       # $t6 = ponteiro para CPF buscado
        li $t7, 0           # $t7 = contador de caracteres

        loop_cmp_cpf:
            lb $t8, 0($t5)  # $t8 = char cliente[i]
            lb $t9, 0($t6)  # $t9 = char buscado
            bne $t8, $t9, proximo_cliente_cpf # Se diferentes, pula
            beqz $t8, cpf_existe # Se '\0' (e iguais), fim (existe)
            addi $t5, $t5, 1    # Avança ponteiro
            addi $t6, $t6, 1    # Avança ponteiro
            addi $t7, $t7, 1    # Incrementa contador
            blt $t7, 11, loop_cmp_cpf # Loop (máx 11 chars)

        cpf_existe:
            li $v0, 1           # $v0 = 1 (Verdadeiro)
            jr $ra              # Retorna

        proximo_cliente_cpf:
            addi $t0, $t0, 128  # Avança para o próximo cliente (128 bytes)
            addi $t3, $t3, 1    # i++
            j loop_verif_cpf    # Volta ao loop

    cpf_nao_existe:
        li $v0, 0           # $v0 = 0 (Falso)
        jr $ra              # Retorna

#### Função para verificar se uma conta já existe
#### Entrada: $a0 = ponteiro para string da conta (6 dígitos, sem DV)
#### Saída: $v0 = 1 se existe, 0 se não existe
verificar_conta_existe:
    la $t0, clientes        # $t0 = ponteiro para o início do array 'clientes'
    la $t1, num_clientes    # Endereço do contador
    lw $t2, 0($t1)          # $t2 = total de clientes
    li $t3, 0               # $t3 = índice (i = 0)

    loop_verif_conta:
        bge $t3, $t2, conta_nao_existe # Se i >= total, fim (não existe)
        
        ## Verificar se cliente está ativo (Offset 84)
        lw $t4, 84($t0)     # $t4 = status
        beqz $t4, proximo_cliente_conta # Se status == 0 (inativo), pula

        ## Cliente ativo, comparar Conta (Offset 12)
        addi $t5, $t0, 12   # $t5 = ponteiro para Conta do cliente[i]
        move $t6, $a0       # $t6 = ponteiro para Conta buscada
        li $t7, 0           # $t7 = contador de caracteres

        loop_cmp_conta:
            lb $t8, 0($t5)  # $t8 = char cliente[i]
            lb $t9, 0($t6)  # $t9 = char buscado
            bne $t8, $t9, proximo_cliente_conta # Se diferentes, pula
            beqz $t9, conta_existe # Se '\0' (e iguais), fim (existe)
            addi $t5, $t5, 1    # Avança ponteiro
            addi $t6, $t6, 1    # Avança ponteiro
            addi $t7, $t7, 1    # Incrementa contador
            blt $t7, 6, loop_cmp_conta # Loop (6 chars)

        conta_existe:
            li $v0, 1           # $v0 = 1 (Verdadeiro)
            jr $ra              # Retorna

        proximo_cliente_conta:
            addi $t0, $t0, 128  # Avança para o próximo cliente (128 bytes)
            addi $t3, $t3, 1    # i++
            j loop_verif_conta  # Volta ao loop

      conta_nao_existe:
        li $v0, 0           # $v0 = 0 (Falso)
        jr $ra              # Retorna

#### Função para buscar um cliente pela conta completa (com DV)
#### Entrada: $a0 = endereço da string conta (ex: 123456-7)
#### Saída: $v0 = ponteiro para o cliente, 0 se não existe
buscar_cliente_por_conta_completa:
 addi $sp, $sp, -4       # Aloca 4 bytes
 sw $ra, 0($sp)          # Salva $ra

 ## Formatar a conta de busca (ex: 123456-7) para o formato salvo (1234567\0)
 ## $a0 (origem) -> buffer_conta_completa (destino)
 la $t0, buffer_conta_completa # $t0 = Buffer de destino
 move $t1, $a0           # $t1 = Buffer de origem
 li $t2, 0               # $t2 = Contador

 loop_formatar_conta_busca_interno:
  lb $t3, 0($t1)        # $t3 = char
  beqz $t3, fim_formatar_conta_busca_interno # Se '\0', fim
  beq $t3, '-', proximo_char_conta_busca_interno # Se '-', pula

  sb $t3, 0($t0)        # Salva char no destino
  addi $t0, $t0, 1      # Avança ponteiro destino
  addi $t2, $t2, 1      # i++

 proximo_char_conta_busca_interno:
  addi $t1, $t1, 1      # Avança ponteiro origem
  j loop_formatar_conta_busca_interno # Volta ao loop

 fim_formatar_conta_busca_interno:
  sb $zero, 0($t0)      # Termina a string formatada

 ## Agora, $a0 (buffer_conta_completa) contém "1234567"
 la $a0, buffer_conta_completa # $a0 = string formatada (para strcmp)

 ## Loop principal de busca
 la $t0, clientes        # $t0 = ponteiro para o início do array 'clientes'
 la $t1, num_clientes    # Endereço do contador
 lw $t2, 0($t1)          # $t2 = total de clientes
 li $t3, 0               # $t3 = índice (i = 0)

 loop_buscar_conta_comp_interno:
  bge $t3, $t2, buscar_conta_comp_nao_existe_interno # Se i >= total, fim (não existe)
  
  ## Verificar se cliente está ativo (Offset 84)
  lw $t4, 84($t0)       # $t4 = status
  beqz $t4, proximo_buscar_conta_comp_interno # Se status == 0 (inativo), pula

  ## Cliente ativo, comparar Conta Completa (Offset 12)
  addi $t5, $t0, 12     # $t5 = ponteiro conta cliente[i] (formato 1234567)
  move $t6, $a0         # $t6 = ponteiro conta busca (formato 1234567)

  loop_cmp_buscar_conta_comp_interno:
   lb $t8, 0($t5)       # $t8 = char cliente[i]
   lb $t9, 0($t6)       # $t9 = char buscado
   bne $t8, $t9, proximo_buscar_conta_comp_interno # Se diferentes, pula
   beqz $t8, buscar_conta_comp_encontrado_interno # Se '\0' (e iguais), fim (encontrado)
   addi $t5, $t5, 1     # Avança ponteiro
   addi $t6, $t6, 1     # Avança ponteiro
   j loop_cmp_buscar_conta_comp_interno # Volta ao loop

  buscar_conta_comp_encontrado_interno:
   move $v0, $t0        # $v0 = ponteiro para o cliente
   j fim_buscar_conta_comp_interno # Pula para o fim

  proximo_buscar_conta_comp_interno:
   addi $t0, $t0, 128   # Avança para o próximo cliente (128 bytes)
   addi $t3, $t3, 1     # i++
   j loop_buscar_conta_comp_interno # Volta ao loop

 buscar_conta_comp_nao_existe_interno:
  li $v0, 0             # $v0 = 0 (Não encontrado)

 fim_buscar_conta_comp_interno:
  lw $ra, 0($sp)        # Restaura $ra
  addi $sp, $sp, 4      # Libera 4 bytes
  jr $ra                # Retorna

#### Função para adicionar um cliente ao array 'clientes'
#### Entrada: $a0 = CPF, $a1 = Conta (com DV), $a2 = Nome
adicionar_cliente:
    la $t0, clientes        # $t0 = ponteiro para o início do array 'clientes'
    la $t1, num_clientes    # Endereço do contador
    lw $t2, 0($t1)          # $t2 = total atual (índice do novo cliente)

    ## Calcular endereço do novo cliente
    mul $t3, $t2, 128       # offset = total * 128
    add $t0, $t0, $t3       # $t0 = endereço do novo cliente

    ## Copiar CPF (Offset 0)
    move $t4, $a0           # $t4 = fonte (CPF)
    move $t5, $t0           # $t5 = destino (cliente[i] + 0)
    li $t6, 0               # $t6 = contador
    loop_copy_cpf:
        lb $t7, 0($t4)      # $t7 = char
        sb $t7, 0($t5)      # Salva char
        beqz $t7, fim_copy_cpf # Se '\0', fim
        addi $t4, $t4, 1    # Avança fonte
        addi $t5, $t5, 1    # Avança destino
        addi $t6, $t6, 1    # i++
        blt $t6, 11, loop_copy_cpf # Loop (máx 11 chars)
    fim_copy_cpf:

    ## Copiar Conta (Offset 12)
    move $t4, $a1           # $t4 = fonte (Conta)
    addi $t5, $t0, 12       # $t5 = destino (cliente[i] + 12)
    li $t6, 0               # $t6 = contador
    loop_copy_conta:
        lb $t7, 0($t4)      # $t7 = char
        sb $t7, 0($t5)      # Salva char
        beqz $t7, fim_copy_conta # Se '\0', fim
        addi $t4, $t4, 1    # Avança fonte
        addi $t5, $t5, 1    # Avança destino
        addi $t6, $t6, 1    # i++
        blt $t6, 7, loop_copy_conta # Loop (máx 7 chars)
    fim_copy_conta:

    ## Copiar Nome (Offset 20)
    move $t4, $a2           # $t4 = fonte (Nome)
    addi $t5, $t0, 20       # $t5 = destino (cliente[i] + 20)
    loop_copy_nome:
        lb $t7, 0($t4)      # $t7 = char
        sb $t7, 0($t5)      # Salva char
        beqz $t7, fim_copy_nome # Se '\0', fim
        addi $t4, $t4, 1    # Avança fonte
        addi $t5, $t5, 1    # Avança destino
        j loop_copy_nome    # Volta ao loop
    fim_copy_nome:

    ## Definir valores padrão
    sw $zero, 72($t0)       # Saldo (Offset 72) = 0

    la $t4, limite_credito_padrao # Endereço da constante
    lw $t5, 0($t4)          # $t5 = limite padrão
    sw $t5, 76($t0)         # Limite (Offset 76) = padrão

    sw $zero, 80($t0)       # Credito Usado (Offset 80) = 0

    li $t4, 1               # $t4 = 1 (Ativo)
    sw $t4, 84($t0)         # Status (Offset 84) = 1

    ## Incrementar contador de clientes
    addi $t2, $t2, 1        # total = total + 1
    sw $t2, 0($t1)          # Salva o novo total

    jr $ra                  # Retorna

# ===== FUNÇÕES DE PERSISTÊNCIA (SALVAR/RECARREGAR) =====

#### Handler para o comando 'salvar'
handle_salvar:
    addi $sp, $sp, -4       # Aloca 4 bytes
    sw $ra, 0($sp)          # Salva $ra
    
    jal salvar_dados        # Chama a função de salvar
    
    lw $ra, 0($sp)          # Restaura $ra
    addi $sp, $sp, 4        # Libera 4 bytes
    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'recarregar'
handle_recarregar:
    addi $sp, $sp, -4       # Aloca 4 bytes
    sw $ra, 0($sp)          # Salva $ra
    
    jal recarregar_dados    # Chama a função de recarregar
    
    lw $ra, 0($sp)          # Restaura $ra
    addi $sp, $sp, 4        # Libera 4 bytes
    j cli_loop              # Retorna ao loop principal

#### Handler para o comando 'formatar'
handle_formatar:
    addi $sp, $sp, -4       # Aloca 4 bytes
    sw $ra, 0($sp)          # Salva $ra
    
    jal formatar_sistema    # Chama a função de formatar
    
    lw $ra, 0($sp)          # Restaura $ra
    addi $sp, $sp, 4        # Libera 4 bytes
    j cli_loop              # Retorna ao loop principal

#### Função para salvar todos os dados em "pingasbank_data.txt"
salvar_dados:
    ## Salvar registradores na pilha
    addi $sp, $sp, -28      # Aloca 28 bytes
    sw $ra, 24($sp)         # Salva $ra
    sw $s0, 20($sp)         # Salva $s0 (file descriptor)
    sw $s1, 16($sp)         # Salva $s1 (contador loop)
    sw $s2, 12($sp)         # Salva $s2 (limite loop)
    sw $s3, 8($sp)          # Salva $s3 (ponteiro cliente/transação)
    sw $s4, 4($sp)          # Salva $s4 (total temp)
    sw $s5, 0($sp)          # Salva $s5
    
    ## Abrir arquivo para escrita
    li $v0, 13              # Syscall 13 (open_file)
    la $a0, arquivo_nome    # $a0 = nome do arquivo
    li $a1, 1               # $a1 = flags (1 = Write-only)
    li $a2, 0               # $a2 = mode (ignorado)
    syscall                 # Executa a syscall
    
    bltz $v0, salvar_erro   # Se $v0 < 0, erro
    move $s0, $v0           # $s0 = file descriptor
    
    ## ===== CABEÇALHO =====
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_cab # $a1 = "<CAB>"
    jal escrever_string     # Escreve a string

    move $a0, $s0           # $a0 = fd
    la $t0, num_clientes    # Endereço do contador
    lw $a1, 0($t0)          # $a1 = total clientes
    move $s4, $a1           # Salva total em $s4
    jal escrever_campo_inteiro # Escreve total + ";"

    move $a0, $s0           # $a0 = fd
    la $t0, data_atual      # Endereço da data
    lw $a1, 0($t0)          # $a1 = data
    jal escrever_campo_inteiro # Escreve data + ";"
    
    move $a0, $s0           # $a0 = fd
    la $t0, hora_atual      # Endereço da hora
    lw $a1, 0($t0)          # $a1 = hora
    jal escrever_campo_inteiro # Escreve hora + ";"
    
    move $a0, $s0           # $a0 = fd
    la $t0, tempo_ultimo_incremento # Endereço do tempo
    lw $a1, 0($t0)          # $a1 = tempo
    jal escrever_inteiro    # Escreve tempo (sem ";")
    
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_fim_cab # $a1 = "</CAB>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    la $a1, newline         # $a1 = "\n"
    jal escrever_string     # Escreve "\n"
    
    ## ===== CLIENTES =====
    move $s2, $s4           # $s2 = limite (total de clientes)
    li $s1, 0               # $s1 = índice (i = 0)
    
salvar_loop_clientes:
    bge $s1, $s2, salvar_transacoes_debito # Se i >= total, fim
    
    li $t0, 128             # Tamanho do cliente
    mul $t1, $s1, $t0       # offset = i * 128
    la $t2, clientes        # Endereço base
    add $s3, $t2, $t1       # $s3 = endereço do cliente[i]
    
    lw $t3, 84($s3)         # $t3 = status
    beqz $t3, salvar_proximo_cliente # Se inativo, pula
    
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_cli # $a1 = "<CLI>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    move $a1, $s3           # $a1 = CPF (offset 0)
    jal escrever_campo_string # Escreve CPF + ";"
    
    move $a0, $s0           # $a0 = fd
    addi $a1, $s3, 12       # $a1 = Conta (offset 12)
    jal escrever_campo_string # Escreve Conta + ";"
    
    move $a0, $s0           # $a0 = fd
    addi $a1, $s3, 20       # $a1 = Nome (offset 20)
    jal escrever_campo_string # Escreve Nome + ";"
    
    move $a0, $s0           # $a0 = fd
    lw $a1, 72($s3)         # $a1 = Saldo (offset 72)
    jal escrever_campo_inteiro # Escreve Saldo + ";"
    
    move $a0, $s0           # $a0 = fd
    lw $a1, 76($s3)         # $a1 = Limite (offset 76)
    jal escrever_campo_inteiro # Escreve Limite + ";"
    
    move $a0, $s0           # $a0 = fd
    lw $a1, 80($s3)         # $a1 = Credito Usado (offset 80)
    jal escrever_campo_inteiro # Escreve Credito Usado + ";"
    
    move $a0, $s0           # $a0 = fd
    lw $a1, 84($s3)         # $a1 = Status (offset 84)
    jal escrever_inteiro    # Escreve Status (sem ";")
    
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_fim_cli # $a1 = "</CLI>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    la $a1, newline         # $a1 = "\n"
    jal escrever_string     # Escreve "\n"
    
salvar_proximo_cliente:
    addi $s1, $s1, 1        # i++
    j salvar_loop_clientes  # Volta ao loop
    
    ## ===== TRANSAÇÕES DÉBITO =====
salvar_transacoes_debito:
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_trd # $a1 = "<TRD>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    la $t0, num_transacoes_debito # Endereço do contador
    lw $a1, 0($t0)          # $a1 = total transações débito
    move $s4, $a1           # Salva total em $s4
    jal escrever_campo_inteiro # Escreve total + ";"
    
    move $s2, $s4           # $s2 = limite (total)
    li $s1, 0               # $s1 = índice (i = 0)
    
salvar_loop_debito:
    bge $s1, $s2, salvar_fim_debito # Se i >= total, fim
    
    li $t0, 24              # Tamanho da transação
    mul $t1, $s1, $t0       # offset = i * 24
    la $t2, transacoes_debito # Endereço base
    add $s3, $t2, $t1       # $s3 = endereço da transação[i]
    
    ## Conta (offset 0)
    move $a0, $s0           # $a0 = fd
    move $a1, $s3           # $a1 = Conta (string)
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Valor (offset 8)
    move $a0, $s0           # $a0 = fd
    lw $a1, 8($s3)          # $a1 = Valor
    jal escrever_inteiro    # Escreve o valor
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Tipo (offset 12)
    move $a0, $s0           # $a0 = fd
    lw $a1, 12($s3)         # $a1 = Tipo
    jal escrever_inteiro    # Escreve o tipo
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Data (offset 16)
    move $a0, $s0           # $a0 = fd
    lw $a1, 16($s3)         # $a1 = Data
    jal escrever_inteiro    # Escreve a data
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Hora (offset 20)
    move $a0, $s0           # $a0 = fd
    lw $a1, 20($s3)         # $a1 = Hora
    jal escrever_inteiro    # Escreve a hora
    
    move $a0, $s0           # $a0 = fd
    li $a1, ';'             # $a1 = ';' (fim da transação)
    jal escrever_delimitador # Escreve ";"
    
    addi $s1, $s1, 1        # i++
    j salvar_loop_debito    # Volta ao loop
    
salvar_fim_debito:
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_fim_trd # $a1 = "</TRD>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    la $a1, newline         # $a1 = "\n"
    jal escrever_string     # Escreve "\n"
    
    ## ===== TRANSAÇÕES CRÉDITO =====
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_trc # $a1 = "<TRC>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    la $t0, num_transacoes_credito # Endereço do contador
    lw $a1, 0($t0)          # $a1 = total transações crédito
    move $s4, $a1           # Salva total em $s4
    jal escrever_campo_inteiro # Escreve total + ";"
    
    move $s2, $s4           # $s2 = limite (total)
    li $s1, 0               # $s1 = índice (i = 0)
    
salvar_loop_credito:
    bge $s1, $s2, salvar_fim_credito # Se i >= total, fim
    
    li $t0, 24              # Tamanho da transação
    mul $t1, $s1, $t0       # offset = i * 24
    la $t2, transacoes_credito # Endereço base
    add $s3, $t2, $t1       # $s3 = endereço da transação[i]
    
    ## Conta (offset 0)
    move $a0, $s0           # $a0 = fd
    move $a1, $s3           # $a1 = Conta (string)
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Valor (offset 8)
    move $a0, $s0           # $a0 = fd
    lw $a1, 8($s3)          # $a1 = Valor
    jal escrever_inteiro    # Escreve o valor
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Tipo (offset 12)
    move $a0, $s0           # $a0 = fd
    lw $a1, 12($s3)         # $a1 = Tipo
    jal escrever_inteiro    # Escreve o tipo
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Data (offset 16)
    move $a0, $s0           # $a0 = fd
    lw $a1, 16($s3)         # $a1 = Data
    jal escrever_inteiro    # Escreve a data
    
    move $a0, $s0           # $a0 = fd
    li $a1, ','             # $a1 = ','
    jal escrever_delimitador # Escreve ","
    
    ## Hora (offset 20)
    move $a0, $s0           # $a0 = fd
    lw $a1, 20($s3)         # $a1 = Hora
    jal escrever_inteiro    # Escreve a hora
    
    move $a0, $s0           # $a0 = fd
    li $a1, ';'             # $a1 = ';' (fim da transação)
    jal escrever_delimitador # Escreve ";"
    
    addi $s1, $s1, 1        # i++
    j salvar_loop_credito   # Volta ao loop
    
salvar_fim_credito:
    move $a0, $s0           # $a0 = fd
    la $a1, arquivo_marcador_fim_trc # $a1 = "</TRC>"
    jal escrever_string     # Escreve a string
    
    move $a0, $s0           # $a0 = fd
    la $a1, newline         # $a1 = "\n"
    jal escrever_string     # Escreve "\n"
    
    ## Fechar arquivo
    li $v0, 16              # Syscall 16 (close_file)
    move $a0, $s0           # $a0 = fd
    syscall                 # Executa a syscall
    
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_salvar_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall
    j salvar_fim            # Pula para o fim
    
salvar_erro:
    ## Mensagem de erro: Falha ao salvar
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_salvar_erro # Carrega mensagem de erro
    syscall                 # Executa a syscall
    
salvar_fim:
    ## Restaurar registradores da pilha
    lw $s5, 0($sp)          # Restaura $s5
    lw $s4, 4($sp)          # Restaura $s4
    lw $s3, 8($sp)          # Restaura $s3
    lw $s2, 12($sp)         # Restaura $s2
    lw $s1, 16($sp)         # Restaura $s1
    lw $s0, 20($sp)         # Restaura $s0
    lw $ra, 24($sp)         # Restaura $ra
    addi $sp, $sp, 28       # Libera 28 bytes
    jr $ra                  # Retorna

# ===== FUNÇÕES AUXILIARES DE LEITURA (ARQUIVO) =====

#### Função para ler uma linha completa do arquivo
#### Lê até encontrar '\n' ou EOF. Substitui '\n' por '\0'.
#### Entrada: $a0 = file descriptor, $a1 = buffer destino
#### Saída: $v0 = número de bytes lidos (0 = EOF/vazio)
ler_linha_completa:
    ## Salvar registradores na pilha
    addi $sp, $sp, -20      # Aloca 20 bytes
    sw $ra, 16($sp)         # Salva $ra
    sw $s0, 12($sp)         # Salva $s0 (fd)
    sw $s1, 8($sp)          # Salva $s1 (ponteiro buffer)
    sw $s2, 4($sp)          # Salva $s2
    sw $s3, 0($sp)          # Salva $s3 (contador bytes)
    
    move $s0, $a0           # $s0 = fd
    move $s1, $a1           # $s1 = ponteiro atual do buffer
    move $s2, $a1           # $s2 = início do buffer
    li $s3, 0               # $s3 = contador de bytes
    
ler_linha_loop:
    ## Ler 1 byte
    li $v0, 14              # Syscall 14 (read_file)
    move $a0, $s0           # $a0 = fd
    move $a1, $s1           # $a1 = buffer (posição atual)
    li $a2, 1               # $a2 = 1 byte
    syscall                 # Executa a syscall
    
    ## EOF ou erro?
    blez $v0, ler_linha_eof # Se $v0 <= 0, fim
    
    ## Verificar se é newline
    lb $t0, 0($s1)          # $t0 = caractere lido
    beq $t0, '\n', ler_linha_fim # Se '\n', fim
    beq $t0, '\r', ler_linha_loop # Se '\r', ignora (continua o loop)
    
    ## Avançar
    addi $s1, $s1, 1        # Avança ponteiro do buffer
    addi $s3, $s3, 1        # Incrementa contador de bytes
    j ler_linha_loop        # Volta ao loop
    
ler_linha_eof:
    move $v0, $s3           # $v0 = total de bytes lidos
    sb $zero, 0($s1)        # Adiciona '\0' no final
    j ler_linha_return      # Pula para o retorno
    
ler_linha_fim:
    sb $zero, 0($s1)        # Substitui '\n' por '\0'
    move $v0, $s3           # $v0 = total de bytes lidos
    
ler_linha_return:
    ## Restaurar registradores da pilha
    lw $s3, 0($sp)          # Restaura $s3
    lw $s2, 4($sp)          # Restaura $s2
    lw $s1, 8($sp)          # Restaura $s1
    lw $s0, 12($sp)         # Restaura $s0
    lw $ra, 16($sp)         # Restaura $ra
    addi $sp, $sp, 20       # Libera 20 bytes
    jr $ra                  # Retorna

#### Função para parsear um campo com delimitador (para leitura de arquivo)
#### Copia de $a0 (fonte) para $a1 (destino) até encontrar $a2 (delimitador).
#### Entrada: $a0 = fonte, $a1 = destino, $a2 = delimitador
#### Saída: $v0 = ponteiro para o resto da string fonte (após o delimitador)
parsear_campo_delim:
    move $t0, $a0           # $t0 = fonte
    move $t1, $a1           # $t1 = destino
    move $t2, $a2           # $t2 = delimitador
    
parsear_loop:
    lb $t3, 0($t0)          # $t3 = char
    beqz $t3, parsear_fim_null # Se '\0', fim
    beq $t3, $t2, parsear_fim_delim # Se delimitador, fim
    
    sb $t3, 0($t1)          # Salva char no destino
    addi $t0, $t0, 1        # Avança fonte
    addi $t1, $t1, 1        # Avança destino
    j parsear_loop          # Volta ao loop
    
parsear_fim_delim:
    sb $zero, 0($t1)        # Adiciona '\0' no destino
    addi $t0, $t0, 1        # Pula o delimitador na fonte
    move $v0, $t0           # $v0 = resto da fonte
    jr $ra                  # Retorna
    
parsear_fim_null:
    sb $zero, 0($t1)        # Adiciona '\0' no destino
    move $v0, $t0           # $v0 = resto da fonte (no '\0')
    jr $ra                  # Retorna

#### Função para recarregar todos os dados de "pingasbank_data.txt"
recarregar_dados:
    ## Salvar registradores na pilha
    addi $sp, $sp, -32      # Aloca 32 bytes
    sw $ra, 28($sp)         # Salva $ra
    sw $s0, 24($sp)         # Salva $s0 (fd)
    sw $s1, 20($sp)         # Salva $s1 (contador)
    sw $s2, 16($sp)         # Salva $s2 (limite)
    sw $s3, 12($sp)         # Salva $s3 (ponteiro cliente/transação)
    sw $s4, 8($sp)          # Salva $s4 (buffer de linha)
    sw $s5, 4($sp)          # Salva $s5 (ponteiro de parsing)
    sw $s6, 0($sp)          # Salva $s6
    
    ## Abrir arquivo para leitura
    li $v0, 13              # Syscall 13 (open_file)
    la $a0, arquivo_nome    # $a0 = nome do arquivo
    li $a1, 0               # $a1 = flags (0 = Read-only)
    li $a2, 0               # $a2 = mode
    syscall                 # Executa a syscall
    move $s0, $v0           # $s0 = fd
    
    bltz $s0, recarregar_arquivo_nao_existe # Se $v0 < 0, arquivo não existe
    
    ## ===== LIMPAR DADOS ATUAIS =====
    la $t0, num_clientes    # Endereço do contador
    sw $zero, 0($t0)        # Zera
    la $t0, num_transacoes_debito # Endereço do contador
    sw $zero, 0($t0)        # Zera
    la $t0, num_transacoes_credito # Endereço do contador
    sw $zero, 0($t0)        # Zera
    la $t0, data_atual      # Endereço da data
    sw $zero, 0($t0)        # Zera
    la $t0, hora_atual      # Endereço da hora
    sw $zero, 0($t0)        # Zera
    la $t0, tempo_ultimo_incremento # Endereço do tempo
    sw $zero, 0($t0)        # Zera
    
    ## ===== LER CABEÇALHO =====
    move $a0, $s0           # $a0 = fd
    la $a1, buffer_linha    # $a1 = buffer
    jal ler_linha_completa  # Lê a primeira linha
    beqz $v0, recarregar_erro_formato # Se 0 bytes, erro
    
    ## Pular "<CAB>"
    la $s5, buffer_linha    # $s5 = ponteiro de parsing
    addi $s5, $s5, 5        # Avança 5 chars
    
    ## Ler num_clientes
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    
    la $a0, buffer_temp     # $a0 = string (total)
    jal atoi                # Converte para int
    la $t0, num_clientes    # Endereço do contador
    sw $v0, 0($t0)          # Salva o total
    move $s2, $v0           # $s2 = Total de clientes a ler
    
    ## Ler data_atual
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    
    la $a0, buffer_temp     # $a0 = string (data)
    jal atoi                # Converte para int
    la $t0, data_atual      # Endereço da data
    sw $v0, 0($t0)          # Salva a data
    
    ## Ler hora_atual
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    
    la $a0, buffer_temp     # $a0 = string (hora)
    jal atoi                # Converte para int
    la $t0, hora_atual      # Endereço da hora
    sw $v0, 0($t0)          # Salva a hora
    
    ## Ler tempo_ultimo_incremento
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino
    li $a2, '<'             # $a2 = delimitador ('<')
    jal parsear_campo_delim # Parseia o campo
    
    la $a0, buffer_temp     # $a0 = string (tempo)
    jal atoi                # Converte para int
    la $t0, tempo_ultimo_incremento # Endereço do tempo
    sw $v0, 0($t0)          # Salva o tempo
    
    ## ===== RECARREGAR CLIENTES =====
    li $s1, 0               # $s1 = índice (i = 0)
    
recarregar_cliente_loop:
    bge $s1, $s2, recarregar_transacoes_debito # Se i >= total, fim
    
    ## Ler linha do cliente
    move $a0, $s0           # $a0 = fd
    la $a1, buffer_linha    # $a1 = buffer
    jal ler_linha_completa  # Lê a linha
    beqz $v0, recarregar_erro_incompleto # Se 0 bytes, erro
    
    ## Calcular endereço do cliente
    li $t0, 128             # Tamanho do cliente
    mul $t1, $s1, $t0       # offset = i * 128
    la $t2, clientes        # Endereço base
    add $s3, $t2, $t1       # $s3 = endereço do cliente[i]
    
    ## Pular "<CLI>"
    la $s5, buffer_linha    # $s5 = ponteiro de parsing
    addi $s5, $s5, 5        # Avança 5 chars
    
    ## CPF (Offset 0)
    move $a0, $s5           # $a0 = fonte
    move $a1, $s3           # $a1 = destino (cliente[i] + 0)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia e copia
    move $s5, $v0           # $s5 = resto da fonte
    
    ## Conta (Offset 12)
    move $a0, $s5           # $a0 = fonte
    addi $a1, $s3, 12       # $a1 = destino (cliente[i] + 12)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia e copia
    move $s5, $v0           # $s5 = resto da fonte
    
    ## Nome (Offset 20)
    move $a0, $s5           # $a0 = fonte
    addi $a1, $s3, 20       # $a1 = destino (cliente[i] + 20)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia e copia
    move $s5, $v0           # $s5 = resto da fonte
    
    ## Saldo (Offset 72)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (saldo)
    jal atoi                # Converte para int
    sw $v0, 72($s3)         # Salva o saldo
    
    ## Limite (Offset 76)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (limite)
    jal atoi                # Converte para int
    sw $v0, 76($s3)         # Salva o limite
    
    ## Crédito Usado (Offset 80)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (credito)
    jal atoi                # Converte para int
    sw $v0, 80($s3)         # Salva o crédito
    
    ## Status (Offset 84)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, '<'             # $a2 = delimitador ('<')
    jal parsear_campo_delim # Parseia o campo
    la $a0, buffer_temp     # $a0 = string (status)
    jal atoi                # Converte para int
    sw $v0, 84($s3)         # Salva o status
    
    addi $s1, $s1, 1        # i++
    j recarregar_cliente_loop # Volta ao loop
    
    ## ===== RECARREGAR TRANSAÇÕES DÉBITO =====
recarregar_transacoes_debito:
    ## Ler linha completa de transações (pode ser longa)
    move $a0, $s0           # $a0 = fd
    la $a1, buffer_arquivo  # $a1 = buffer grande
    jal ler_linha_completa  # Lê a linha
    beqz $v0, recarregar_erro_formato # Se 0 bytes, erro
    
    ## Pular "<TRD>" e ler quantidade
    la $s5, buffer_arquivo  # $s5 = ponteiro de parsing
    addi $s5, $s5, 5        # Avança 5 chars
    
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo (total)
    move $s5, $v0           # $s5 = resto da fonte (início das transações)
    
    la $a0, buffer_temp     # $a0 = string (total)
    jal atoi                # Converte para int
    move $s2, $v0           # $s2 = limite (total de transações)
    la $t0, num_transacoes_debito # Endereço do contador
    sw $v0, 0($t0)          # Salva o total
    
    li $s1, 0               # $s1 = índice (i = 0)
    
recarregar_loop_debito:
    bge $s1, $s2, recarregar_transacoes_credito # Se i >= total, fim
    
    ## Calcular endereço da transação
    li $t0, 24              # Tamanho da transação
    mul $t1, $s1, $t0       # offset = i * 24
    la $t2, transacoes_debito # Endereço base
    add $s3, $t2, $t1       # $s3 = endereço da transação[i]
    
    ## Verificar se chegou no fim da string (marcador </TRD>)
    lb $t9, 0($s5)          # $t9 = char
    beqz $t9, recarregar_transacoes_credito # Se '\0', fim
    beq $t9, '<', recarregar_transacoes_credito # Se '<', fim
    
    ## Conta (Offset 0)
    move $a0, $s5           # $a0 = fonte
    move $a1, $s3           # $a1 = destino (transacao[i] + 0)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia e copia
    move $s5, $v0           # $s5 = resto da fonte
    
    ## Valor (Offset 8)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (valor)
    jal atoi                # Converte para int
    sw $v0, 8($s3)          # Salva o valor
    
    ## Tipo (Offset 12)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (tipo)
    jal atoi                # Converte para int
    sw $v0, 12($s3)         # Salva o tipo
    
    ## Data (Offset 16)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (data)
    jal atoi                # Converte para int
    sw $v0, 16($s3)         # Salva a data
    
    ## Hora (Offset 20)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador (fim da transação)
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte (próxima transação)
    la $a0, buffer_temp     # $a0 = string (hora)
    jal atoi                # Converte para int
    sw $v0, 20($s3)         # Salva a hora
    
    addi $s1, $s1, 1        # i++
    j recarregar_loop_debito # Volta ao loop
    
    ## ===== RECARREGAR TRANSAÇÕES CRÉDITO =====
recarregar_transacoes_credito:
    ## Ler linha completa de transações
    move $a0, $s0           # $a0 = fd
    la $a1, buffer_arquivo  # $a1 = buffer grande
    jal ler_linha_completa  # Lê a linha
    beqz $v0, recarregar_fechar # Se 0 bytes, fim
    
    ## Pular "<TRC>" e ler quantidade
    la $s5, buffer_arquivo  # $s5 = ponteiro de parsing
    addi $s5, $s5, 5        # Avança 5 chars
    
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo (total)
    move $s5, $v0           # $s5 = resto da fonte (início das transações)
    
    la $a0, buffer_temp     # $a0 = string (total)
    jal atoi                # Converte para int
    move $s2, $v0           # $s2 = limite (total de transações)
    la $t0, num_transacoes_credito # Endereço do contador
    sw $v0, 0($t0)          # Salva o total
    
    li $s1, 0               # $s1 = índice (i = 0)
    
recarregar_loop_credito:
    bge $s1, $s2, recarregar_fechar # Se i >= total, fim
    
    ## Calcular endereço da transação
    li $t0, 24              # Tamanho da transação
    mul $t1, $s1, $t0       # offset = i * 24
    la $t2, transacoes_credito # Endereço base
    add $s3, $t2, $t1       # $s3 = endereço da transação[i]
    
    ## Verificar fim da string
    lb $t9, 0($s5)          # $t9 = char
    beqz $t9, recarregar_fechar # Se '\0', fim
    beq $t9, '<', recarregar_fechar # Se '<', fim
    
    ## Conta (Offset 0)
    move $a0, $s5           # $a0 = fonte
    move $a1, $s3           # $a1 = destino (transacao[i] + 0)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia e copia
    move $s5, $v0           # $s5 = resto da fonte
    
    ## Valor (Offset 8)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (valor)
    jal atoi                # Converte para int
    sw $v0, 8($s3)          # Salva o valor
    
    ## Tipo (Offset 12)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (tipo)
    jal atoi                # Converte para int
    sw $v0, 12($s3)         # Salva o tipo
    
    ## Data (Offset 16)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ','             # $a2 = delimitador
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte
    la $a0, buffer_temp     # $a0 = string (data)
    jal atoi                # Converte para int
    sw $v0, 16($s3)         # Salva a data
    
    ## Hora (Offset 20)
    move $a0, $s5           # $a0 = fonte
    la $a1, buffer_temp     # $a1 = destino (temp)
    li $a2, ';'             # $a2 = delimitador (fim da transação)
    jal parsear_campo_delim # Parseia o campo
    move $s5, $v0           # $s5 = resto da fonte (próxima transação)
    la $a0, buffer_temp     # $a0 = string (hora)
    jal atoi                # Converte para int
    sw $v0, 20($s3)         # Salva a hora
    
    addi $s1, $s1, 1        # i++
    j recarregar_loop_credito # Volta ao loop
    
recarregar_fechar:
    ## Fechar arquivo
    li $v0, 16              # Syscall 16 (close_file)
    move $a0, $s0           # $a0 = fd
    syscall                 # Executa a syscall
    
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_recarregar_sucesso # Carrega mensagem de sucesso
    syscall                 # Executa a syscall
    j recarregar_fim        # Pula para o fim
    
recarregar_arquivo_nao_existe:
    ## Mensagem de erro: Arquivo não existe
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_arquivo_nao_existe # Carrega mensagem
    syscall                 # Executa a syscall
    j recarregar_fim        # Pula para o fim
    
recarregar_erro_incompleto:
recarregar_erro_formato:
    ## Mensagem de erro: Erro de formato ou incompleto
    li $v0, 4               # Syscall 4 (print_string)
    la $a0, msg_recarregar_erro # Carrega mensagem de erro
    syscall                 # Executa a syscall
    
    li $v0, 16              # Syscall 16 (close_file)
    move $a0, $s0           # $a0 = fd
    syscall                 # Fecha o arquivo (mesmo com erro)
    
recarregar_fim:
    ## Restaurar registradores da pilha
    lw $s6, 0($sp)          # Restaura $s6
    lw $s5, 4($sp)          # Restaura $s5
    lw $s4, 8($sp)          # Restaura $s4
    lw $s3, 12($sp)         # Restaura $s3
    lw $s2, 16($sp)         # Restaura $s2
    lw $s1, 20($sp)         # Restaura $s1
    lw $s0, 24($sp)         # Restaura $s0
    lw $ra, 28($sp)         # Restaura $ra
    addi $sp, $sp, 32       # Libera 32 bytes
    jr $ra                  # Retorna

# =====FUNÇÃO FORMATAR_SISTEMA=====
#### Apaga todos os dados da memória do sistema
#### Solicita confirmação do usuário antes de prosseguir
#### Zera contadores, data/hora e marca todos os clientes como inativos
formatar_sistema:
    addi $sp, $sp, -4 # Reserva espaço na pilha
    sw $ra, 0($sp) # Salva endereço de retorno
    
    ## Solicitar confirmação do usuário
    li $v0, 4 # Syscall para imprimir string
    la $a0, msg_formatar_confirmacao # Carrega mensagem de confirmação
    syscall
    
    ## Ler resposta do usuário
    li $v0, 8 # Syscall para ler string
    la $a0, buffer_confirmar_opcao # Carrega buffer para resposta
    li $a1, 4 # Define tamanho máximo da entrada
    syscall
    
    ## Limpar caractere newline da entrada
    la $a0, buffer_confirmar_opcao # Carrega buffer
    jal limpar_newline_comando # Chama função para limpar newline
    
    ## Verificar se usuário confirmou com 'S' ou 's'
    la $t0, buffer_confirmar_opcao # Carrega buffer
    lb $t0, 0($t0) # Lê primeiro caractere
    beq $t0, 'S', formatar_confirmado # Se for 'S', confirma
    beq $t0, 's', formatar_confirmado # Se for 's', confirma
    
    ## Operação não confirmada - cancelar formatação
    li $v0, 4 # Syscall para imprimir string
    la $a0, msg_formatar_cancelado # Carrega mensagem de cancelamento
    syscall
    j formatar_fim # Pula para o fim
    
formatar_confirmado:
    ## Zerar contador de clientes
    la $t0, num_clientes # Carrega endereço do contador
    sw $zero, 0($t0) # Define contador como zero
    
    ## Zerar contador de transações de débito
    la $t0, num_transacoes_debito # Carrega endereço do contador
    sw $zero, 0($t0) # Define contador como zero
    
    ## Zerar contador de transações de crédito
    la $t0, num_transacoes_credito # Carrega endereço do contador
    sw $zero, 0($t0) # Define contador como zero
    
    ## Zerar data atual do sistema
    la $t0, data_atual # Carrega endereço da data
    sw $zero, 0($t0) # Define data como zero
    
    ## Zerar hora atual do sistema
    la $t0, hora_atual # Carrega endereço da hora
    sw $zero, 0($t0) # Define hora como zero
    
    ## Zerar timestamp do último incremento
    la $t0, tempo_ultimo_incremento # Carrega endereço do timestamp
    sw $zero, 0($t0) # Define timestamp como zero
    
    ## Preparar loop para limpar array de clientes
    la $t0, clientes # Carrega endereço base do array
    li $t1, 0 # Inicializa índice em zero
    li $t2, 50 # Define máximo de clientes
    
formatar_loop_clientes:
    bge $t1, $t2, formatar_sucesso # Se índice >= máximo, termina loop
    
    ## Calcular offset do cliente atual
    mul $t3, $t1, 128 # Multiplica índice por tamanho da estrutura
    add $t4, $t0, $t3 # Calcula endereço do cliente
    sw $zero, 84($t4) # Define status como zero (inativo)
    
    addi $t1, $t1, 1 # Incrementa índice
    j formatar_loop_clientes # Continua loop
    
formatar_sucesso:
    ## Exibir mensagem de sucesso
    li $v0, 4 # Syscall para imprimir string
    la $a0, msg_formatar_sucesso # Carrega mensagem de sucesso
    syscall
    
formatar_fim:
    lw $ra, 0($sp) # Restaura endereço de retorno
    addi $sp, $sp, 4 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÕES AUXILIARES DE LEITURA=====

#### Lê e separa um campo delimitado de uma string
#### $a0 = buffer destino
#### $a1 = caractere delimitador
#### $a2 = ponteiro para string fonte
#### $v0 = ponteiro atualizado após o delimitador
parse_campo:
    move $t0, $a0 # Copia ponteiro destino
    move $t1, $a1 # Copia delimitador
    move $t2, $a2 # Copia ponteiro fonte

loop_parse_campo:
    lb $t3, 0($t2) # Lê caractere atual da fonte
    beq $t3, $t1, fim_parse_campo # Se for delimitador, termina
    beqz $t3, fim_parse_campo_null # Se for null, termina
    
    sb $t3, 0($t0) # Copia caractere para destino
    addi $t0, $t0, 1 # Avança ponteiro destino
    addi $t2, $t2, 1 # Avança ponteiro fonte
    j loop_parse_campo # Continua loop

fim_parse_campo:
    sb $zero, 0($t0) # Adiciona terminador null
    addi $t2, $t2, 1 # Pula o delimitador
    move $v0, $t2 # Retorna ponteiro atualizado
    jr $ra # Retorna

fim_parse_campo_null:
    sb $zero, 0($t0) # Adiciona terminador null
    move $v0, $t2 # Retorna ponteiro no null
    jr $ra # Retorna

# =====FUNÇÃO ATOI COM SUPORTE A NEGATIVOS=====
#### Converte string ASCII para inteiro
#### Suporta números positivos e negativos
#### $a0 = ponteiro para string
#### $v0 = valor inteiro resultante
atoi:
    addi $sp, $sp, -8 # Reserva espaço na pilha
    sw $s0, 4($sp) # Salva $s0
    sw $s1, 0($sp) # Salva $s1
    
    li $v0, 0 # Inicializa resultado
    move $t0, $a0 # Copia ponteiro para string
    li $s1, 1 # Inicializa sinal como positivo
    
    ## Verificar se número é negativo
    lb $t1, 0($t0) # Lê primeiro caractere
    bne $t1, '-', atoi_loop # Se não for '-', processa normalmente
    
    li $s1, -1 # Define sinal como negativo
    addi $t0, $t0, 1 # Pula o caractere '-'
    
atoi_loop:
    lb $t1, 0($t0) # Lê caractere atual
    beqz $t1, atoi_fim # Se for null, termina
    
    blt $t1, '0', atoi_fim # Se menor que '0', termina
    bgt $t1, '9', atoi_fim # Se maior que '9', termina
    
    addi $t1, $t1, -48 # Converte ASCII para dígito
    
    mul $v0, $v0, 10 # Multiplica resultado por 10
    add $v0, $v0, $t1 # Adiciona dígito ao resultado
    
    addi $t0, $t0, 1 # Avança ponteiro
    j atoi_loop # Continua loop
    
atoi_fim:
    mul $v0, $v0, $s1 # Aplica o sinal ao resultado
    
    lw $s1, 0($sp) # Restaura $s1
    lw $s0, 4($sp) # Restaura $s0
    addi $sp, $sp, 8 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÃO PRINT_MOEDA=====
#### Imprime valor monetário no formato R$ X,YY
#### $a0 = valor em centavos
print_moeda:
    addi $sp, $sp, -16 # Reserva espaço na pilha
    sw $ra, 0($sp) # Salva endereço de retorno
    sw $s0, 4($sp) # Salva $s0
    sw $s1, 8($sp) # Salva $s1
    sw $t0, 12($sp) # Salva $t0
    
    move $t0, $a0 # Salva valor original em $t0
    
    ## Imprimir prefixo "R$ "
    li $v0, 4 # Syscall para imprimir string
    la $a0, msg_str_rs # Carrega string "R$ "
    syscall
    
    ## Calcular reais e centavos
    li $t1, 100 # Divisor para separar reais de centavos
    div $t0, $t1 # Divide valor por 100
    mflo $s0 # Parte inteira (reais)
    mfhi $s1 # Resto (centavos)
    
    ## Imprimir parte dos reais
    li $v0, 1 # Syscall para imprimir inteiro
    move $a0, $s0 # Move reais para $a0
    syscall
    
    ## Imprimir vírgula separadora
    li $v0, 4 # Syscall para imprimir string
    la $a0, msg_str_virgula # Carrega vírgula
    syscall
    
    ## Verificar se precisa imprimir zero à esquerda
    blt $s1, 10, print_moeda_zero # Se centavos < 10, imprime zero
    j print_moeda_centavos # Senão, pula para centavos
    
print_moeda_zero:
    li $v0, 4 # Syscall para imprimir string
    la $a0, msg_str_zero # Carrega "0"
    syscall
    
print_moeda_centavos:
    ## Imprimir centavos
    li $v0, 1 # Syscall para imprimir inteiro
    move $a0, $s1 # Move centavos para $a0
    syscall
    
    ## Imprimir newline
    li $v0, 4 # Syscall para imprimir string
    la $a0, newline # Carrega newline
    syscall
    
    ## Restaurar registradores salvos
    lw $t0, 12($sp) # Restaura $t0
    lw $s1, 8($sp) # Restaura $s1
    lw $s0, 4($sp) # Restaura $s0
    lw $ra, 0($sp) # Restaura endereço de retorno
    addi $sp, $sp, 16 # Libera espaço da pilha
    jr $ra # Retorna

# =====HELPERS DE STRINGS=====

#### Compara duas strings
#### $a0 = string1
#### $a1 = string2
#### $v0 = 0 se iguais, 1 se diferentes
strcmp:
    li $v0, 0 # Assume que são iguais inicialmente
    
loop_strcmp:
    lb $t0, 0($a0) # Lê caractere da string1
    lb $t1, 0($a1) # Lê caractere da string2
    
    bne $t0, $t1, strcmp_diferente # Se diferentes, marca como diferente
    
    beqz $t0, fim_strcmp # Se ambos são null, termina
    
    addi $a0, $a0, 1 # Avança ponteiro string1
    addi $a1, $a1, 1 # Avança ponteiro string2
    j loop_strcmp # Continua loop
    
strcmp_diferente:
    li $v0, 1 # Marca como diferente
    
fim_strcmp:
    jr $ra # Retorna

#### Copia string de origem para destino
#### $a0 = destino
#### $a1 = origem
strcpy:
loop_strcpy:
    lb $t0, 0($a1) # Lê caractere da origem
    sb $t0, 0($a0) # Escreve no destino
    beqz $t0, fim_strcpy # Se null, termina
    addi $a0, $a0, 1 # Avança ponteiro destino
    addi $a1, $a1, 1 # Avança ponteiro origem
    j loop_strcpy # Continua loop
    
fim_strcpy:
    jr $ra # Retorna

# =====FUNÇÕES DE ESCRITA EM ARQUIVO=====

#### Escreve string em arquivo
#### $a0 = file descriptor
#### $a1 = ponteiro para string
escrever_string:
    addi $sp, $sp, -20 # Reserva espaço na pilha
    sw $ra, 16($sp) # Salva endereço de retorno
    sw $s0, 12($sp) # Salva $s0
    sw $s1, 8($sp) # Salva $s1
    sw $s2, 4($sp) # Salva $s2
    sw $s3, 0($sp) # Salva $s3
    
    move $s0, $a0 # Salva file descriptor
    move $s1, $a1 # Salva ponteiro para string
    
    ## Calcular comprimento da string
    move $s2, $s1 # Copia ponteiro
    li $s3, 0 # Inicializa contador
    
calc_tamanho_str_novo:
    lb $t0, 0($s2) # Lê caractere atual
    beqz $t0, fim_calc_tamanho_str_novo # Se null, termina
    addi $s2, $s2, 1 # Avança ponteiro
    addi $s3, $s3, 1 # Incrementa contador
    j calc_tamanho_str_novo # Continua loop
    
fim_calc_tamanho_str_novo:
    ## Escrever string no arquivo
    li $v0, 15 # Syscall para escrever em arquivo
    move $a0, $s0 # File descriptor
    move $a1, $s1 # Buffer da string
    move $a2, $s3 # Tamanho da string
    syscall
    
    ## Restaurar registradores
    lw $s3, 0($sp) # Restaura $s3
    lw $s2, 4($sp) # Restaura $s2
    lw $s1, 8($sp) # Restaura $s1
    lw $s0, 12($sp) # Restaura $s0
    lw $ra, 16($sp) # Restaura endereço de retorno
    addi $sp, $sp, 20 # Libera espaço da pilha
    jr $ra # Retorna

#### Converte inteiro para string
#### $a0 = inteiro
#### $a1 = buffer destino
inteiro_para_string_seguro:
    addi $sp, $sp, -20 # Reserva espaço na pilha
    sw $ra, 16($sp) # Salva endereço de retorno
    sw $s0, 12($sp) # Salva $s0
    sw $s1, 8($sp) # Salva $s1
    sw $s2, 4($sp) # Salva $s2
    sw $s3, 0($sp) # Salva $s3
    
    move $s0, $a0 # Salva valor
    move $s1, $a1 # Salva buffer
    move $s2, $a1 # Guarda início do buffer
    
    ## Verificar se número é negativo
    bgez $s0, int_str_pos_novo # Se positivo, pula
    
    li $t0, '-' # Caractere de sinal negativo
    sb $t0, 0($s1) # Escreve no buffer
    addi $s1, $s1, 1 # Avança ponteiro
    sub $s0, $zero, $s0 # Torna valor positivo
    
int_str_pos_novo:
    move $s3, $s1 # Salva posição atual
    
    ## Caso especial: número zero
    bnez $s0, int_str_nao_zero_novo # Se não for zero, pula
    li $t0, '0' # Caractere '0'
    sb $t0, 0($s3) # Escreve no buffer
    addi $s3, $s3, 1 # Avança ponteiro
    sb $zero, 0($s3) # Adiciona terminador null
    j int_str_fim_novo # Termina
    
int_str_nao_zero_novo:
    move $t1, $s0 # Copia valor
    
int_str_extrai_loop_novo:
    beqz $t1, int_str_reverte_novo # Se zero, termina extração
    li $t2, 10 # Divisor
    div $t1, $t2 # Divide por 10
    mflo $t1 # Quociente
    mfhi $t3 # Resto (dígito)
    addi $t3, $t3, 48 # Converte para ASCII
    sb $t3, 0($s3) # Escreve no buffer
    addi $s3, $s3, 1 # Avança ponteiro
    j int_str_extrai_loop_novo # Continua loop
    
int_str_reverte_novo:
    sb $zero, 0($s3) # Adiciona terminador null
    
    ## Reverter string de dígitos
    move $t0, $s1 # Ponteiro início
    addi $t1, $s3, -1 # Ponteiro fim
    
int_str_rev_loop_novo:
    bge $t0, $t1, int_str_fim_novo # Se ponteiros se cruzaram, termina
    lb $t2, 0($t0) # Lê caractere do início
    lb $t3, 0($t1) # Lê caractere do fim
    sb $t3, 0($t0) # Troca caracteres
    sb $t2, 0($t1) # Troca caracteres
    addi $t0, $t0, 1 # Avança início
    addi $t1, $t1, -1 # Retrocede fim
    j int_str_rev_loop_novo # Continua loop
    
int_str_fim_novo:
    ## Restaurar registradores
    lw $s3, 0($sp) # Restaura $s3
    lw $s2, 4($sp) # Restaura $s2
    lw $s1, 8($sp) # Restaura $s1
    lw $s0, 12($sp) # Restaura $s0
    lw $ra, 16($sp) # Restaura endereço de retorno
    addi $sp, $sp, 20 # Libera espaço da pilha
    jr $ra # Retorna

#### Escreve inteiro em arquivo
#### $a0 = file descriptor
#### $a1 = valor inteiro
escrever_inteiro:
    addi $sp, $sp, -16 # Reserva espaço na pilha
    sw $ra, 12($sp) # Salva endereço de retorno
    sw $s0, 8($sp) # Salva $s0
    sw $s1, 4($sp) # Salva $s1
    sw $s2, 0($sp) # Salva $s2
    
    move $s0, $a0 # Salva file descriptor
    move $s1, $a1 # Salva valor
    
    ## Criar buffer temporário na pilha
    addi $sp, $sp, -64 # Reserva 64 bytes
    move $s2, $sp # Salva ponteiro do buffer
    
    ## Converter inteiro para string
    move $a0, $s1 # Valor a converter
    move $a1, $s2 # Buffer destino
    jal inteiro_para_string_seguro # Chama conversão
    
    ## Escrever string no arquivo
    move $a0, $s0 # File descriptor
    move $a1, $s2 # Buffer com string
    jal escrever_string # Chama escrita
    
    ## Liberar buffer temporário
    addi $sp, $sp, 64 # Libera 64 bytes
    
    ## Restaurar registradores
    lw $s2, 0($sp) # Restaura $s2
    lw $s1, 4($sp) # Restaura $s1
    lw $s0, 8($sp) # Restaura $s0
    lw $ra, 12($sp) # Restaura endereço de retorno
    addi $sp, $sp, 16 # Libera espaço da pilha
    jr $ra # Retorna

#### Escreve caractere delimitador em arquivo
#### $a0 = file descriptor
#### $a1 = caractere delimitador
escrever_delimitador:
    addi $sp, $sp, -16 # Reserva espaço na pilha
    sw $ra, 12($sp) # Salva endereço de retorno
    sw $s0, 8($sp) # Salva $s0
    sw $s1, 4($sp) # Salva $s1
    sw $s2, 0($sp) # Salva $s2
    
    move $s0, $a0 # Salva file descriptor
    move $s1, $a1 # Salva caractere
    
    ## Criar buffer na pilha
    addi $sp, $sp, -4 # Reserva 4 bytes
    sb $s1, 0($sp) # Escreve caractere
    sb $zero, 1($sp) # Adiciona terminador
    
    ## Escrever no arquivo
    li $v0, 15 # Syscall para escrever
    move $a0, $s0 # File descriptor
    move $a1, $sp # Buffer
    li $a2, 1 # Tamanho = 1 byte
    syscall
    
    ## Liberar buffer
    addi $sp, $sp, 4 # Libera 4 bytes
    
    ## Restaurar registradores
    lw $s2, 0($sp) # Restaura $s2
    lw $s1, 4($sp) # Restaura $s1
    lw $s0, 8($sp) # Restaura $s0
    lw $ra, 12($sp) # Restaura endereço de retorno
    addi $sp, $sp, 16 # Libera espaço da pilha
    jr $ra # Retorna

#### Escreve campo string seguido de delimitador
#### $a0 = file descriptor
#### $a1 = ponteiro para string
escrever_campo_string:
    addi $sp, $sp, -12 # Reserva espaço na pilha
    sw $ra, 8($sp) # Salva endereço de retorno
    sw $s0, 4($sp) # Salva $s0
    sw $s1, 0($sp) # Salva $s1
    
    move $s0, $a0 # Salva file descriptor
    move $s1, $a1 # Salva ponteiro string
    
    ## Escrever string
    move $a0, $s0 # File descriptor
    move $a1, $s1 # String
    jal escrever_string # Chama escrita
    
    ## Escrever delimitador
    move $a0, $s0 # File descriptor
    li $a1, ';' # Caractere ponto-e-vírgula
    jal escrever_delimitador # Chama escrita
    
    ## Restaurar registradores
    lw $s1, 0($sp) # Restaura $s1
    lw $s0, 4($sp) # Restaura $s0
    lw $ra, 8($sp) # Restaura endereço de retorno
    addi $sp, $sp, 12 # Libera espaço da pilha
    jr $ra # Retorna

#### Escreve campo inteiro seguido de delimitador
#### $a0 = file descriptor
#### $a1 = valor inteiro
escrever_campo_inteiro:
    addi $sp, $sp, -12 # Reserva espaço na pilha
    sw $ra, 8($sp) # Salva endereço de retorno
    sw $s0, 4($sp) # Salva $s0
    sw $s1, 0($sp) # Salva $s1
    
    move $s0, $a0 # Salva file descriptor
    move $s1, $a1 # Salva valor
    
    ## Escrever inteiro
    move $a0, $s0 # File descriptor
    move $a1, $s1 # Valor
    jal escrever_inteiro # Chama escrita
    
    ## Escrever delimitador
    move $a0, $s0 # File descriptor
    li $a1, ';' # Caractere ponto-e-vírgula
    jal escrever_delimitador # Chama escrita
    
    ## Restaurar registradores
    lw $s1, 0($sp) # Restaura $s1
    lw $s0, 4($sp) # Restaura $s0
    lw $ra, 8($sp) # Restaura endereço de retorno
    addi $sp, $sp, 12 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÃO CALCULAR E APLICAR JUROS=====
#### Aplica juros de 1% uma vez por minuto
#### Itera sobre todos os clientes ativos
#### Registra transações de juros automaticamente
calcular_juros_automatico:
    addi $sp, $sp, -36 # Reserva espaço na pilha
    sw $ra, 32($sp) # Salva endereço de retorno
    sw $s0, 28($sp) # Salva $s0
    sw $s1, 24($sp) # Salva $s1
    sw $s2, 20($sp) # Salva $s2
    sw $s3, 16($sp) # Salva $s3
    sw $s4, 12($sp) # Salva $s4
    sw $s5, 8($sp) # Salva $s5
    sw $s6, 4($sp) # Salva $s6
    sw $s7, 0($sp) # Salva $s7
    
    ## Obter timestamp atual do sistema
    jal obter_timestamp_atual # Chama função
    move $s3, $v0 # Salva timestamp em $s3
    beqz $s3, fim_calcular_juros # Se data não configurada, sai
    
    ## Inicializar iteração sobre clientes
    la $t0, num_clientes # Carrega contador de clientes
    lw $s1, 0($t0) # Número total de clientes
    li $s0, 0 # Inicializa índice
    
loop_juros_clientes:
    bge $s0, $s1, fim_calcular_juros # Se índice >= total, termina
    
    ## Calcular endereço do cliente
    li $t0, 128 # Tamanho da estrutura cliente
    mul $t1, $s0, $t0 # Offset do cliente
    la $t2, clientes # Base do array
    add $s2, $t2, $t1 # Endereço do cliente
    
    ## Verificar se cliente está ativo
    lw $t3, 84($s2) # Carrega status
    beqz $t3, proximo_cliente_juros # Se inativo, pula
    
    ## Verificar se cliente tem dívida
    lw $s7, 80($s2) # Carrega crédito usado
    blez $s7, proximo_cliente_juros # Se sem dívida, pula
    
    ## Buscar último timestamp de aplicação de juros
    la $a0, 12($s2) # Conta do cliente
    jal buscar_ultimo_juros # Chama busca
    move $s4, $v0 # Salva timestamp anterior
    
    ## Verificar se é primeira aplicação
    beqz $s4, inicializar_juros # Se nunca aplicou, inicializa
    
    ## Extrair data e minuto do timestamp anterior
    li $t0, 100 # Divisor para extrair minuto
    div $s4, $t0 # Divide timestamp anterior
    mflo $t1 # Data e minuto anterior (AAAAMMDDHHMM)
    
    ## Extrair data e minuto do timestamp atual
    div $s3, $t0 # Divide timestamp atual
    mflo $t2 # Data e minuto atual (AAAAMMDDHHMM)
    
    ## Comparar minutos
    beq $t1, $t2, proximo_cliente_juros # Se mesmo minuto, pula
    
    ## Calcular juros de 1%
    li $t0, 100 # Divisor para 1%
    div $s7, $t0 # Divide crédito usado por 100
    mflo $s6 # Valor dos juros
    
    ## Garantir valor mínimo de juros
    beqz $s6, juros_minimo_diario # Se zero, aplica mínimo
    j aplicar_juros_diario # Senão, aplica calculado
    
juros_minimo_diario:
    li $s6, 1 # Mínimo de 1 centavo
    
aplicar_juros_diario:
    ## Salvar estado antes de aplicar
    addi $sp, $sp, -12 # Reserva espaço na pilha
    sw $s2, 8($sp) # Salva ponteiro do cliente
    sw $s6, 4($sp) # Salva valor dos juros
    sw $s3, 0($sp) # Salva timestamp atual
    
    ## Verificar se já está no limite de crédito
    lw $t5, 80($s2) # Carrega crédito usado atual
    lw $t8, 76($s2) # Carrega limite de crédito
    beq $t5, $t8, pular_aplicacao_diario # Se no limite, pula
    
    ## Aplicar juros ao crédito usado
    add $t5, $t5, $s6 # Soma juros ao crédito usado
    
    ## Garantir que não ultrapassa o limite
    ble $t5, $t8, salvar_novo_credito_diario # Se dentro do limite, salva
    move $t5, $t8 # Senão, trunca no limite
    
salvar_novo_credito_diario:
    sw $t5, 80($s2) # Salva novo crédito usado
    
    ## Extrair data do timestamp atual
    lw $s3, 0($sp) # Recupera timestamp
    move $a0, $s3 # Passa timestamp
    jal extrair_data_timestamp # Chama extração
    move $t3, $v0 # Salva data AAAAMMDD
    
    ## Converter data para formato DDMMAAAA
    move $a0, $t3 # Passa data AAAAMMDD
    jal convert_aaaammdd_to_ddmmaaaa # Chama conversão
    move $t3, $v0 # Salva data DDMMAAAA
    
    ## Extrair hora do timestamp atual
    move $a0, $s3 # Passa timestamp
    jal extrair_hora_timestamp # Chama extração
    move $t4, $v0 # Salva hora HHMMSS
    
    ## Registrar transação de juros
    lw $s2, 8($sp) # Recupera ponteiro do cliente
    la $a0, 12($s2) # Conta do cliente
    lw $s6, 4($sp) # Recupera valor dos juros
    move $a1, $s6 # Passa valor para registro
    li $a2, 6 # Tipo 6 = Juros
    move $a3, $t3 # Data DDMMAAAA
    
    addi $sp, $sp, -4 # Reserva espaço para hora
    sw $t4, 0($sp) # Passa hora na pilha
    jal registrar_transacao_credito # Chama registro
    addi $sp, $sp, 4 # Libera espaço da hora
    
pular_aplicacao_diario:
    lw $s3, 0($sp) # Restaura timestamp atual
    addi $sp, $sp, 12 # Libera espaço da pilha
    
    ## Atualizar timestamp da última aplicação
    la $a0, 12($s2) # Conta do cliente
    move $a1, $s3 # Timestamp atual
    jal atualizar_ultimo_juros # Chama atualização
    
    j proximo_cliente_juros # Vai para próximo cliente
    
inicializar_juros:
    ## Primeira aplicação de juros - apenas inicializa timestamp
    la $a0, 12($s2) # Conta do cliente
    move $a1, $s3 # Timestamp atual
    jal atualizar_ultimo_juros # Chama atualização
    
proximo_cliente_juros:
    addi $s0, $s0, 1 # Incrementa índice
    j loop_juros_clientes # Continua loop
    
fim_calcular_juros:
    ## Restaurar registradores salvos
    lw $s7, 0($sp) # Restaura $s7
    lw $s6, 4($sp) # Restaura $s6
    lw $s5, 8($sp) # Restaura $s5
    lw $s4, 12($sp) # Restaura $s4
    lw $s3, 16($sp) # Restaura $s3
    lw $s2, 20($sp) # Restaura $s2
    lw $s1, 24($sp) # Restaura $s1
    lw $s0, 28($sp) # Restaura $s0
    lw $ra, 32($sp) # Restaura endereço de retorno
    addi $sp, $sp, 36 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÃO OBTER TIMESTAMP ATUAL=====
#### Retorna timestamp no formato AAAAMMDDHHMMSS
#### Converte data de DDMMAAAA para AAAAMMDD
#### $v0 = timestamp completo ou 0 se não configurado
obter_timestamp_atual:
    addi $sp, $sp, -8 # Reserva espaço na pilha
    sw $ra, 4($sp) # Salva endereço de retorno
    sw $s0, 0($sp) # Salva $s0
    
    ## Obter data e hora do sistema
    jal obter_data_hora_atual # Chama função
    move $t0, $v0 # Salva data DDMMAAAA
    move $t1, $v1 # Salva hora HHMMSS
    
    ## Verificar se data está configurada
    beqz $t0, timestamp_nao_config # Se zero, não configurada
    beqz $t1, timestamp_nao_config # Se zero, não configurada
    
    ## Extrair DD de DDMMAAAA
    li $t2, 1000000 # Divisor para extrair DD
    div $t0, $t2 # Divide
    mflo $t3 # DD
    mfhi $t4 # MMAAAA
    
    ## Extrair MM de MMAAAA
    li $t2, 10000 # Divisor para extrair MM
    div $t4, $t2 # Divide
    mflo $t5 # MM
    mfhi $t6 # AAAA
    
    ## Reconstruir como AAAAMMDD
    li $t2, 10000 # Multiplicador
    mul $t7, $t6, $t2 # AAAA * 10000
    li $t2, 100 # Multiplicador
    mul $t8, $t5, $t2 # MM * 100
    add $t7, $t7, $t8 # AAAA * 10000 + MM * 100
    add $t7, $t7, $t3 # + DD = AAAAMMDD
    
    ## Combinar data e hora em timestamp
    li $t2, 1000000 # Multiplicador
    mul $v0, $t7, $t2 # AAAAMMDD * 1000000
    add $v0, $v0, $t1 # + HHMMSS = AAAAMMDDHHMMSS
    
    j fim_timestamp # Termina
    
timestamp_nao_config:
    li $v0, 0 # Retorna zero
    
fim_timestamp:
    lw $s0, 0($sp) # Restaura $s0
    lw $ra, 4($sp) # Restaura endereço de retorno
    addi $sp, $sp, 8 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÃO BUSCAR ÚLTIMO TIMESTAMP DE JUROS=====
#### Busca timestamp da última aplicação de juros
#### $a0 = conta do cliente (string)
#### $v0 = timestamp ou 0 se não encontrado
buscar_ultimo_juros:
    addi $sp, $sp, -16 # Reserva espaço na pilha
    sw $ra, 12($sp) # Salva endereço de retorno
    sw $s0, 8($sp) # Salva $s0
    sw $s1, 4($sp) # Salva $s1
    sw $s2, 0($sp) # Salva $s2
    
    move $s0, $a0 # Salva conta
    li $s1, 0 # Inicializa índice
    
    ## Carregar total de clientes
    la $t0, num_clientes # Endereço do contador
    lw $s2, 0($t0) # Total de clientes
    
buscar_juros_loop:
    bge $s1, $s2, buscar_juros_nao_encontrado # Se índice >= total, não encontrou
    
    ## Calcular offset do registro
    li $t0, 12 # Tamanho de cada registro
    mul $t1, $s1, $t0 # Offset = índice * 12
    la $t2, ultimo_calculo_juros # Base do array
    add $t2, $t2, $t1 # Endereço do registro
    
    ## Comparar conta
    move $a0, $s0 # Conta buscada
    move $a1, $t2 # Conta no registro
    jal strcmp # Chama comparação
    beqz $v0, buscar_juros_encontrado # Se iguais, encontrou
    
    addi $s1, $s1, 1 # Incrementa índice
    j buscar_juros_loop # Continua loop
    
buscar_juros_encontrado:
    lw $v0, 8($t2) # Carrega timestamp do offset 8
    j fim_buscar_juros # Termina
    
buscar_juros_nao_encontrado:
    li $v0, 0 # Retorna zero
    
fim_buscar_juros:
    ## Restaurar registradores
    lw $s2, 0($sp) # Restaura $s2
    lw $s1, 4($sp) # Restaura $s1
    lw $s0, 8($sp) # Restaura $s0
    lw $ra, 12($sp) # Restaura endereço de retorno
    addi $sp, $sp, 16 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÃO ATUALIZAR TIMESTAMP DE JUROS=====
#### Atualiza ou cria registro de timestamp de juros
#### $a0 = conta do cliente
#### $a1 = novo timestamp
atualizar_ultimo_juros:
    addi $sp, $sp, -16 # Reserva espaço na pilha
    sw $ra, 12($sp) # Salva endereço de retorno
    sw $s0, 8($sp) # Salva $s0
    sw $s1, 4($sp) # Salva $s1
    sw $s2, 0($sp) # Salva $s2
    
    move $s0, $a0 # Salva conta
    move $s1, $a1 # Salva timestamp
    li $s2, 0 # Inicializa índice
    
    ## Carregar total de clientes
    la $t0, num_clientes # Endereço do contador
    lw $t1, 0($t0) # Total de clientes
    
atualizar_juros_loop:
    bge $s2, $t1, atualizar_juros_novo # Se índice >= total, cria novo
    
    ## Calcular offset do registro
    li $t2, 12 # Tamanho de cada registro
    mul $t3, $s2, $t2 # Offset = índice * 12
    la $t4, ultimo_calculo_juros # Base do array
    add $t4, $t4, $t3 # Endereço do registro
    
    ## Comparar conta
    move $a0, $s0 # Conta buscada
    move $a1, $t4 # Conta no registro
    jal strcmp # Chama comparação
    beqz $v0, atualizar_juros_existente # Se iguais, atualiza
    
    addi $s2, $s2, 1 # Incrementa índice
    j atualizar_juros_loop # Continua loop
    
atualizar_juros_existente:
    sw $s1, 8($t4) # Atualiza timestamp no offset 8
    j fim_atualizar_juros # Termina
    
atualizar_juros_novo:
    ## Criar nova entrada no array
    li $t2, 12 # Tamanho de cada registro
    mul $t3, $s2, $t2 # Offset para novo registro
    la $t4, ultimo_calculo_juros # Base do array
    add $t4, $t4, $t3 # Endereço do novo registro
    
    ## Copiar conta para o registro
    move $a0, $t4 # Destino
    move $a1, $s0 # Origem (conta)
    jal strcpy # Chama cópia
    
    ## Salvar timestamp
    sw $s1, 8($t4) # Salva timestamp no offset 8
    
fim_atualizar_juros:
    ## Restaurar registradores
    lw $s2, 0($sp) # Restaura $s2
    lw $s1, 4($sp) # Restaura $s1
    lw $s0, 8($sp) # Restaura $s0
    lw $ra, 12($sp) # Restaura endereço de retorno
    addi $sp, $sp, 16 # Libera espaço da pilha
    jr $ra # Retorna

# =====FUNÇÕES DE MANIPULAÇÃO DE TIMESTAMP=====

#### Extrai data de timestamp AAAAMMDDHHMMSS
#### $a0 = timestamp completo
#### $v0 = data AAAAMMDD
extrair_data_timestamp:
    li $t0, 1000000 # Divisor
    div $a0, $t0 # Divide timestamp
    mflo $v0 # Resultado = AAAAMMDD
    jr $ra # Retorna

#### Extrai hora de timestamp AAAAMMDDHHMMSS
#### $a0 = timestamp completo
#### $v0 = hora HHMMSS
extrair_hora_timestamp:
    li $t0, 1000000 # Divisor
    div $a0, $t0 # Divide timestamp
    mfhi $v0 # Resto = HHMMSS
    jr $ra # Retorna

#### Converte hora HHMMSS para segundos totais
#### $a0 = hora no formato HHMMSS
#### $v0 = total de segundos
hhmmss_para_segundos:
    ## Extrair horas (HH)
    li $t0, 10000 # Divisor para extrair HH
    div $a0, $t0 # Divide
    mflo $t1 # HH
    mfhi $t2 # MMSS
    
    ## Extrair minutos (MM)
    li $t0, 100 # Divisor para extrair MM
    div $t2, $t0 # Divide
    mflo $t3 # MM
    mfhi $t4 # SS
    
    ## Converter para segundos totais
    li $t0, 3600 # Segundos por hora
    mul $t5, $t1, $t0 # HH * 3600
    li $t0, 60 # Segundos por minuto
    mul $t6, $t3, $t0 # MM * 60
    add $t5, $t5, $t6 # HH*3600 + MM*60
    add $v0, $t5, $t4 # + SS
    jr $ra # Retorna

# =====FUNÇÃO CONVERTER FORMATO DE DATA=====
#### Converte data de AAAAMMDD para DDMMAAAA
#### $a0 = data no formato AAAAMMDD
#### $v0 = data no formato DDMMAAAA
convert_aaaammdd_to_ddmmaaaa:
    ## Extrair AAAA de AAAAMMDD
    li $t0, 10000 # Divisor
    div $a0, $t0 # Divide
    mflo $t1 # AAAA
    mfhi $t2 # MMDD
    
    ## Extrair MM de MMDD
    li $t0, 100 # Divisor
    div $t2, $t0 # Divide
    mflo $t3 # MM
    mfhi $t4 # DD
    
    ## Reconstruir como DDMMAAAA
    li $t0, 1000000 # Multiplicador para DD
    mul $v0, $t4, $t0 # DD * 1000000
    li $t0, 10000 # Multiplicador para MM
    mul $t5, $t3, $t0 # MM * 10000
    add $v0, $v0, $t5 # DD*1000000 + MM*10000
    add $v0, $v0, $t1 # + AAAA = DDMMAAAA
    jr $ra # Retorna