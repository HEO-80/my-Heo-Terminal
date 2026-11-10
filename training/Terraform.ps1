# ================================================================= #
#   TERRAFORM: ENTRENAMIENTO PRÁCTICO DE COMANDOS DESDE TERMINAL     #
# ================================================================= #
# IMPORTANTE: guardar como UTF-8 con BOM (o usar PowerShell 7).
#
# Cómo funciona:
#   terraform-dojo                te lanza 5 retos aleatorios
#   terraform-dojo -Preguntas 10  más retos de golpe
#   terraform-dojo -Modo Init     solo retos de init/plan/apply (también: Provider, Recurso, Estado, Variable, Modulo, Import, General)
#   terraform-dojo -Repaso         solo lo que toca repasar hoy (Leitner)
#
# Cada reto te pide que escribas el comando terraform real o el bloque HCL.
# Depende de Motor.ps1 (progreso y repaso espaciado).

# Por si se carga este archivo suelto (sin el tema)
if (-not (Get-Command Write-Cyber -ErrorAction SilentlyContinue)) {
    function Write-Cyber {
        param([string]$Text, [string]$Color, [switch]$NoNewline)
        Write-Host $Text -NoNewline:$NoNewline
    }
}

# Registrar el "mundo" Terraform en el motor
if ($global:NombreMundo -and -not $global:NombreMundo.ContainsKey('Terraform')) {
    $global:NombreMundo['Terraform'] = 'terminal con Terraform'
}

# ================================================================= #
#                    BANCO DE RETOS TERRAFORM                        #
# ================================================================= #

function Get-TerraformBanco {
    @(
        # ─────────────────────────────────────────────────────────────
        #  Init / Plan / Apply / Destroy — el ciclo de vida
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-init'; Tipo = 'Init'
            Tarea = 'Inicializa el directorio de trabajo de Terraform (descarga providers y módulos).'
            Exp = 'terraform init es SIEMPRE el primer comando. Descarga los providers, configura el backend y prepara el directorio .terraform/.'
            R = @{ Terraform = @{ Ej = 'terraform init'; Rx = @(
                '^\s*terraform\s+init'
            )}}
        },
        @{
            Id = 'tf-init-upgrade'; Tipo = 'Init'
            Tarea = 'Reinicializa Terraform actualizando los providers a la última versión permitida por las restricciones.'
            Exp = 'terraform init -upgrade actualiza los providers dentro de los rangos de versión definidos. Útil cuando cambias restricciones.'
            R = @{ Terraform = @{ Ej = 'terraform init -upgrade'; Rx = @(
                '^\s*terraform\s+init\s+-upgrade'
            )}}
        },
        @{
            Id = 'tf-plan'; Tipo = 'Init'
            Tarea = 'Genera un plan de ejecución para ver qué cambios se van a aplicar (sin tocar nada).'
            Exp = 'terraform plan muestra lo que Terraform VA A HACER: crear, modificar o destruir. Es un "dry run" — no cambia nada.'
            R = @{ Terraform = @{ Ej = 'terraform plan'; Rx = @(
                '^\s*terraform\s+plan'
            )}}
        },
        @{
            Id = 'tf-plan-out'; Tipo = 'Init'
            Tarea = 'Genera un plan y guárdalo en el archivo "cambios.tfplan" para aplicarlo después exactamente igual.'
            Exp = 'terraform plan -out=archivo guarda el plan binario. Después puedes hacer terraform apply archivo y se aplica EXACTAMENTE eso.'
            R = @{ Terraform = @{ Ej = 'terraform plan -out=cambios.tfplan'; Rx = @(
                '^\s*terraform\s+plan\s+-out[= ]cambios\.tfplan'
            )}}
        },
        @{
            Id = 'tf-apply'; Tipo = 'Init'
            Tarea = 'Aplica los cambios de infraestructura definidos en la configuración.'
            Exp = 'terraform apply crea/modifica/destruye los recursos. Te pide confirmación (yes). Con -auto-approve se salta la pregunta.'
            R = @{ Terraform = @{ Ej = 'terraform apply'; Rx = @(
                '^\s*terraform\s+apply'
            )}}
        },
        @{
            Id = 'tf-apply-auto'; Tipo = 'Init'
            Tarea = 'Aplica los cambios sin pedir confirmación (para pipelines de CI/CD).'
            Exp = 'terraform apply -auto-approve es necesario en CI/CD donde nadie puede escribir "yes". OJO: no hay marcha atrás.'
            R = @{ Terraform = @{ Ej = 'terraform apply -auto-approve'; Rx = @(
                '^\s*terraform\s+apply\s+-auto-approve'
            )}}
        },
        @{
            Id = 'tf-destroy'; Tipo = 'Init'
            Tarea = 'Destruye TODA la infraestructura gestionada por esta configuración.'
            Exp = 'terraform destroy borra TODO lo que Terraform ha creado. Pide confirmación. Es el "undo total" de tu infraestructura.'
            R = @{ Terraform = @{ Ej = 'terraform destroy'; Rx = @(
                '^\s*terraform\s+destroy'
            )}}
        },
        @{
            Id = 'tf-destroy-target'; Tipo = 'Init'
            Tarea = 'Destruye solo el recurso aws_instance.web (sin tocar el resto de la infraestructura).'
            Exp = '-target permite destruir un recurso concreto sin afectar al resto. Útil para limpiar un recurso problemático.'
            R = @{ Terraform = @{ Ej = 'terraform destroy -target=aws_instance.web'; Rx = @(
                '^\s*terraform\s+destroy\s+-target[= ]aws_instance\.web'
            )}}
        },
        @{
            Id = 'tf-validate'; Tipo = 'Init'
            Tarea = 'Valida que la configuración de Terraform sea sintácticamente correcta.'
            Exp = 'terraform validate comprueba la sintaxis HCL y la coherencia de la configuración. No accede a ningún proveedor.'
            R = @{ Terraform = @{ Ej = 'terraform validate'; Rx = @(
                '^\s*terraform\s+validate'
            )}}
        },
        @{
            Id = 'tf-fmt'; Tipo = 'Init'
            Tarea = 'Formatea todos los archivos .tf del directorio actual según el estilo estándar de Terraform.'
            Exp = 'terraform fmt reescribe los .tf con la indentación y el estilo canónico de HashiCorp. -check solo informa sin cambiar.'
            R = @{ Terraform = @{ Ej = 'terraform fmt'; Rx = @(
                '^\s*terraform\s+fmt'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Providers — configurar proveedores
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-provider-aws'; Tipo = 'Provider'
            Tarea = 'Escribe el bloque terraform con el required_provider para AWS (hashicorp/aws) con versión >= 5.0.'
            Exp = 'El bloque terraform.required_providers define qué provider necesita tu configuración y con qué restricción de versión.'
            R = @{ Terraform = @{ Ej = @'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
'@; Rx = @(
                'terraform\s*\{[\s\S]*required_providers\s*\{[\s\S]*aws\s*=\s*\{[\s\S]*source\s*=\s*"hashicorp/aws"[\s\S]*version\s*=\s*".*5\.0'
            )}}
        },
        @{
            Id = 'tf-provider-azurerm'; Tipo = 'Provider'
            Tarea = 'Escribe el bloque provider para Azure (azurerm) con features vacío (obligatorio).'
            Exp = 'El provider azurerm EXIGE el bloque features {} aunque esté vacío. Sin él, Terraform da error.'
            R = @{ Terraform = @{ Ej = @'
provider "azurerm" {
  features {}
}
'@; Rx = @(
                'provider\s+"azurerm"\s*\{[\s\S]*features\s*\{'
            )}}
        },
        @{
            Id = 'tf-provider-listar'; Tipo = 'Provider'
            Tarea = 'Lista los providers instalados en el directorio actual con sus versiones.'
            Exp = 'terraform providers muestra el árbol de providers requeridos. Con terraform version ves las versiones exactas instaladas.'
            R = @{ Terraform = @{ Ej = 'terraform providers'; Rx = @(
                '^\s*terraform\s+providers'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Recursos — escribir recursos HCL
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-recurso-ec2'; Tipo = 'Recurso'
            Tarea = 'Escribe un recurso aws_instance llamado "web" con AMI "ami-0c55b159cbfafe1f0" y tipo "t2.micro".'
            Exp = 'aws_instance es el recurso más básico de AWS en Terraform. ami y instance_type son los argumentos mínimos obligatorios.'
            R = @{ Terraform = @{ Ej = @'
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
'@; Rx = @(
                'resource\s+"aws_instance"\s+"web"\s*\{[\s\S]*ami\s*=\s*"ami-0c55b159cbfafe1f0"[\s\S]*instance_type\s*=\s*"t2\.micro"'
            )}}
        },
        @{
            Id = 'tf-recurso-s3'; Tipo = 'Recurso'
            Tarea = 'Escribe un recurso aws_s3_bucket llamado "datos" con bucket "mi-bucket-datos-2024".'
            Exp = 'aws_s3_bucket crea un bucket de S3. Desde AWS Provider v4+, las propiedades como versionado van en recursos separados.'
            R = @{ Terraform = @{ Ej = @'
resource "aws_s3_bucket" "datos" {
  bucket = "mi-bucket-datos-2024"
}
'@; Rx = @(
                'resource\s+"aws_s3_bucket"\s+"datos"\s*\{[\s\S]*bucket\s*=\s*"mi-bucket-datos-2024"'
            )}}
        },
        @{
            Id = 'tf-recurso-rg'; Tipo = 'Recurso'
            Tarea = 'Escribe un recurso azurerm_resource_group llamado "produccion" en location "West Europe" con nombre "rg-produccion".'
            Exp = 'azurerm_resource_group es el primer recurso en Azure. Todos los demás recursos deben estar dentro de un grupo.'
            R = @{ Terraform = @{ Ej = @'
resource "azurerm_resource_group" "produccion" {
  name     = "rg-produccion"
  location = "West Europe"
}
'@; Rx = @(
                'resource\s+"azurerm_resource_group"\s+"produccion"\s*\{[\s\S]*name\s*=\s*"rg-produccion"[\s\S]*location\s*=\s*"West Europe"'
            )}}
        },
        @{
            Id = 'tf-output'; Tipo = 'Recurso'
            Tarea = 'Escribe un bloque output llamado "ip_publica" que muestre la IP pública de aws_instance.web.'
            Exp = 'Los outputs exponen valores después del apply. Puedes usarlos para pasar datos entre módulos o verlos en terminal.'
            R = @{ Terraform = @{ Ej = @'
output "ip_publica" {
  value = aws_instance.web.public_ip
}
'@; Rx = @(
                'output\s+"ip_publica"\s*\{[\s\S]*value\s*=\s*aws_instance\.web\.public_ip'
            )}}
        },
        @{
            Id = 'tf-data-source'; Tipo = 'Recurso'
            Tarea = 'Escribe un data source que busque la AMI más reciente de Ubuntu 22.04 en AWS (propietario Canonical 099720109477).'
            Exp = 'Los data sources leen información que ya existe en el proveedor. Es la forma de buscar AMIs, VPCs, zonas, etc. sin hardcodear IDs.'
            R = @{ Terraform = @{ Ej = @'
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
'@; Rx = @(
                'data\s+"aws_ami"\s+"ubuntu"\s*\{[\s\S]*most_recent\s*=\s*true[\s\S]*owners\s*=\s*\[.*099720109477'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Estado — gestión del state
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-state-list'; Tipo = 'Estado'
            Tarea = 'Lista todos los recursos que Terraform tiene registrados en su estado (state).'
            Exp = 'terraform state list muestra lo que Terraform "conoce". Si un recurso no aparece aquí, Terraform no lo gestiona.'
            R = @{ Terraform = @{ Ej = 'terraform state list'; Rx = @(
                '^\s*terraform\s+state\s+list'
            )}}
        },
        @{
            Id = 'tf-state-show'; Tipo = 'Estado'
            Tarea = 'Muestra los atributos detallados del recurso aws_instance.web en el estado.'
            Exp = 'terraform state show muestra TODOS los atributos de un recurso concreto tal como los tiene guardados en el state.'
            R = @{ Terraform = @{ Ej = 'terraform state show aws_instance.web'; Rx = @(
                '^\s*terraform\s+state\s+show\s+aws_instance\.web'
            )}}
        },
        @{
            Id = 'tf-state-rm'; Tipo = 'Estado'
            Tarea = 'Elimina el recurso aws_instance.old del estado de Terraform (sin destruir el recurso real).'
            Exp = 'terraform state rm "olvida" un recurso sin destruirlo en el proveedor. Útil para migrar recursos entre configuraciones.'
            R = @{ Terraform = @{ Ej = 'terraform state rm aws_instance.old'; Rx = @(
                '^\s*terraform\s+state\s+rm\s+aws_instance\.old'
            )}}
        },
        @{
            Id = 'tf-state-mv'; Tipo = 'Estado'
            Tarea = 'Renombra el recurso aws_instance.web a aws_instance.servidor_principal en el estado.'
            Exp = 'terraform state mv mueve/renombra un recurso en el state sin destruir y recrear. Evita downtime al refactorizar.'
            R = @{ Terraform = @{ Ej = 'terraform state mv aws_instance.web aws_instance.servidor_principal'; Rx = @(
                '^\s*terraform\s+state\s+mv\s+aws_instance\.web\s+aws_instance\.servidor_principal'
            )}}
        },
        @{
            Id = 'tf-backend-s3'; Tipo = 'Estado'
            Tarea = 'Escribe el bloque backend para guardar el estado en S3 (bucket "tf-state-prod", key "infra/terraform.tfstate", region "eu-west-1").'
            Exp = 'El backend remoto guarda el state en un lugar compartido. S3 es el más usado en AWS. DynamoDB añade locking para equipos.'
            R = @{ Terraform = @{ Ej = @'
terraform {
  backend "s3" {
    bucket = "tf-state-prod"
    key    = "infra/terraform.tfstate"
    region = "eu-west-1"
  }
}
'@; Rx = @(
                'backend\s+"s3"\s*\{[\s\S]*bucket\s*=\s*"tf-state-prod"[\s\S]*key\s*=\s*"infra/terraform\.tfstate"'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Variables — entrada y parametrización
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-variable'; Tipo = 'Variable'
            Tarea = 'Escribe una variable "entorno" de tipo string, con valor por defecto "desarrollo" y descripción "Nombre del entorno".'
            Exp = 'Las variables parametrizan tu configuración. Se pueden pasar con -var, archivos .tfvars o variables de entorno TF_VAR_.'
            R = @{ Terraform = @{ Ej = @'
variable "entorno" {
  type        = string
  default     = "desarrollo"
  description = "Nombre del entorno"
}
'@; Rx = @(
                'variable\s+"entorno"\s*\{[\s\S]*type\s*=\s*string[\s\S]*default\s*=\s*"desarrollo"'
            )}}
        },
        @{
            Id = 'tf-apply-var'; Tipo = 'Variable'
            Tarea = 'Aplica la configuración pasando la variable "entorno" con valor "produccion" desde la línea de comandos.'
            Exp = '-var te permite pasar variables sin archivo. Para muchas variables es mejor usar un .tfvars.'
            R = @{ Terraform = @{ Ej = 'terraform apply -var="entorno=produccion"'; Rx = @(
                '^\s*terraform\s+apply\s+-var[= ].*entorno.*produccion'
            )}}
        },
        @{
            Id = 'tf-apply-varfile'; Tipo = 'Variable'
            Tarea = 'Aplica la configuración usando el archivo de variables "prod.tfvars".'
            Exp = '-var-file carga todas las variables de un archivo. Es la forma estándar de tener configuraciones por entorno (dev.tfvars, prod.tfvars).'
            R = @{ Terraform = @{ Ej = 'terraform apply -var-file="prod.tfvars"'; Rx = @(
                '^\s*terraform\s+apply\s+-var-file[= ].*prod\.tfvars'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Módulos — reutilización
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-modulo-local'; Tipo = 'Modulo'
            Tarea = 'Escribe un bloque module que use un módulo local en "./modulos/red" pasándole la variable cidr = "10.0.0.0/16".'
            Exp = 'Los módulos encapsulan grupos de recursos. source = "./ruta" es un módulo local. También puedes usar el Registry de Terraform.'
            R = @{ Terraform = @{ Ej = @'
module "red" {
  source = "./modulos/red"
  cidr   = "10.0.0.0/16"
}
'@; Rx = @(
                'module\s+"red"\s*\{[\s\S]*source\s*=\s*"\./modulos/red"[\s\S]*cidr\s*=\s*"10\.0\.0\.0/16"'
            )}}
        },
        @{
            Id = 'tf-modulo-registry'; Tipo = 'Modulo'
            Tarea = 'Escribe un bloque module que use el módulo oficial de VPC de AWS del Registry de Terraform (terraform-aws-modules/vpc/aws) versión 5.0.0.'
            Exp = 'El Terraform Registry tiene módulos listos para usar. La source de un módulo del Registry usa el formato namespace/nombre/provider.'
            R = @{ Terraform = @{ Ej = @'
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
'@; Rx = @(
                'module\s+"vpc"\s*\{[\s\S]*source\s*=\s*"terraform-aws-modules/vpc/aws"[\s\S]*version\s*=\s*"5\.0\.0"'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Import — importar recursos existentes
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-import'; Tipo = 'Import'
            Tarea = 'Importa una instancia EC2 existente (ID: i-0abc123def456789) al recurso aws_instance.legacy de tu configuración.'
            Exp = 'terraform import enlaza un recurso que ya existe en el proveedor con tu código. Después debes escribir la configuración HCL que lo describa.'
            R = @{ Terraform = @{ Ej = 'terraform import aws_instance.legacy i-0abc123def456789'; Rx = @(
                '^\s*terraform\s+import\s+aws_instance\.legacy\s+i-0abc123def456789'
            )}}
        },
        @{
            Id = 'tf-import-block'; Tipo = 'Import'
            Tarea = 'Escribe un bloque import (Terraform 1.5+) para importar la instancia i-0abc123def456789 al recurso aws_instance.legacy.'
            Exp = 'Desde Terraform 1.5, puedes declarar imports en HCL. Se ejecutan con plan/apply y generan la config con -generate-config-out.'
            R = @{ Terraform = @{ Ej = @'
import {
  to = aws_instance.legacy
  id = "i-0abc123def456789"
}
'@; Rx = @(
                'import\s*\{[\s\S]*to\s*=\s*aws_instance\.legacy[\s\S]*id\s*=\s*"i-0abc123def456789"'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  General — otros comandos útiles
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'tf-output-cmd'; Tipo = 'General'
            Tarea = 'Muestra el valor del output "ip_publica" después de un apply.'
            Exp = 'terraform output muestra los valores de los outputs. Con -json los devuelve en JSON, ideal para scripts.'
            R = @{ Terraform = @{ Ej = 'terraform output ip_publica'; Rx = @(
                '^\s*terraform\s+output\s+ip_publica'
            )}}
        },
        @{
            Id = 'tf-workspace-new'; Tipo = 'General'
            Tarea = 'Crea un nuevo workspace llamado "staging".'
            Exp = 'Los workspaces permiten tener varios estados con la misma configuración (dev, staging, prod). Cada uno tiene su propio state.'
            R = @{ Terraform = @{ Ej = 'terraform workspace new staging'; Rx = @(
                '^\s*terraform\s+workspace\s+new\s+staging'
            )}}
        },
        @{
            Id = 'tf-workspace-select'; Tipo = 'General'
            Tarea = 'Cambia al workspace "produccion".'
            Exp = 'terraform workspace select cambia entre workspaces existentes. terraform.workspace devuelve el nombre actual en la configuración HCL.'
            R = @{ Terraform = @{ Ej = 'terraform workspace select produccion'; Rx = @(
                '^\s*terraform\s+workspace\s+select\s+produccion'
            )}}
        },
        @{
            Id = 'tf-graph'; Tipo = 'General'
            Tarea = 'Genera el grafo de dependencias de la infraestructura en formato DOT.'
            Exp = 'terraform graph genera un grafo en formato DOT (Graphviz). Puedes redirigirlo a un archivo o a dot -Tpng para visualizarlo.'
            R = @{ Terraform = @{ Ej = 'terraform graph'; Rx = @(
                '^\s*terraform\s+graph'
            )}}
        },
        @{
            Id = 'tf-taint'; Tipo = 'General'
            Tarea = 'Marca el recurso aws_instance.web para que sea destruido y recreado en el próximo apply (Terraform < 1.6).'
            Exp = 'terraform taint fuerza la recreación. Desde Terraform 1.6+ se usa terraform apply -replace=aws_instance.web en su lugar.'
            R = @{ Terraform = @{ Ej = 'terraform apply -replace=aws_instance.web'; Rx = @(
                '^\s*terraform\s+(taint\s+aws_instance\.web|apply\s+-replace[= ]aws_instance\.web)'
            )}}
        }
    )
}

# ================================================================= #
#                        LANZADOR                                    #
# ================================================================= #
function Invoke-Terraform {
    [CmdletBinding()]
    param(
        [int]$Preguntas = 5,

        # Filtrar por tema: Init, Provider, Recurso, Estado, Variable, Modulo, Import, General
        [ValidateSet('Mix', 'Init', 'Provider', 'Recurso', 'Estado', 'Variable', 'Modulo', 'Import', 'General')]
        [string]$Modo = 'Mix',

        # Solo lo que toca repasar hoy (Leitner)
        [switch]$Repaso
    )
    Invoke-DojoEngine -Banco (Get-TerraformBanco) -Prefijo 'terraform' -Titulo 'TERRAFORM: ENTRENAMIENTO DE INFRAESTRUCTURA COMO CÓDIGO' -Preguntas $Preguntas -Modo $Modo -Repaso:$Repaso
}

Set-Alias terraform-dojo Invoke-Terraform
Set-Alias tf-dojo        Invoke-Terraform
