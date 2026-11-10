# ================================================================= #
#   AZURE CLI: ENTRENAMIENTO PRÁCTICO DE COMANDOS AZ DESDE TERMINAL  #
# ================================================================= #
# IMPORTANTE: guardar como UTF-8 con BOM (o usar PowerShell 7).
#
# Cómo funciona:
#   azcli                te lanza 5 retos aleatorios (mezcla de servicios)
#   azcli -Preguntas 10  más retos de golpe
#   azcli -Modo VM       solo retos de VMs (también: Grupo, AppService, AKS, Red, IAM, Storage, Monitor, General)
#   azcli -Repaso         solo lo que toca repasar hoy (Leitner)
#
# Cada reto te pide que escribas el comando az real.
# Depende de Motor.ps1 (progreso y repaso espaciado).

# Por si se carga este archivo suelto (sin el tema)
if (-not (Get-Command Write-Cyber -ErrorAction SilentlyContinue)) {
    function Write-Cyber {
        param([string]$Text, [string]$Color, [switch]$NoNewline)
        Write-Host $Text -NoNewline:$NoNewline
    }
}

# Registrar el "mundo" Azure en el motor
if ($global:NombreMundo -and -not $global:NombreMundo.ContainsKey('Azure')) {
    $global:NombreMundo['Azure'] = 'terminal con Azure CLI'
}

# ================================================================= #
#                    BANCO DE RETOS AZURE CLI                        #
# ================================================================= #

function Get-AzureCliBanco {
    @(
        # ─────────────────────────────────────────────────────────────
        #  Grupo de recursos
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-group-crear'; Tipo = 'Grupo'
            Tarea = 'Crea un grupo de recursos llamado "rg-produccion" en la región "westeurope".'
            Exp = 'Todo en Azure vive dentro de un grupo de recursos. Es lo primero que se crea y lo último que se borra.'
            R = @{ Azure = @{ Ej = 'az group create --name rg-produccion --location westeurope'; Rx = @(
                '^\s*az\s+group\s+create\s+--name\s+rg-produccion\s+--location\s+westeurope'
                '^\s*az\s+group\s+create\s+-n\s+rg-produccion\s+-l\s+westeurope'
                '^\s*az\s+group\s+create\s+--location\s+westeurope\s+--name\s+rg-produccion'
            )}}
        },
        @{
            Id = 'az-group-listar'; Tipo = 'Grupo'
            Tarea = 'Lista todos los grupos de recursos de tu suscripción.'
            Exp = 'az group list muestra todos los grupos con su ubicación y estado. Añade --output table para verlo más claro.'
            R = @{ Azure = @{ Ej = 'az group list'; Rx = @(
                '^\s*az\s+group\s+list'
            )}}
        },
        @{
            Id = 'az-group-borrar'; Tipo = 'Grupo'
            Tarea = 'Borra el grupo de recursos "rg-pruebas" y todo lo que tenga dentro (sin pedir confirmación).'
            Exp = 'az group delete --yes borra TODOS los recursos del grupo. Es la forma más limpia de limpiar después de practicar.'
            R = @{ Azure = @{ Ej = 'az group delete --name rg-pruebas --yes --no-wait'; Rx = @(
                '^\s*az\s+group\s+delete\s+--name\s+rg-pruebas\s+--yes'
                '^\s*az\s+group\s+delete\s+-n\s+rg-pruebas\s+--yes'
                '^\s*az\s+group\s+delete\s+--name\s+rg-pruebas\s+-y'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Máquinas virtuales (VM)
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-vm-crear'; Tipo = 'VM'
            Tarea = 'Crea una VM llamada "srv-web" en el grupo "rg-produccion" con imagen Ubuntu LTS y tamaño Standard_B1s. Genera las claves SSH automáticamente.'
            Exp = 'az vm create es el equivalente a run-instances de AWS. Standard_B1s es el tamaño más barato para pruebas.'
            R = @{ Azure = @{ Ej = 'az vm create --resource-group rg-produccion --name srv-web --image Ubuntu2204 --size Standard_B1s --generate-ssh-keys'; Rx = @(
                '^\s*az\s+vm\s+create.*--resource-group\s+rg-produccion.*--name\s+srv-web.*--image\s+\S+.*--generate-ssh-keys'
                '^\s*az\s+vm\s+create.*-g\s+rg-produccion.*-n\s+srv-web.*--image\s+\S+.*--generate-ssh-keys'
            )}}
        },
        @{
            Id = 'az-vm-listar'; Tipo = 'VM'
            Tarea = 'Lista todas las VMs del grupo "rg-produccion" mostrando nombre, estado y IP.'
            Exp = 'az vm list con -d (--show-details) añade la IP pública y el estado de alimentación.'
            R = @{ Azure = @{ Ej = 'az vm list --resource-group rg-produccion --show-details --output table'; Rx = @(
                '^\s*az\s+vm\s+list.*--(resource-group|g)\s+rg-produccion.*(-d|--show-details)'
                '^\s*az\s+vm\s+list.*(-d|--show-details).*--(resource-group|g)\s+rg-produccion'
            )}}
        },
        @{
            Id = 'az-vm-parar'; Tipo = 'VM'
            Tarea = 'Para la VM "srv-web" del grupo "rg-produccion" y libera los recursos (para no pagar).'
            Exp = 'az vm deallocate para la VM y libera el cómputo (no cobra). Solo az vm stop la para pero SIGUE cobrando.'
            R = @{ Azure = @{ Ej = 'az vm deallocate --resource-group rg-produccion --name srv-web'; Rx = @(
                '^\s*az\s+vm\s+deallocate.*--(resource-group|g)\s+rg-produccion.*--(name|n)\s+srv-web'
                '^\s*az\s+vm\s+deallocate.*--(name|n)\s+srv-web.*--(resource-group|g)\s+rg-produccion'
            )}}
        },
        @{
            Id = 'az-vm-arrancar'; Tipo = 'VM'
            Tarea = 'Arranca la VM "srv-web" del grupo "rg-produccion".'
            Exp = 'az vm start enciende una VM parada o desasignada.'
            R = @{ Azure = @{ Ej = 'az vm start --resource-group rg-produccion --name srv-web'; Rx = @(
                '^\s*az\s+vm\s+start.*--(resource-group|g)\s+rg-produccion.*--(name|n)\s+srv-web'
                '^\s*az\s+vm\s+start.*--(name|n)\s+srv-web.*--(resource-group|g)\s+rg-produccion'
            )}}
        },
        @{
            Id = 'az-vm-borrar'; Tipo = 'VM'
            Tarea = 'Borra la VM "srv-web" del grupo "rg-produccion" sin pedir confirmación.'
            Exp = 'az vm delete borra la VM pero puede dejar discos y NICs huérfanos. Borrar el grupo entero es más limpio para prácticas.'
            R = @{ Azure = @{ Ej = 'az vm delete --resource-group rg-produccion --name srv-web --yes'; Rx = @(
                '^\s*az\s+vm\s+delete.*--(resource-group|g)\s+rg-produccion.*--(name|n)\s+srv-web.*--yes'
                '^\s*az\s+vm\s+delete.*--(name|n)\s+srv-web.*--yes'
            )}}
        },
        @{
            Id = 'az-vm-ip'; Tipo = 'VM'
            Tarea = 'Obtén la IP pública de la VM "srv-web" del grupo "rg-produccion".'
            Exp = 'az vm show con --query extrae campos concretos. También puedes usar az vm list-ip-addresses.'
            R = @{ Azure = @{ Ej = 'az vm list-ip-addresses --resource-group rg-produccion --name srv-web --output table'; Rx = @(
                '^\s*az\s+vm\s+list-ip-addresses.*--(resource-group|g)\s+rg-produccion.*--(name|n)\s+srv-web'
                '^\s*az\s+vm\s+show.*--(resource-group|g)\s+rg-produccion.*--(name|n)\s+srv-web.*--query.*publicIp'
            )}}
        },
        @{
            Id = 'az-vm-abrir-puerto'; Tipo = 'VM'
            Tarea = 'Abre el puerto 80 (HTTP) en la VM "srv-web" del grupo "rg-produccion".'
            Exp = 'az vm open-port es un atajo que crea una regla NSG. En producción es mejor gestionar los NSG directamente.'
            R = @{ Azure = @{ Ej = 'az vm open-port --resource-group rg-produccion --name srv-web --port 80'; Rx = @(
                '^\s*az\s+vm\s+open-port.*--(resource-group|g)\s+rg-produccion.*--(name|n)\s+srv-web.*--port\s+80'
                '^\s*az\s+vm\s+open-port.*--port\s+80.*--(name|n)\s+srv-web'
            )}}
        },
        @{
            Id = 'az-vm-listar-tamanos'; Tipo = 'VM'
            Tarea = 'Lista los tamaños de VM disponibles en la región "westeurope".'
            Exp = 'az vm list-sizes muestra CPU, RAM y disco de cada tamaño. Útil para elegir antes de crear.'
            R = @{ Azure = @{ Ej = 'az vm list-sizes --location westeurope --output table'; Rx = @(
                '^\s*az\s+vm\s+list-sizes.*--location\s+westeurope'
                '^\s*az\s+vm\s+list-sizes.*-l\s+westeurope'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  App Service (web apps)
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-appservice-plan'; Tipo = 'AppService'
            Tarea = 'Crea un plan de App Service llamado "plan-web" en el grupo "rg-produccion" con SKU gratuito (F1) y Linux.'
            Exp = 'El plan define el hardware. F1 es gratuito (con limitaciones). --is-linux elige contenedores Linux.'
            R = @{ Azure = @{ Ej = 'az appservice plan create --name plan-web --resource-group rg-produccion --sku F1 --is-linux'; Rx = @(
                '^\s*az\s+appservice\s+plan\s+create.*--name\s+plan-web.*--sku\s+F1.*--is-linux'
                '^\s*az\s+appservice\s+plan\s+create.*-n\s+plan-web.*--sku\s+F1.*--is-linux'
            )}}
        },
        @{
            Id = 'az-webapp-crear'; Tipo = 'AppService'
            Tarea = 'Crea una web app llamada "mi-api-prod" en el grupo "rg-produccion", plan "plan-web", con runtime Node 18 LTS.'
            Exp = 'az webapp create despliega la app sobre un plan existente. El runtime se indica con --runtime.'
            R = @{ Azure = @{ Ej = 'az webapp create --name mi-api-prod --resource-group rg-produccion --plan plan-web --runtime "NODE:18-lts"'; Rx = @(
                '^\s*az\s+webapp\s+create.*--name\s+mi-api-prod.*--plan\s+plan-web.*--runtime'
                '^\s*az\s+webapp\s+create.*-n\s+mi-api-prod.*--plan\s+plan-web.*--runtime'
            )}}
        },
        @{
            Id = 'az-webapp-listar'; Tipo = 'AppService'
            Tarea = 'Lista todas las web apps del grupo "rg-produccion".'
            Exp = 'az webapp list muestra nombre, URL, estado y plan de cada app.'
            R = @{ Azure = @{ Ej = 'az webapp list --resource-group rg-produccion --output table'; Rx = @(
                '^\s*az\s+webapp\s+list.*--(resource-group|g)\s+rg-produccion'
            )}}
        },
        @{
            Id = 'az-webapp-deploy-zip'; Tipo = 'AppService'
            Tarea = 'Despliega el archivo "app.zip" en la web app "mi-api-prod" del grupo "rg-produccion".'
            Exp = 'az webapp deploy con --src-path sube un zip y lo despliega. Es la forma más rápida de deploy desde terminal.'
            R = @{ Azure = @{ Ej = 'az webapp deploy --resource-group rg-produccion --name mi-api-prod --src-path app.zip'; Rx = @(
                '^\s*az\s+webapp\s+deploy.*--(resource-group|g)\s+rg-produccion.*--name\s+mi-api-prod.*--src-path\s+app\.zip'
                '^\s*az\s+webapp\s+deployment\s+source\s+config-zip.*--name\s+mi-api-prod.*--src\s+app\.zip'
            )}}
        },
        @{
            Id = 'az-webapp-logs'; Tipo = 'AppService'
            Tarea = 'Muestra los logs en tiempo real de la web app "mi-api-prod" del grupo "rg-produccion".'
            Exp = 'az webapp log tail es como un tail -f de los logs de tu app. Ctrl+C para salir.'
            R = @{ Azure = @{ Ej = 'az webapp log tail --resource-group rg-produccion --name mi-api-prod'; Rx = @(
                '^\s*az\s+webapp\s+log\s+tail.*--(resource-group|g)\s+rg-produccion.*--name\s+mi-api-prod'
                '^\s*az\s+webapp\s+log\s+tail.*--name\s+mi-api-prod'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  AKS — Kubernetes
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-aks-crear'; Tipo = 'AKS'
            Tarea = 'Crea un clúster AKS llamado "k8s-produccion" en el grupo "rg-produccion" con 2 nodos.'
            Exp = 'az aks create despliega un clúster Kubernetes gestionado. --node-count define cuántos nodos worker.'
            R = @{ Azure = @{ Ej = 'az aks create --resource-group rg-produccion --name k8s-produccion --node-count 2 --generate-ssh-keys'; Rx = @(
                '^\s*az\s+aks\s+create.*--(resource-group|g)\s+rg-produccion.*--name\s+k8s-produccion.*--node-count\s+2'
                '^\s*az\s+aks\s+create.*--name\s+k8s-produccion.*--node-count\s+2'
            )}}
        },
        @{
            Id = 'az-aks-credenciales'; Tipo = 'AKS'
            Tarea = 'Descarga las credenciales del clúster "k8s-produccion" para poder usar kubectl.'
            Exp = 'get-credentials configura tu ~/.kube/config con el contexto del clúster. Después kubectl ya funciona.'
            R = @{ Azure = @{ Ej = 'az aks get-credentials --resource-group rg-produccion --name k8s-produccion'; Rx = @(
                '^\s*az\s+aks\s+get-credentials.*--(resource-group|g)\s+rg-produccion.*--name\s+k8s-produccion'
                '^\s*az\s+aks\s+get-credentials.*--name\s+k8s-produccion'
            )}}
        },
        @{
            Id = 'az-aks-escalar'; Tipo = 'AKS'
            Tarea = 'Escala el node pool del clúster "k8s-produccion" a 4 nodos.'
            Exp = 'az aks scale cambia el número de nodos worker. Más nodos = más capacidad = más coste.'
            R = @{ Azure = @{ Ej = 'az aks scale --resource-group rg-produccion --name k8s-produccion --node-count 4'; Rx = @(
                '^\s*az\s+aks\s+scale.*--name\s+k8s-produccion.*--node-count\s+4'
            )}}
        },
        @{
            Id = 'az-aks-borrar'; Tipo = 'AKS'
            Tarea = 'Borra el clúster AKS "k8s-produccion" sin pedir confirmación.'
            Exp = 'az aks delete destruye el clúster y sus nodos. Los recursos persistentes (discos, IPs) pueden quedar huérfanos.'
            R = @{ Azure = @{ Ej = 'az aks delete --resource-group rg-produccion --name k8s-produccion --yes'; Rx = @(
                '^\s*az\s+aks\s+delete.*--name\s+k8s-produccion.*--yes'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Red (VNet, NSG, IP)
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-vnet-crear'; Tipo = 'Red'
            Tarea = 'Crea una red virtual "vnet-prod" con rango 10.0.0.0/16 y una subnet "subnet-web" con rango 10.0.1.0/24 en el grupo "rg-produccion".'
            Exp = 'az network vnet create puede crear la VNet y la primera subnet de golpe con --subnet-name y --subnet-prefix.'
            R = @{ Azure = @{ Ej = 'az network vnet create --resource-group rg-produccion --name vnet-prod --address-prefix 10.0.0.0/16 --subnet-name subnet-web --subnet-prefix 10.0.1.0/24'; Rx = @(
                '^\s*az\s+network\s+vnet\s+create.*--name\s+vnet-prod.*--address-prefix.*10\.0\.0\.0/16.*--subnet-name\s+subnet-web'
            )}}
        },
        @{
            Id = 'az-nsg-crear'; Tipo = 'Red'
            Tarea = 'Crea un Network Security Group llamado "nsg-web" en el grupo "rg-produccion".'
            Exp = 'Un NSG es el firewall de Azure. Se crea vacío y luego se le añaden reglas de entrada/salida.'
            R = @{ Azure = @{ Ej = 'az network nsg create --resource-group rg-produccion --name nsg-web'; Rx = @(
                '^\s*az\s+network\s+nsg\s+create.*--(resource-group|g)\s+rg-produccion.*--name\s+nsg-web'
            )}}
        },
        @{
            Id = 'az-nsg-regla-http'; Tipo = 'Red'
            Tarea = 'Añade una regla al NSG "nsg-web" que permita tráfico HTTP entrante (puerto 80, prioridad 100).'
            Exp = 'Las reglas NSG tienen prioridad (100-4096, menor = más prioritaria). --access Allow/Deny, --direction Inbound/Outbound.'
            R = @{ Azure = @{ Ej = 'az network nsg rule create --resource-group rg-produccion --nsg-name nsg-web --name AllowHTTP --priority 100 --destination-port-ranges 80 --access Allow --protocol Tcp --direction Inbound'; Rx = @(
                '^\s*az\s+network\s+nsg\s+rule\s+create.*--nsg-name\s+nsg-web.*--priority\s+100.*--destination-port-ranges\s+80.*--access\s+Allow'
            )}}
        },
        @{
            Id = 'az-ip-crear'; Tipo = 'Red'
            Tarea = 'Crea una IP pública estática llamada "ip-web" en el grupo "rg-produccion".'
            Exp = 'Una IP pública estática no cambia al reiniciar la VM. --allocation-method Static la fija.'
            R = @{ Azure = @{ Ej = 'az network public-ip create --resource-group rg-produccion --name ip-web --allocation-method Static'; Rx = @(
                '^\s*az\s+network\s+public-ip\s+create.*--name\s+ip-web.*--allocation-method\s+Static'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  IAM — Identidad y roles
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-ad-user-listar'; Tipo = 'IAM'
            Tarea = 'Lista todos los usuarios de Azure Active Directory (Entra ID).'
            Exp = 'az ad user list muestra los usuarios del directorio. En suscripciones grandes puede ser enorme: añade --filter o --query.'
            R = @{ Azure = @{ Ej = 'az ad user list --output table'; Rx = @(
                '^\s*az\s+ad\s+user\s+list'
            )}}
        },
        @{
            Id = 'az-role-asignar'; Tipo = 'IAM'
            Tarea = 'Asigna el rol "Contributor" al usuario "dev@empresa.com" en el grupo de recursos "rg-produccion".'
            Exp = 'az role assignment create es el RBAC de Azure. Contributor puede crear/borrar recursos pero no gestionar accesos.'
            R = @{ Azure = @{ Ej = 'az role assignment create --assignee dev@empresa.com --role Contributor --resource-group rg-produccion'; Rx = @(
                '^\s*az\s+role\s+assignment\s+create.*--assignee\s+dev@empresa\.com.*--role\s+Contributor.*--(resource-group|g)\s+rg-produccion'
                '^\s*az\s+role\s+assignment\s+create.*--role\s+Contributor.*--assignee\s+dev@empresa\.com'
            )}}
        },
        @{
            Id = 'az-role-listar'; Tipo = 'IAM'
            Tarea = 'Lista las asignaciones de roles del grupo "rg-produccion".'
            Exp = 'az role assignment list muestra quién tiene qué rol. --scope limita al grupo de recursos.'
            R = @{ Azure = @{ Ej = 'az role assignment list --resource-group rg-produccion --output table'; Rx = @(
                '^\s*az\s+role\s+assignment\s+list.*--(resource-group|g)\s+rg-produccion'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Storage — Cuentas de almacenamiento
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-storage-crear'; Tipo = 'Storage'
            Tarea = 'Crea una cuenta de almacenamiento "stproddata2024" en el grupo "rg-produccion" con SKU Standard_LRS.'
            Exp = 'El nombre de la cuenta debe ser único en todo Azure, solo minúsculas y números, 3-24 caracteres. Standard_LRS es la más barata (un solo centro de datos).'
            R = @{ Azure = @{ Ej = 'az storage account create --name stproddata2024 --resource-group rg-produccion --sku Standard_LRS'; Rx = @(
                '^\s*az\s+storage\s+account\s+create.*--name\s+stproddata2024.*--sku\s+Standard_LRS'
                '^\s*az\s+storage\s+account\s+create.*-n\s+stproddata2024.*--sku\s+Standard_LRS'
            )}}
        },
        @{
            Id = 'az-storage-listar'; Tipo = 'Storage'
            Tarea = 'Lista todas las cuentas de almacenamiento de tu suscripción.'
            Exp = 'az storage account list muestra todas las cuentas con su SKU, ubicación y estado.'
            R = @{ Azure = @{ Ej = 'az storage account list --output table'; Rx = @(
                '^\s*az\s+storage\s+account\s+list'
            )}}
        },
        @{
            Id = 'az-storage-subir-blob'; Tipo = 'Storage'
            Tarea = 'Sube el archivo "backup.sql" al contenedor "backups" de la cuenta "stproddata2024".'
            Exp = 'az storage blob upload sube un archivo a un contenedor de blobs. --account-name y --container-name son obligatorios.'
            R = @{ Azure = @{ Ej = 'az storage blob upload --account-name stproddata2024 --container-name backups --file backup.sql --name backup.sql'; Rx = @(
                '^\s*az\s+storage\s+blob\s+upload.*--account-name\s+stproddata2024.*--container-name\s+backups.*--(file|f)\s+backup\.sql'
                '^\s*az\s+storage\s+blob\s+upload.*--container-name\s+backups.*--account-name\s+stproddata2024.*--file\s+backup\.sql'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Monitor — Métricas y alertas
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-monitor-listar-metricas'; Tipo = 'Monitor'
            Tarea = 'Lista las métricas disponibles para la VM "srv-web" del grupo "rg-produccion".'
            Exp = 'az monitor metrics list-definitions muestra qué métricas puedes consultar (CPU, disco, red, etc.).'
            R = @{ Azure = @{ Ej = 'az monitor metrics list-definitions --resource-group rg-produccion --resource-type Microsoft.Compute/virtualMachines --resource srv-web'; Rx = @(
                '^\s*az\s+monitor\s+metrics\s+list-definitions.*srv-web'
            )}}
        },
        @{
            Id = 'az-monitor-activity-log'; Tipo = 'Monitor'
            Tarea = 'Consulta el log de actividad del grupo "rg-produccion" (quién hizo qué y cuándo).'
            Exp = 'az monitor activity-log list muestra las operaciones (crear, borrar, modificar) con fecha y usuario.'
            R = @{ Azure = @{ Ej = 'az monitor activity-log list --resource-group rg-produccion --output table'; Rx = @(
                '^\s*az\s+monitor\s+activity-log\s+list.*--(resource-group|g)\s+rg-produccion'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  General — Login, cuenta, configuración
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'az-login'; Tipo = 'General'
            Tarea = 'Inicia sesión en Azure CLI (login interactivo con el navegador).'
            Exp = 'az login abre el navegador para autenticarte. Después ya puedes usar todos los comandos.'
            R = @{ Azure = @{ Ej = 'az login'; Rx = @(
                '^\s*az\s+login\s*$'
            )}}
        },
        @{
            Id = 'az-account-show'; Tipo = 'General'
            Tarea = 'Muestra la suscripción activa en la que estás trabajando.'
            Exp = 'az account show es el "dónde estoy" de Azure. Comprueba siempre que estés en la suscripción correcta antes de crear nada.'
            R = @{ Azure = @{ Ej = 'az account show'; Rx = @(
                '^\s*az\s+account\s+show'
            )}}
        },
        @{
            Id = 'az-account-list'; Tipo = 'General'
            Tarea = 'Lista todas las suscripciones a las que tienes acceso.'
            Exp = 'az account list muestra todas tus suscripciones. La que tiene isDefault=true es en la que trabajas.'
            R = @{ Azure = @{ Ej = 'az account list --output table'; Rx = @(
                '^\s*az\s+account\s+list'
            )}}
        },
        @{
            Id = 'az-account-set'; Tipo = 'General'
            Tarea = 'Cambia a la suscripción con ID "aaaabbbb-1234-5678-9012-ccccddddeeee".'
            Exp = 'az account set cambia la suscripción activa. Todo lo que hagas después se crea en esa suscripción.'
            R = @{ Azure = @{ Ej = 'az account set --subscription aaaabbbb-1234-5678-9012-ccccddddeeee'; Rx = @(
                '^\s*az\s+account\s+set\s+--subscription\s+aaaabbbb-1234-5678-9012-ccccddddeeee'
                '^\s*az\s+account\s+set\s+-s\s+aaaabbbb-1234-5678-9012-ccccddddeeee'
            )}}
        },
        @{
            Id = 'az-output-query'; Tipo = 'General'
            Tarea = 'Lista solo los nombres de todas las VMs de tu suscripción usando --query (sin ver todo el JSON).'
            Exp = '--query usa sintaxis JMESPath para filtrar la salida. [].name extrae solo los nombres de cada objeto.'
            R = @{ Azure = @{ Ej = "az vm list --query '[].name' --output tsv"; Rx = @(
                '^\s*az\s+vm\s+list\s+--query.*\[\]\.name'
                "^\s*az\s+vm\s+list\s+--query.*\[\]\.name"
            )}}
        },
        @{
            Id = 'az-find'; Tipo = 'General'
            Tarea = 'Busca todos los comandos de Azure CLI relacionados con "container registry".'
            Exp = 'az find busca en la documentación de los comandos. Muy útil cuando no recuerdas el subcomando exacto.'
            R = @{ Azure = @{ Ej = 'az find "container registry"'; Rx = @(
                '^\s*az\s+find\s+.*container.*registry'
            )}}
        }
    )
}

# ================================================================= #
#                        LANZADOR                                    #
# ================================================================= #
function Invoke-AzureCli {
    [CmdletBinding()]
    param(
        [int]$Preguntas = 5,

        # Filtrar por servicio: Grupo, VM, AppService, AKS, Red, IAM, Storage, Monitor, General
        [ValidateSet('Mix', 'Grupo', 'VM', 'AppService', 'AKS', 'Red', 'IAM', 'Storage', 'Monitor', 'General')]
        [string]$Modo = 'Mix',

        # Solo lo que toca repasar hoy (Leitner)
        [switch]$Repaso
    )
    Invoke-DojoEngine -Banco (Get-AzureCliBanco) -Prefijo 'azcli' -Titulo 'AZURE CLI: ENTRENAMIENTO DE COMANDOS EN TERMINAL' -Preguntas $Preguntas -Modo $Modo -Repaso:$Repaso
}

Set-Alias azcli    Invoke-AzureCli
Set-Alias az-dojo  Invoke-AzureCli
