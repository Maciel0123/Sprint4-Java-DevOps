###
### Variáveis
###
grupoRecursos=rg-futurestack
# Altere para seu RM
rm=rm554773
nomeACR="acr$rm"
imageACR="acr$rm.azurecr.io/acr:latest"
serverACR="acr$rm.azurecr.io"
userACR=$(az acr credential show --name $nomeACR --query "username" -o tsv)
passACR=$(az acr credential show --name $nomeACR --query "passwords[0].value" -o tsv)
nomeACI="aci$rm"
# Altere a Região conforme orientação do Prof
regiao=eastus
#Outras opções:
#brazilsouth
#eastus2
#westus
#westus2
planService=planACRWebApp
sku=F1
appName="acrwebapp$rm"
imageACR="acr$rm.azurecr.io/acr:latest"
port=80

###
### Criação do ACI
###
az container create \
    --resource-group $grupoRecursos \
    --name $nomeACI \
    --image $imageACR \
    --cpu 1 \
    --memory 1 \
    --os-type Linux \
    --registry-login-server $serverACR \
    --registry-username $userACR \
    --registry-password $passACR \
    --dns-name-label $nomeACI \
    --restart-policy Always \
    --ports 8080

###
### Criação do Web App
###

### Cria o Plano de Serviço se não existir
if az appservice plan show --name $planService --resource-group $grupoRecursos &> /dev/null; then
    echo "O plano de serviço $planService já existe"
else
    az appservice plan create --name $planService --resource-group $grupoRecursos --is-linux --sku $sku
    echo "Plano de serviço $planService criado com sucesso"
fi 
### Cria o Serviço de Aplicativo se não existir
if az webapp show --name $appName --resource-group $grupoRecursos &> /dev/null; then
    echo "O Serviço de Aplicativo $appName já existe"
else
    az webapp create --resource-group $grupoRecursos --plan $planService --name  $appName --deployment-container-image-name $imageACR
    echo "Serviço de Aplicativo $appName criado com sucesso"
fi
### Cria uma variável definindo a porta do Serviço de Aplicativo
if az webapp show --name $appName --resource-group $grupoRecursos > /dev/null 2>&1; then
    az webapp config appsettings set --resource-group $grupoRecursos --name $appName --settings WEBSITES_PORT=$port
    echo "Serviço de Aplicativo $appName configurado para escutar na porta $port com sucesso"
fi
