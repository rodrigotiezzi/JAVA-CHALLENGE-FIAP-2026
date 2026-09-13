# ☁️ Deploy na Azure — Clyvo Care

## 📌 Descrição da Solução

A ideia principal do **Clyvo Care** é uma **coleira inteligente para pets** que, por meio da leitura de batimentos cardíacos e outros sinais vitais do animal, ajuda o tutor a entender o estado emocional e físico do pet — se está feliz, triste, estressado ou com fome — permitindo agir antes que isso vire um problema de saúde.

Para sustentar essa proposta, foi desenvolvida uma **API RESTful em Java com Spring Boot**, com persistência em Azure SQL Database, que funciona como o back-end de gestão da solução: centraliza o cadastro de **tutores**, **pets** e **veterinários**, permite criar e gerenciar **agendamentos** de consultas (com controle de status: agendado, realizado ou cancelado) — inclusive os originados a partir de alertas da coleira — e registrar o **histórico clínico** de cada atendimento (diagnóstico, tratamento e observações).

A solução expõe endpoints REST documentados via Swagger/OpenAPI, com suporte a busca por parâmetros, paginação e ordenação de resultados, validação de dados de entrada e tratamento global de exceções — cobrindo todo o fluxo de uma clínica veterinária, do cadastro do tutor até o encerramento da consulta.

## 💼 Descrição dos Benefícios para o Negócio

- **Organização centralizada**: elimina planilhas e controles manuais, unificando tutores, pets, veterinários e agendamentos em um único sistema.
- **Redução de erros e retrabalho**: validações automáticas e regras de negócio (ex.: impedir agendamentos conflitantes, exigir dados obrigatórios) diminuem falhas de cadastro e de rotina operacional.
- **Rastreabilidade do histórico clínico**: cada consulta fica vinculada ao seu agendamento, com diagnóstico, tratamento e observações, permitindo consultar rapidamente o histórico de saúde de um pet.
- **Agilidade no atendimento**: buscas por nome, CPF, espécie, área de atuação ou status de agendamento tornam a rotina da clínica mais rápida para recepcionistas e veterinários.
- **Escalabilidade e disponibilidade**: hospedagem em nuvem (Azure App Service + Azure SQL Database) permite crescimento do volume de dados e de acessos sem necessidade de infraestrutura própria.
- **Integração facilitada**: por ser uma API REST documentada (Swagger) e com coleção Postman disponível, o sistema pode ser integrado a outros sistemas (site, app mobile, painéis administrativos) com baixo esforço.

---

## Arquitetura

<img width="1393" height="755" alt="image" src="https://github.com/user-attachments/assets/d014b145-9cc2-42e2-970a-810e3278481c" />

---

## Variáveis

```bash
# Gerais
RESOURCE_GROUP_NAME="rg-clyvo-care"
LOCATION="southafricanorth"

# Web App
WEBAPP_NAME="webapp-clyvo-care"
APP_SERVICE_PLAN="plan-clyvo-care"
RUNTIME="JAVA:21-java21"

# Banco de Dados (Azure SQL)
SQL_SERVER_NAME="sqlserver-clyvo-care"
SQL_DB_NAME="clyvo-caredb"
SQL_ADMIN_USER="dbadmin"
SQL_ADMIN_PASSWORD="FIAP@2tdspo2026"

# GitHub
GITHUB_REPO_NAME="rodrigotiezzi/JAVA-CHALLENGE-FIAP-2026"
BRANCH="master"
```

---

## Comandos

### 1. Resource Group

```bash
az group create --name rg-clyvo-care --location "southafricanorth"
```

### 2. Banco de dados (Azure SQL)

```bash
az sql server create \
  --name "sqlserver-clyvo-care" \
  --resource-group "rg-clyvo-care" \
  --location "southafricanorth" \
  --admin-user "dbadmin" \
  --admin-password "FIAP@2tdspo2026"

az sql db create \
  --resource-group rg-clyvo-care \
  --server sqlserver-clyvo-care \
  --name clyvo-caredb \
  --service-objective Basic

az sql server firewall-rule create \
  --resource-group rg-clyvo-care \
  --server sqlserver-clyvo-care \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255
```

### 3. App Service Plan + Web App

```bash
az appservice plan create \
  --name plan-clyvo-care \
  --resource-group rg-clyvo-care \
  --location southafricanorth \
  --sku F1 \
  --is-linux

az webapp create \
  --name webapp-clyvo-care \
  --resource-group rg-clyvo-care \
  --plan plan-clyvo-care \
  --runtime "JAVA:21-java21"

az resource update \
  --resource-group rg-clyvo-care \
  --namespace Microsoft.Web \
  --resource-type basicPublishingCredentialsPolicies \
  --name scm \
  --parent sites/webapp-clyvo-care \
  --set properties.allow=true
```

### 4. Variáveis de ambiente do Web App

```bash
az webapp config appsettings set \
  --name "webapp-clyvo-care" \
  --resource-group "rg-clyvo-care" \
  --settings \
    SPRING_DATASOURCE_USERNAME="dbadmin" \
    SPRING_DATASOURCE_PASSWORD="FIAP@2tdspo2026" \
    SPRING_DATASOURCE_URL="jdbc:sqlserver://sqlserver-clyvo-care.database.windows.net:1433;database=clyvo-caredb;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

az webapp restart --name webapp-clyvo-care --resource-group rg-clyvo-care
```

### 5. Conectar o repositório GitHub (CI/CD)

```bash
az webapp deployment github-actions add \
  --name webapp-clyvo-care \
  --resource-group rg-clyvo-care \
  --repo rodrigotiezzi/JAVA-CHALLENGE-FIAP-2026 \
  --branch "master" \
  --login-with-github
```


Esse comando já cria o workflow `.yml` em `.github/workflows/` e o secret do publish profile automaticamente.
Dentro do repositório do GitHub, vá em Settings -> Secrets and variables -> Actions.
Clique em New repository secret.
Adicione as 3 variáveis (pegue os mesmos valores usados na Azure CLI):
SPRING_DATASOURCE_URL -> jdbc:sqlserver://sqlserver-clyvo-care.database.windows.net:1433;database=clyvo-caredb;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
SPRING_DATASOURCE_USERNAME -> dbadmin
SPRING_DATASOURCE_PASSWORD -> FIAP@2tdspo2026


Agora vamos fazer login! 
Se so entrarmos na pagina, vamos ter um tela em branco. 
É necessario digitar na url "/web/login"
EX:https://webapp-clyvo-care.azurewebsites.net/web/login

O usuario é admin 
e a senha é admin123

