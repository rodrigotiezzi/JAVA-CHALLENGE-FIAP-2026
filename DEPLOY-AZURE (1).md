# ☁️ Deploy na Azure — Clyvo Care

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
SQL_ADMIN_PASSWORD="<definida localmente / no Azure Key Vault, nunca commitada>"

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
  --name sqlserver-clyvo-care \
  --resource-group rg-clyvo-care \
  --location southafricanorth \
  --admin-user dbadmin \
  --admin-password SUA_SENHA_AQUI

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
    SPRING_DATASOURCE_PASSWORD="SUA_SENHA_AQUI" \
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
SPRING_DATASOURCE_URL -> jdbc:sqlserver://sqlserver-clyvo-caredatabase.windows.net:1433;database=clyvo-caredb;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
SPRING_DATASOURCE_USERNAME -> dbadmin
SPRING_DATASOURCE_PASSWORD -> SUA_SENHA_AQUI


