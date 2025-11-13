# PingasBank - Sistema Bancário em MIPS

Um sistema bancário via CLI (Command Line Interface) desenvolvido inteiramente em Assembly MIPS para a disciplina de Arquitetura e Organização de Computadores. O projeto simula as operações fundamentais de um banco, incluindo gerenciamento de contas, transações de débito, e um sistema de crédito com fatura e juros.

O sistema foi projetado para ser executado no simulador **MARS** e inclui persistência de dados, salvando e recarregando o estado do banco (contas, saldos, transações) em um arquivo de dados (`pingasbank_data.txt`).

## Funcionalidades Principais

  * **Gestão de Clientes:** Cadastro, busca e encerramento de contas.
  * **Conta Corrente (Débito):** Operações de depósito, saque e transferência.
  * **Sistema de Crédito:** Limite de crédito padrão, transferências no crédito e pagamento de fatura.
  * **Extratos:** Emissão de extratos separados para transações de débito e crédito (fatura).
  * **Persistência de Dados:** Capacidade de `salvar` o estado atual do sistema em um arquivo e `recarregar` ao iniciar.
  * **Simulação de Tempo:** O sistema requer a configuração de `data_hora` para registrar transações e aplicar juros.
  * **Cálculo de Juros:** Aplicação automática de juros sobre o saldo devedor do crédito.
  * **Formatação de Dados:** Comandos para formatar o sistema (`formatar`) ou apagar o extrato de uma conta específica (`conta_format`).

## Setup e Execução

### Pré-requisitos

  * **Simulador MARS:** O projeto é compilado e executado inteiramente dentro do [MARS (MIPS Assembler and Runtime Simulator)](https://www.google.com/search?q=http://courses.missouristate.edu/kenvollmar/mars/).

### Configuração Crítica: Diretório de Execução

Para que o sistema de persistência (leitura e escrita no arquivo `pingasbank_data.txt`) funcione corretamente, o simulador MARS **deve ser executado a partir do diretório que contém o arquivo de dados.**

O `pingasbank.asm` usa um caminho relativo (`pingasbank_data.txt`) para salvar e carregar os dados. O MARS, por padrão, usa o diretório onde foi aberto como o "diretório de trabalho".

**Instruções de Execução:**

1.  Clone o repositório.
2.  Coloque o arquivo `MARS.jar` dentro da pasta `app/` do repositório (ou navegue até ela ao abrir o MARS).
3.  Garanta que o `pingasbank.asm` e o `pingasbank_data.txt` (mesmo que vazio) estejam nesta mesma pasta `app/`.
4.  Abra o MARS, carregue o `pingasbank.asm`, compile (Assemble) e execute.

Se o MARS for aberto de outro local, ele não encontrará o `pingasbank_data.txt` para carregar os dados e criará um novo arquivo de salvamento em um local inesperado.

## Fluxo de Uso Recomendado

O sistema possui uma sequência de execução lógica para que as operações funcionem:

1.  **`data_hora` (Obrigatório):** O sistema **DEVE** ser iniciado com o comando `data_hora`. Nenhuma transação (depósito, saque, etc.) será registrada se a data e hora não estiverem configuradas.
2.  **`conta_cadastrar`:** Crie uma ou mais contas de cliente.
3.  **`depositar` / `transferir_...`:** Adicione fundos às contas.
4.  **Operações:** Realize as demais operações (saque, extrato, etc.).

## Referência de Comandos

O sistema é operado via CLI, aceitando comandos no formato `comando-<param1>-<param2>-...`.

-----

### 1\. Sistema e Persistência

Comandos para gerenciar o estado do simulador e a persistência dos dados.

`data_hora-<DDMMAAAA>-<HHMMSS>`

  * **Descrição:** Configura a data e hora iniciais do sistema. **Este é o primeiro comando que deve ser executado.**
  * **Exemplo:** `data_hora-12112025-224500`

`salvar`

  * **Descrição:** Salva o estado atual de todas as contas e transações no arquivo `pingasbank_data.txt`.

`recarregar`

  * **Descrição:** Limpa a memória atual e recarrega os dados salvos a partir do `pingasbank_data.txt`. (Isso também acontece automaticamente ao iniciar o programa).

`formatar`

  * **Descrição:** Apaga **TODOS** os dados do sistema (contas, transações, etc.) da memória, reiniciando o banco. Requer confirmação (S/N).

`encerrar`

  * **Descrição:** Termina a execução do simulador.

-----

### 2\. Gestão de Contas

Comandos para administrar clientes e seus limites.

`conta_cadastrar-<cpf>-<conta_base>-<nome>`

  * **Descrição:** Cadastra um novo cliente.
  * **Parâmetros:**
      * `<cpf>`: CPF do cliente (ex: 12345678901).
      * `<conta_base>`: Número da conta com 6 dígitos (ex: 123456). O dígito verificador (DV) é calculado e adicionado automaticamente.
      * `<nome>`: Nome completo do cliente.
  * **Exemplo:** `conta_cadastrar-12345678901-123456-João Silva`

`conta_buscar-<conta_completa>`

  * **Descrição:** Exibe os detalhes de uma conta (CPF, Nome, Saldo, Limite, Crédito Usado).
  * **Parâmetros:**
      * `<conta_completa>`: O número da conta com o DV (ex: `123456-0` ou `1234560`).
  * **Exemplo:** `conta_buscar-123456-0`

`conta_fechar-<conta_completa>`

  * **Descrição:** Desativa uma conta. A conta só pode ser fechada se o saldo (débito e crédito) estiver zerado.
  * **Exemplo:** `conta_fechar-123456-0`

`alterar_limite-<conta_completa>-<novo_limite_centavos>`

  * **Descrição:** Altera o limite de crédito de um cliente.
  * **Exemplo:** `alterar_limite-123456-0-200000` (Altera o limite para R$ 2000,00)

`conta_format-<conta_completa>`

  * **Descrição:** Apaga **todas as transações de débito (extrato da conta corrente)** de um cliente específico. Não afeta o saldo. Requer confirmação (S/N).
  * **Exemplo:** `conta_format-123456-0`

-----

### 3\. Operações de Débito (Conta Corrente)

Operações que afetam o saldo principal (conta corrente).

`depositar-<conta_completa>-<valor_centavos>`

  * **Descrição:** Adiciona fundos ao saldo de débito de uma conta.
  * **Exemplo:** `depositar-123456-0-50000` (Deposita R$ 500,00)

`sacar-<conta_completa>-<valor_centavos>`

  * **Descrição:** Retira fundos do saldo de débito, se houver saldo suficiente.
  * **Exemplo:** `sacar-123456-0-25000` (Saca R$ 250,00)

`transferir_debito-<conta_origem>-<conta_destino>-<valor_centavos>`

  * **Descrição:** Transfere fundos do saldo de débito da conta de origem para o saldo de débito da conta de destino.
  * **Exemplo:** `transferir_debito-123456-0-123457-2-10000`

`debito_extrato-<conta_completa>`

  * **Descrição:** Exibe o extrato da conta corrente (transações de débito).
  * **Exemplo:** `debito_extrato-123456-0`

-----

### 4\. Operações de Crédito (Fatura)

Operações que utilizam o limite de crédito e afetam a fatura.

`transferir_credito-<conta_destino>-<conta_origem>-<valor_centavos>`

  * **Descrição:** Transfere fundos usando o limite de crédito da conta de **origem** para o saldo de débito (conta corrente) da conta de **destino**. Aumenta o "Crédito Usado" da origem.
  * **Exemplo:** `transferir_credito-123456-0-123457-2-10000`

`pagar_fatura-<conta_completa>-<valor_centavos>-<metodo>`

  * **Descrição:** Paga parte ou o total do "Crédito Usado" (dívida da fatura).
  * **Parâmetros:**
      * `<metodo>`: `S` (usa o Saldo de débito da própria conta) ou `E` (pagamento Externo, ex: boleto).
  * **Exemplo (Externo):** `pagar_fatura-123457-2-10000-E`
  * **Exemplo (Saldo):** `pagar_fatura-123457-2-10000-S`

`credito_extrato-<conta_completa>`

  * **Descrição:** Exibe o extrato de crédito (fatura), detalhando o limite total, o valor usado, o disponível e todas as transações de crédito/pagamento/juros.
  * **Exemplo:** `credito_extrato-123457-2`

## Integrantes

  * Emanuel José Tenório Rodrigues
  * Gustavo Henrique Evangelista de Souza
  * Heitor Santana
  * João Ricardo de Andrade Ferreira Barbosa
