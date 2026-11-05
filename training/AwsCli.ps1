# ================================================================= #
#    AWS CLI: ENTRENAMIENTO PRÁCTICO DE COMANDOS AWS DESDE TERMINAL  #
# ================================================================= #
# IMPORTANTE: guardar como UTF-8 con BOM (o usar PowerShell 7).
#
# Cómo funciona:
#   awscli              te lanza 5 retos aleatorios (mezcla de servicios)
#   awscli -Preguntas 10   más retos de golpe
#   awscli -Modo S3     solo retos de S3 (también: EC2, IAM, VPC, Lambda, CloudWatch, General)
#   awscli -Repaso      solo lo que toca repasar hoy (Leitner)
#
# Cada reto te pide que escribas el comando AWS CLI real.
# Se acepta la forma más habitual y variaciones razonables.
# Depende de Motor.ps1 (progreso y repaso espaciado).

# Por si se carga este archivo suelto (sin el tema)
if (-not (Get-Command Write-Cyber -ErrorAction SilentlyContinue)) {
    function Write-Cyber {
        param([string]$Text, [string]$Color, [switch]$NoNewline)
        Write-Host $Text -NoNewline:$NoNewline
    }
}

# Registrar el "mundo" AWS en el motor
if ($global:NombreMundo -and -not $global:NombreMundo.ContainsKey('AWS')) {
    $global:NombreMundo['AWS'] = 'terminal con AWS CLI'
}

# ================================================================= #
#                     BANCO DE RETOS AWS CLI                         #
# ================================================================= #

function Get-AwsCliBanco {
    @(
        # ─────────────────────────────────────────────────────────────
        #  S3 — Almacenamiento de objetos
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-s3-crear-bucket'; Tipo = 'S3'
            Tarea = 'Crea un bucket de S3 llamado "mi-backup-2024".'
            Exp = 'aws s3 mb crea un bucket. El nombre va precedido de s3:// — debe ser único en todo el mundo.'
            R = @{ AWS = @{ Ej = 'aws s3 mb s3://mi-backup-2024'; Rx = @(
                '^\s*aws\s+s3\s+mb\s+s3://mi-backup-2024'
                '^\s*aws\s+s3api\s+create-bucket\s+--bucket\s+mi-backup-2024'
            )}}
        },
        @{
            Id = 'aws-s3-listar-buckets'; Tipo = 'S3'
            Tarea = 'Lista todos tus buckets de S3.'
            Exp = 'aws s3 ls (sin ruta) muestra todos los buckets de tu cuenta.'
            R = @{ AWS = @{ Ej = 'aws s3 ls'; Rx = @(
                '^\s*aws\s+s3\s+ls\s*$'
                '^\s*aws\s+s3api\s+list-buckets'
            )}}
        },
        @{
            Id = 'aws-s3-subir-archivo'; Tipo = 'S3'
            Tarea = 'Sube el archivo "informe.pdf" al bucket "mi-backup-2024".'
            Exp = 'aws s3 cp copia archivos entre local y S3. El destino S3 siempre lleva s3://.'
            R = @{ AWS = @{ Ej = 'aws s3 cp informe.pdf s3://mi-backup-2024/'; Rx = @(
                '^\s*aws\s+s3\s+cp\s+informe\.pdf\s+s3://mi-backup-2024'
            )}}
        },
        @{
            Id = 'aws-s3-descargar-archivo'; Tipo = 'S3'
            Tarea = 'Descarga "datos.csv" del bucket "mi-backup-2024" a tu carpeta actual.'
            Exp = 'aws s3 cp con el origen en S3 y el destino en local (usa . para la carpeta actual).'
            R = @{ AWS = @{ Ej = 'aws s3 cp s3://mi-backup-2024/datos.csv .'; Rx = @(
                '^\s*aws\s+s3\s+cp\s+s3://mi-backup-2024/datos\.csv\s+\.'
                '^\s*aws\s+s3\s+cp\s+s3://mi-backup-2024/datos\.csv\s+datos\.csv'
                '^\s*aws\s+s3\s+cp\s+s3://mi-backup-2024/datos\.csv\s+\./'
            )}}
        },
        @{
            Id = 'aws-s3-listar-contenido'; Tipo = 'S3'
            Tarea = 'Lista el contenido del bucket "mi-backup-2024".'
            Exp = 'aws s3 ls s3://bucket muestra los objetos (archivos) dentro de un bucket.'
            R = @{ AWS = @{ Ej = 'aws s3 ls s3://mi-backup-2024/'; Rx = @(
                '^\s*aws\s+s3\s+ls\s+s3://mi-backup-2024'
            )}}
        },
        @{
            Id = 'aws-s3-sync'; Tipo = 'S3'
            Tarea = 'Sincroniza la carpeta local "web" con el bucket "mi-sitio-web" (solo sube lo que ha cambiado).'
            Exp = 'aws s3 sync compara origen y destino y solo transfiere los archivos nuevos o modificados. Ideal para deploys.'
            R = @{ AWS = @{ Ej = 'aws s3 sync web s3://mi-sitio-web/'; Rx = @(
                '^\s*aws\s+s3\s+sync\s+\.?/?web\s+s3://mi-sitio-web'
                '^\s*aws\s+s3\s+sync\s+web/?\s+s3://mi-sitio-web'
            )}}
        },
        @{
            Id = 'aws-s3-borrar-bucket'; Tipo = 'S3'
            Tarea = 'Borra el bucket "mi-backup-2024" con todo lo que tenga dentro.'
            Exp = 'aws s3 rb --force vacía el bucket y lo borra. Sin --force solo borra buckets vacíos.'
            R = @{ AWS = @{ Ej = 'aws s3 rb s3://mi-backup-2024 --force'; Rx = @(
                '^\s*aws\s+s3\s+rb\s+s3://mi-backup-2024\s+--force'
                '^\s*aws\s+s3\s+rb\s+--force\s+s3://mi-backup-2024'
            )}}
        },
        @{
            Id = 'aws-s3-presign'; Tipo = 'S3'
            Tarea = 'Genera una URL temporal (1 hora) para compartir "informe.pdf" del bucket "datos-empresa" sin dar acceso a tu cuenta.'
            Exp = 'aws s3 presign genera una URL firmada con caducidad. Perfecta para compartir un archivo sin dar credenciales.'
            R = @{ AWS = @{ Ej = 'aws s3 presign s3://datos-empresa/informe.pdf --expires-in 3600'; Rx = @(
                '^\s*aws\s+s3\s+presign\s+s3://datos-empresa/informe\.pdf\s+--expires-in\s+3600'
                '^\s*aws\s+s3\s+presign\s+--expires-in\s+3600\s+s3://datos-empresa/informe\.pdf'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  EC2 — Máquinas virtuales
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-ec2-listar'; Tipo = 'EC2'
            Tarea = 'Lista todas las instancias EC2 de tu cuenta.'
            Exp = 'describe-instances muestra todas las instancias con sus datos (estado, IP, tipo, etc.).'
            R = @{ AWS = @{ Ej = 'aws ec2 describe-instances'; Rx = @(
                '^\s*aws\s+ec2\s+describe-instances'
            )}}
        },
        @{
            Id = 'aws-ec2-crear-keypair'; Tipo = 'EC2'
            Tarea = 'Crea un par de claves llamado "mi-clave" y guarda la clave privada en "mi-clave.pem".'
            Exp = 'create-key-pair genera la clave privada una sola vez. Si la pierdes, no se puede recuperar. --query extrae solo el texto de la clave.'
            R = @{ AWS = @{ Ej = "aws ec2 create-key-pair --key-name mi-clave --query 'KeyMaterial' --output text > mi-clave.pem"; Rx = @(
                '^\s*aws\s+ec2\s+create-key-pair\s+--key-name\s+mi-clave.*>\s*mi-clave\.pem'
            )}}
        },
        @{
            Id = 'aws-ec2-sg-crear'; Tipo = 'EC2'
            Tarea = 'Crea un Security Group llamado "sg-web" con la descripción "Trafico web" en la VPC por defecto.'
            Exp = 'Un Security Group es el firewall de AWS. Se crea vacío (sin reglas) y luego se le añaden.'
            R = @{ AWS = @{ Ej = 'aws ec2 create-security-group --group-name sg-web --description "Trafico web"'; Rx = @(
                '^\s*aws\s+ec2\s+create-security-group\s+--group-name\s+sg-web\s+--description\s+'
            )}}
        },
        @{
            Id = 'aws-ec2-sg-abrir-ssh'; Tipo = 'EC2'
            Tarea = 'Abre el puerto 22 (SSH) en el Security Group "sg-123456" para que puedas conectarte desde cualquier IP.'
            Exp = 'authorize-security-group-ingress añade reglas de entrada. 0.0.0.0/0 significa "desde cualquier IP" (cuidado en producción).'
            R = @{ AWS = @{ Ej = 'aws ec2 authorize-security-group-ingress --group-id sg-123456 --protocol tcp --port 22 --cidr 0.0.0.0/0'; Rx = @(
                '^\s*aws\s+ec2\s+authorize-security-group-ingress\s+--group-id\s+sg-123456.*--port\s+22.*--cidr\s+0\.0\.0\.0/0'
                '^\s*aws\s+ec2\s+authorize-security-group-ingress\s+--group-id\s+sg-123456.*--cidr\s+0\.0\.0\.0/0.*--port\s+22'
            )}}
        },
        @{
            Id = 'aws-ec2-lanzar'; Tipo = 'EC2'
            Tarea = 'Lanza una instancia EC2 t2.micro con la AMI "ami-0abcdef1234567890", key pair "mi-clave" y Security Group "sg-123456".'
            Exp = 'run-instances es el comando más importante de EC2. t2.micro entra en Free Tier. --count 1 lanza una sola instancia.'
            R = @{ AWS = @{ Ej = 'aws ec2 run-instances --image-id ami-0abcdef1234567890 --instance-type t2.micro --key-name mi-clave --security-group-ids sg-123456 --count 1'; Rx = @(
                '^\s*aws\s+ec2\s+run-instances\s.*--image-id\s+ami-0abcdef1234567890.*--instance-type\s+t2\.micro'
                '^\s*aws\s+ec2\s+run-instances\s.*--instance-type\s+t2\.micro.*--image-id\s+ami-0abcdef1234567890'
            )}}
        },
        @{
            Id = 'aws-ec2-parar'; Tipo = 'EC2'
            Tarea = 'Para (detén) la instancia EC2 con ID "i-0abc123def456".'
            Exp = 'stop-instances la apaga pero conserva el disco. No te cobra por el cómputo mientras está parada (sí por el disco EBS).'
            R = @{ AWS = @{ Ej = 'aws ec2 stop-instances --instance-ids i-0abc123def456'; Rx = @(
                '^\s*aws\s+ec2\s+stop-instances\s+--instance-ids\s+i-0abc123def456'
            )}}
        },
        @{
            Id = 'aws-ec2-arrancar'; Tipo = 'EC2'
            Tarea = 'Arranca la instancia EC2 "i-0abc123def456" que estaba parada.'
            Exp = 'start-instances enciende una instancia parada. Puede cambiar la IP pública (a menos que tengas una Elastic IP).'
            R = @{ AWS = @{ Ej = 'aws ec2 start-instances --instance-ids i-0abc123def456'; Rx = @(
                '^\s*aws\s+ec2\s+start-instances\s+--instance-ids\s+i-0abc123def456'
            )}}
        },
        @{
            Id = 'aws-ec2-terminar'; Tipo = 'EC2'
            Tarea = 'Termina (destruye) la instancia EC2 "i-0abc123def456". Esto borra la máquina y su disco.'
            Exp = 'terminate-instances destruye la instancia. No se puede deshacer. Es distinto de stop: stop la apaga, terminate la borra.'
            R = @{ AWS = @{ Ej = 'aws ec2 terminate-instances --instance-ids i-0abc123def456'; Rx = @(
                '^\s*aws\s+ec2\s+terminate-instances\s+--instance-ids\s+i-0abc123def456'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  IAM — Identidad y permisos
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-iam-crear-usuario'; Tipo = 'IAM'
            Tarea = 'Crea un usuario IAM llamado "desarrollador".'
            Exp = 'create-user crea la identidad, pero sin contraseña ni claves. Hay que añadirle acceso después.'
            R = @{ AWS = @{ Ej = 'aws iam create-user --user-name desarrollador'; Rx = @(
                '^\s*aws\s+iam\s+create-user\s+--user-name\s+desarrollador'
            )}}
        },
        @{
            Id = 'aws-iam-crear-grupo'; Tipo = 'IAM'
            Tarea = 'Crea un grupo IAM llamado "devs".'
            Exp = 'Los grupos simplifican la gestión: asignas la política al grupo y luego metes usuarios en él.'
            R = @{ AWS = @{ Ej = 'aws iam create-group --group-name devs'; Rx = @(
                '^\s*aws\s+iam\s+create-group\s+--group-name\s+devs'
            )}}
        },
        @{
            Id = 'aws-iam-meter-en-grupo'; Tipo = 'IAM'
            Tarea = 'Mete al usuario "desarrollador" en el grupo "devs".'
            Exp = 'add-user-to-group vincula un usuario con un grupo. El usuario hereda todas las políticas del grupo.'
            R = @{ AWS = @{ Ej = 'aws iam add-user-to-group --user-name desarrollador --group-name devs'; Rx = @(
                '^\s*aws\s+iam\s+add-user-to-group\s+--user-name\s+desarrollador\s+--group-name\s+devs'
                '^\s*aws\s+iam\s+add-user-to-group\s+--group-name\s+devs\s+--user-name\s+desarrollador'
            )}}
        },
        @{
            Id = 'aws-iam-asignar-politica'; Tipo = 'IAM'
            Tarea = 'Asigna la política "AmazonS3ReadOnlyAccess" al grupo "devs" (usa el ARN completo de AWS managed policies).'
            Exp = 'attach-group-policy vincula una política gestionada por AWS. El ARN siempre empieza por arn:aws:iam::aws:policy/.'
            R = @{ AWS = @{ Ej = 'aws iam attach-group-policy --group-name devs --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess'; Rx = @(
                '^\s*aws\s+iam\s+attach-group-policy\s+--group-name\s+devs\s+--policy-arn\s+arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess'
                '^\s*aws\s+iam\s+attach-group-policy\s+--policy-arn\s+arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess\s+--group-name\s+devs'
            )}}
        },
        @{
            Id = 'aws-iam-listar-usuarios'; Tipo = 'IAM'
            Tarea = 'Lista todos los usuarios IAM de tu cuenta.'
            Exp = 'list-users muestra todos los usuarios con su fecha de creación y ARN.'
            R = @{ AWS = @{ Ej = 'aws iam list-users'; Rx = @(
                '^\s*aws\s+iam\s+list-users'
            )}}
        },
        @{
            Id = 'aws-iam-quien-soy'; Tipo = 'IAM'
            Tarea = 'Comprueba con qué identidad estás autenticado en AWS (quién eres).'
            Exp = 'sts get-caller-identity es el "whoami" de AWS: te dice tu cuenta, usuario y ARN. Úsalo siempre que dudes de con qué credenciales estás trabajando.'
            R = @{ AWS = @{ Ej = 'aws sts get-caller-identity'; Rx = @(
                '^\s*aws\s+sts\s+get-caller-identity'
            )}}
        },
        @{
            Id = 'aws-iam-crear-access-key'; Tipo = 'IAM'
            Tarea = 'Crea unas access keys (credenciales de terminal) para el usuario "desarrollador".'
            Exp = 'create-access-key genera AccessKeyId + SecretAccessKey. La Secret solo se muestra UNA VEZ: si la pierdes, hay que crear otra.'
            R = @{ AWS = @{ Ej = 'aws iam create-access-key --user-name desarrollador'; Rx = @(
                '^\s*aws\s+iam\s+create-access-key\s+--user-name\s+desarrollador'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  VPC — Redes
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-vpc-crear'; Tipo = 'VPC'
            Tarea = 'Crea una VPC con el bloque CIDR 10.0.0.0/16.'
            Exp = 'Una VPC es tu red privada en AWS. /16 te da 65.536 IPs. Todo recurso (EC2, RDS, Lambda en VPC) vive dentro de una.'
            R = @{ AWS = @{ Ej = 'aws ec2 create-vpc --cidr-block 10.0.0.0/16'; Rx = @(
                '^\s*aws\s+ec2\s+create-vpc\s+--cidr-block\s+10\.0\.0\.0/16'
            )}}
        },
        @{
            Id = 'aws-vpc-crear-subnet'; Tipo = 'VPC'
            Tarea = 'Crea una subnet pública 10.0.1.0/24 en la VPC "vpc-abc123" en la zona "eu-west-1a".'
            Exp = 'Una subnet divide la VPC. /24 da 256 IPs (251 utilizables). Se necesita al menos una para lanzar instancias.'
            R = @{ AWS = @{ Ej = 'aws ec2 create-subnet --vpc-id vpc-abc123 --cidr-block 10.0.1.0/24 --availability-zone eu-west-1a'; Rx = @(
                '^\s*aws\s+ec2\s+create-subnet.*--vpc-id\s+vpc-abc123.*--cidr-block\s+10\.0\.1\.0/24'
            )}}
        },
        @{
            Id = 'aws-vpc-crear-igw'; Tipo = 'VPC'
            Tarea = 'Crea un Internet Gateway (la puerta de salida a Internet para tu VPC).'
            Exp = 'Sin Internet Gateway una VPC es una red aislada. Se crea y luego se adjunta a una VPC con attach-internet-gateway.'
            R = @{ AWS = @{ Ej = 'aws ec2 create-internet-gateway'; Rx = @(
                '^\s*aws\s+ec2\s+create-internet-gateway'
            )}}
        },
        @{
            Id = 'aws-vpc-attach-igw'; Tipo = 'VPC'
            Tarea = 'Conecta el Internet Gateway "igw-abc123" a la VPC "vpc-abc123".'
            Exp = 'attach-internet-gateway vincula la puerta de Internet con tu VPC. Sin esto, las instancias no salen a Internet.'
            R = @{ AWS = @{ Ej = 'aws ec2 attach-internet-gateway --internet-gateway-id igw-abc123 --vpc-id vpc-abc123'; Rx = @(
                '^\s*aws\s+ec2\s+attach-internet-gateway.*--internet-gateway-id\s+igw-abc123.*--vpc-id\s+vpc-abc123'
                '^\s*aws\s+ec2\s+attach-internet-gateway.*--vpc-id\s+vpc-abc123.*--internet-gateway-id\s+igw-abc123'
            )}}
        },
        @{
            Id = 'aws-vpc-listar'; Tipo = 'VPC'
            Tarea = 'Lista todas las VPCs de tu cuenta.'
            Exp = 'describe-vpcs muestra las VPCs con su CIDR, estado y si es la VPC por defecto.'
            R = @{ AWS = @{ Ej = 'aws ec2 describe-vpcs'; Rx = @(
                '^\s*aws\s+ec2\s+describe-vpcs'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  CloudWatch — Monitorización
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-cw-listar-alarmas'; Tipo = 'CloudWatch'
            Tarea = 'Lista todas las alarmas de CloudWatch.'
            Exp = 'describe-alarms muestra las alarmas configuradas, su estado (OK, ALARM, INSUFFICIENT_DATA) y sus umbrales.'
            R = @{ AWS = @{ Ej = 'aws cloudwatch describe-alarms'; Rx = @(
                '^\s*aws\s+cloudwatch\s+describe-alarms'
            )}}
        },
        @{
            Id = 'aws-cw-alarma-cpu'; Tipo = 'CloudWatch'
            Tarea = 'Crea una alarma llamada "cpu-alta" que salte cuando la CPU de la instancia "i-0abc123" supere el 80% durante 5 minutos (1 periodo de 300s).'
            Exp = 'put-metric-alarm crea alarmas. --statistic Average --period 300 --evaluation-periods 1 --threshold 80 vigila la media de CPU cada 5 minutos.'
            R = @{ AWS = @{ Ej = 'aws cloudwatch put-metric-alarm --alarm-name cpu-alta --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --evaluation-periods 1 --threshold 80 --comparison-operator GreaterThanThreshold --dimensions Name=InstanceId,Value=i-0abc123'; Rx = @(
                '^\s*aws\s+cloudwatch\s+put-metric-alarm.*--alarm-name\s+cpu-alta.*--metric-name\s+CPUUtilization.*--threshold\s+80'
                '^\s*aws\s+cloudwatch\s+put-metric-alarm.*--metric-name\s+CPUUtilization.*--alarm-name\s+cpu-alta.*--threshold\s+80'
            )}}
        },
        @{
            Id = 'aws-cw-borrar-alarma'; Tipo = 'CloudWatch'
            Tarea = 'Borra la alarma de CloudWatch llamada "cpu-alta".'
            Exp = 'delete-alarms puede borrar una o varias alarmas a la vez. Usa --alarm-names (plural).'
            R = @{ AWS = @{ Ej = 'aws cloudwatch delete-alarms --alarm-names cpu-alta'; Rx = @(
                '^\s*aws\s+cloudwatch\s+delete-alarms\s+--alarm-names\s+cpu-alta'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Lambda — Funciones serverless
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-lambda-listar'; Tipo = 'Lambda'
            Tarea = 'Lista todas las funciones Lambda de tu cuenta.'
            Exp = 'list-functions muestra las funciones con su runtime, tamaño y última modificación.'
            R = @{ AWS = @{ Ej = 'aws lambda list-functions'; Rx = @(
                '^\s*aws\s+lambda\s+list-functions'
            )}}
        },
        @{
            Id = 'aws-lambda-crear'; Tipo = 'Lambda'
            Tarea = 'Crea una función Lambda llamada "mi-funcion" con runtime nodejs18.x, handler "index.handler", rol "arn:aws:iam::123456789:role/lambda-role" y código en "funcion.zip".'
            Exp = 'create-function sube el código y configura el runtime. El handler es el punto de entrada (archivo.funcion). El rol define qué permisos tiene la función.'
            R = @{ AWS = @{ Ej = 'aws lambda create-function --function-name mi-funcion --runtime nodejs18.x --handler index.handler --role arn:aws:iam::123456789:role/lambda-role --zip-file fileb://funcion.zip'; Rx = @(
                '^\s*aws\s+lambda\s+create-function.*--function-name\s+mi-funcion.*--runtime\s+nodejs18\.x.*--zip-file\s+fileb://funcion\.zip'
                '^\s*aws\s+lambda\s+create-function.*--function-name\s+mi-funcion.*--zip-file\s+fileb://funcion\.zip.*--runtime\s+nodejs18\.x'
            )}}
        },
        @{
            Id = 'aws-lambda-invocar'; Tipo = 'Lambda'
            Tarea = 'Invoca (ejecuta) la función Lambda "mi-funcion" y guarda la respuesta en "respuesta.json".'
            Exp = 'invoke ejecuta la función y guarda su salida en un archivo. Puedes pasar datos con --payload.'
            R = @{ AWS = @{ Ej = 'aws lambda invoke --function-name mi-funcion respuesta.json'; Rx = @(
                '^\s*aws\s+lambda\s+invoke\s+--function-name\s+mi-funcion\s+respuesta\.json'
                '^\s*aws\s+lambda\s+invoke.*--function-name\s+mi-funcion.*respuesta\.json'
            )}}
        },
        @{
            Id = 'aws-lambda-borrar'; Tipo = 'Lambda'
            Tarea = 'Borra la función Lambda "mi-funcion".'
            Exp = 'delete-function elimina la función y su código. No se puede deshacer.'
            R = @{ AWS = @{ Ej = 'aws lambda delete-function --function-name mi-funcion'; Rx = @(
                '^\s*aws\s+lambda\s+delete-function\s+--function-name\s+mi-funcion'
            )}}
        },
        @{
            Id = 'aws-lambda-actualizar'; Tipo = 'Lambda'
            Tarea = 'Actualiza el código de la función "mi-funcion" subiendo un nuevo "funcion.zip".'
            Exp = 'update-function-code cambia solo el código sin tocar la configuración (runtime, rol, variables...).'
            R = @{ AWS = @{ Ej = 'aws lambda update-function-code --function-name mi-funcion --zip-file fileb://funcion.zip'; Rx = @(
                '^\s*aws\s+lambda\s+update-function-code\s+--function-name\s+mi-funcion\s+--zip-file\s+fileb://funcion\.zip'
                '^\s*aws\s+lambda\s+update-function-code.*--function-name\s+mi-funcion.*--zip-file\s+fileb://funcion\.zip'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  General — Configuración, costes, utilidades
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'aws-config-perfil'; Tipo = 'General'
            Tarea = 'Configura un perfil de AWS CLI llamado "produccion" (que pida las credenciales de ese entorno).'
            Exp = 'aws configure --profile nombre crea un perfil con nombre. Luego usas --profile produccion en cada comando, o exportas AWS_PROFILE.'
            R = @{ AWS = @{ Ej = 'aws configure --profile produccion'; Rx = @(
                '^\s*aws\s+configure\s+--profile\s+produccion'
            )}}
        },
        @{
            Id = 'aws-config-region'; Tipo = 'General'
            Tarea = 'Lista todas las regiones de AWS disponibles.'
            Exp = 'describe-regions te dice qué regiones puedes usar. Cada región tiene al menos 2 zonas de disponibilidad.'
            R = @{ AWS = @{ Ej = 'aws ec2 describe-regions'; Rx = @(
                '^\s*aws\s+ec2\s+describe-regions'
            )}}
        },
        @{
            Id = 'aws-config-output'; Tipo = 'General'
            Tarea = 'Lista tus instancias EC2 pero muestra la salida en formato tabla (en vez del JSON por defecto).'
            Exp = 'El parámetro --output table/json/text/yaml cambia el formato de salida. Table es más legible para humanos.'
            R = @{ AWS = @{ Ej = 'aws ec2 describe-instances --output table'; Rx = @(
                '^\s*aws\s+ec2\s+describe-instances\s+--output\s+table'
            )}}
        },
        @{
            Id = 'aws-config-query'; Tipo = 'General'
            Tarea = 'Lista solo los IDs de tus instancias EC2 usando --query (sin ver todo el JSON).'
            Exp = '--query usa sintaxis JMESPath para filtrar la salida. Reservations[*].Instances[*].InstanceId extrae solo los IDs.'
            R = @{ AWS = @{ Ej = "aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text"; Rx = @(
                '^\s*aws\s+ec2\s+describe-instances\s+--query.*Reservations.*Instances.*InstanceId'
            )}}
        },
        @{
            Id = 'aws-config-buscar-ami'; Tipo = 'General'
            Tarea = 'Busca la AMI más reciente de Amazon Linux 2023 (propiedad de Amazon).'
            Exp = 'describe-images con --owners amazon y --filters filtra entre miles de AMIs. --query y sort_by ordenan para quedarte con la más reciente.'
            R = @{ AWS = @{ Ej = "aws ec2 describe-images --owners amazon --filters 'Name=name,Values=al2023-ami-*' --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text"; Rx = @(
                '^\s*aws\s+ec2\s+describe-images\s+--owners\s+amazon.*al2023'
            )}}
        },
        @{
            Id = 'aws-s3-borrar-objeto'; Tipo = 'S3'
            Tarea = 'Borra el archivo "viejo.log" del bucket "logs-app".'
            Exp = 'aws s3 rm borra un objeto de S3. Para borrar todo un directorio virtual, añade --recursive.'
            R = @{ AWS = @{ Ej = 'aws s3 rm s3://logs-app/viejo.log'; Rx = @(
                '^\s*aws\s+s3\s+rm\s+s3://logs-app/viejo\.log'
                '^\s*aws\s+s3api\s+delete-object\s+--bucket\s+logs-app\s+--key\s+viejo\.log'
            )}}
        },
        @{
            Id = 'aws-ec2-ip-publica'; Tipo = 'EC2'
            Tarea = 'Consulta solo la IP pública de la instancia "i-0abc123" usando --query.'
            Exp = '--query con JMESPath extrae campos concretos del JSON. Para la IP pública: Reservations[0].Instances[0].PublicIpAddress.'
            R = @{ AWS = @{ Ej = "aws ec2 describe-instances --instance-ids i-0abc123 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text"; Rx = @(
                '^\s*aws\s+ec2\s+describe-instances\s+--instance-ids\s+i-0abc123\s+--query.*PublicIpAddress'
            )}}
        },
        @{
            Id = 'aws-iam-borrar-usuario'; Tipo = 'IAM'
            Tarea = 'Borra el usuario IAM "becario".'
            Exp = 'delete-user solo funciona si el usuario no tiene claves, políticas ni pertenece a grupos. Limpia todo eso antes.'
            R = @{ AWS = @{ Ej = 'aws iam delete-user --user-name becario'; Rx = @(
                '^\s*aws\s+iam\s+delete-user\s+--user-name\s+becario'
            )}}
        }
    )
}

# ================================================================= #
#                        LANZADOR                                    #
# ================================================================= #
function Invoke-AwsCli {
    [CmdletBinding()]
    param(
        [int]$Preguntas = 5,

        # Filtrar por servicio: S3, EC2, IAM, VPC, Lambda, CloudWatch, General
        [ValidateSet('Mix', 'S3', 'EC2', 'IAM', 'VPC', 'Lambda', 'CloudWatch', 'General')]
        [string]$Modo = 'Mix',

        # Solo lo que toca repasar hoy (Leitner)
        [switch]$Repaso
    )
    Invoke-DojoEngine -Banco (Get-AwsCliBanco) -Prefijo 'awscli' -Titulo 'AWS CLI: ENTRENAMIENTO DE COMANDOS EN TERMINAL' -Preguntas $Preguntas -Modo $Modo -Repaso:$Repaso
}

Set-Alias awscli   Invoke-AwsCli
Set-Alias aws-dojo Invoke-AwsCli
