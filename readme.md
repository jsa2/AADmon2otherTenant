# Create Logs redirection from another tenant with Azure CLI in Bash

I often need to send logs from a demo tenant which does not have Azure Subscription to Log Analytics. 

✅ This guide is based on [deep-diver-azure-ad-b2c-azure-monitor](https://securecloud.blog/2020/05/30/deep-diver-azure-ad-b2c-azure-monitor-integration-configuration-and-delegation-explained/) which is based on Azure AD B2C guide for similar use case

## pre-reqs
- Azure Cloud shell (bash) - or suitable linux distribution and Azure CLI installed 

## Guide
**In the AAD tenant where you want the logs to be redirected FROM**
1. Create group and take the note of the objectId
2. Copy tenantId of the group

**In The subscription where the logs will be redirected TO**

3. Create new RG and Log Analytics space, and take not of the resource group [depl.sh](depl.sh)

```sh
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
```

4. Populate [redirectLogsParams.json](redirectLogsParams.json) with the values gathered in steps 1-2-3

```
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "mspOfferName": {
            "value": "SecureCloudBlog AAD log redirect"
        },
        "rgName": {
            "value": "rg-redirectlogs-11978"
        },
        "mspOfferDescription": {
            "value": "Provide Azure Monitor for B2C resource"
        },
        "managedByTenantId": {
            "value": "<✅tenantId"
        },
        "authorizations": {
            "value": [
                {
                    "principalId": "<✅GroupObjectId>",
                    "principalIdDisplayName": " Contributor",
                    "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c"
                }
            ]
        }
    }
}
```

5. Create the deployment

```sh
az deployment create --location $location --template-file redirectLogsTemplate.json  --parameters @redirectLogsParams.json
```

**In the AAD tenant where you want the logs to be redirected FROM**

6. Go to Azure AD and send the logs you want to be exported to the log analytics workspace 
   

[https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview ](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/DiagnosticSettings)


![image](https://user-images.githubusercontent.com/58001986/152632523-9e3d7a4c-6bcb-4f77-9d1e-926563af1a9f.png)





