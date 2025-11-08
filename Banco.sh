# (1) Registrar provedores necessários
az provider register --namespace Microsoft.DBforPostgreSQL

# (2) Variáveis
RG="rg-futurestack"
LOCATION="brazilsouth"
PGNAME="pg-rm554773"
PGADMIN="futurestack"
PGADMINPWD="futurestack"
DBNAME="futurestack"
PGHOST="${PGNAME}.postgres.database.azure.com"

# (3) Criar Resource Group (caso não exista)
az group create -n "$RG" -l "$LOCATION"

# (4) Criar PostgreSQL Flexible Server
az postgres flexible-server create \
  -g "$RG" -n "$PGNAME" -l "$LOCATION" \
  --tier Burstable --sku-name Standard_B1ms \
  --storage-size 32 \
  --version 16 \
  --admin-user "$PGADMIN" --admin-password "$PGADMINPWD" \
  --public-access 0.0.0.0-255.255.255.255

# (5) Criar database dentro do servidor Postgres
az postgres flexible-server db create \
  --resource-group "$RG" \
  --server-name "$PGNAME" \
  --database-name "$DBNAME"

echo "BANCO CRIADO COM SUCESSO!"
echo "HOST = $PGHOST"
echo "DATABASE = $DBNAME"
echo "USER = $PGADMIN"
echo "PASSWORD = $PGADMINPWD"
