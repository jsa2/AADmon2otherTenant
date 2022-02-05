
#Define starting variables
rnd=$RANDOM
autodg=redirectLogs-$rnd
rg=RG-redirectLogs-$rnd
location=westeurope

# Create Resource Group
az group create -n $rg \
-l $location \
--tags="svc=autoDiag"

az monitor log-analytics workspace create --location $location -g $rg  -n laws${autodg}

az deployment create --location $location --template-file redirectLogsTemplate.json  --parameters @redirectLogsParams.json