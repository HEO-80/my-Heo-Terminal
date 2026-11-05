# ================================================================= #
#   ANSIBLE: ENTRENAMIENTO PRÁCTICO DE COMANDOS DESDE TERMINAL       #
# ================================================================= #
# IMPORTANTE: guardar como UTF-8 con BOM (o usar PowerShell 7).
#
# Cómo funciona:
#   ansible-dojo                te lanza 5 retos aleatorios
#   ansible-dojo -Preguntas 10  más retos de golpe
#   ansible-dojo -Modo Adhoc    solo retos de comandos ad-hoc (también: Playbook, Inventario, Rol, Modulo, Vault, Galaxy, General)
#   ansible-dojo -Repaso         solo lo que toca repasar hoy (Leitner)
#
# Cada reto te pide que escribas el comando ansible real o el bloque YAML.
# Depende de Motor.ps1 (progreso y repaso espaciado).

# Por si se carga este archivo suelto (sin el tema)
if (-not (Get-Command Write-Cyber -ErrorAction SilentlyContinue)) {
    function Write-Cyber {
        param([string]$Text, [string]$Color, [switch]$NoNewline)
        Write-Host $Text -NoNewline:$NoNewline
    }
}

# Registrar el "mundo" Ansible en el motor
if ($global:NombreMundo -and -not $global:NombreMundo.ContainsKey('Ansible')) {
    $global:NombreMundo['Ansible'] = 'terminal con Ansible'
}

# ================================================================= #
#                    BANCO DE RETOS ANSIBLE                          #
# ================================================================= #

function Get-AnsibleBanco {
    @(
        # ─────────────────────────────────────────────────────────────
        #  Comandos ad-hoc
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-ping'; Tipo = 'Adhoc'
            Tarea = 'Haz ping a todos los hosts del inventario para comprobar que Ansible puede conectarse.'
            Exp = 'ansible all -m ping es lo primero que se ejecuta. Comprueba SSH y Python en los nodos remotos. No es ICMP, es el módulo ping de Ansible.'
            R = @{ Ansible = @{ Ej = 'ansible all -m ping'; Rx = @(
                '^\s*ansible\s+all\s+-m\s+ping'
            )}}
        },
        @{
            Id = 'ans-adhoc-shell'; Tipo = 'Adhoc'
            Tarea = 'Ejecuta el comando "uptime" en todos los servidores del grupo "webservers".'
            Exp = 'ansible <grupo> -m shell -a "<comando>" ejecuta comandos en remoto. El módulo command (por defecto) no expande variables del shell.'
            R = @{ Ansible = @{ Ej = 'ansible webservers -m shell -a "uptime"'; Rx = @(
                '^\s*ansible\s+webservers\s+-(m\s+(shell|command)\s+-a|a)\s+.*uptime'
            )}}
        },
        @{
            Id = 'ans-adhoc-copy'; Tipo = 'Adhoc'
            Tarea = 'Copia el archivo local "/tmp/config.conf" a "/etc/app/config.conf" en todos los hosts del grupo "appservers".'
            Exp = 'El módulo copy sube archivos. src es la ruta local, dest la ruta remota. mode controla los permisos.'
            R = @{ Ansible = @{ Ej = 'ansible appservers -m copy -a "src=/tmp/config.conf dest=/etc/app/config.conf"'; Rx = @(
                '^\s*ansible\s+appservers\s+-m\s+copy\s+-a\s+.*src=/tmp/config\.conf.*dest=/etc/app/config\.conf'
            )}}
        },
        @{
            Id = 'ans-adhoc-apt'; Tipo = 'Adhoc'
            Tarea = 'Instala nginx en todos los hosts del grupo "webservers" usando el módulo apt (con become para sudo).'
            Exp = 'El módulo apt gestiona paquetes en Debian/Ubuntu. --become (-b) ejecuta con sudo. state=present es el valor por defecto.'
            R = @{ Ansible = @{ Ej = 'ansible webservers -m apt -a "name=nginx state=present" --become'; Rx = @(
                '^\s*ansible\s+webservers\s+.*-m\s+apt\s+-a\s+.*name=nginx.*(-b|--become)'
                '^\s*ansible\s+webservers\s+.*(-b|--become).*-m\s+apt\s+-a\s+.*name=nginx'
            )}}
        },
        @{
            Id = 'ans-adhoc-service'; Tipo = 'Adhoc'
            Tarea = 'Reinicia el servicio nginx en todos los hosts del grupo "webservers" (con become).'
            Exp = 'El módulo service gestiona servicios del sistema. state: started, stopped, restarted, reloaded.'
            R = @{ Ansible = @{ Ej = 'ansible webservers -m service -a "name=nginx state=restarted" --become'; Rx = @(
                '^\s*ansible\s+webservers\s+.*-m\s+service\s+-a\s+.*name=nginx.*state=restarted.*(-b|--become)'
                '^\s*ansible\s+webservers\s+.*(-b|--become).*-m\s+service\s+-a\s+.*name=nginx.*state=restarted'
            )}}
        },
        @{
            Id = 'ans-adhoc-user'; Tipo = 'Adhoc'
            Tarea = 'Crea el usuario "deploy" en todos los hosts (con become).'
            Exp = 'El módulo user gestiona cuentas. state=present crea, state=absent borra. Puedes añadir groups, shell, etc.'
            R = @{ Ansible = @{ Ej = 'ansible all -m user -a "name=deploy state=present" --become'; Rx = @(
                '^\s*ansible\s+all\s+.*-m\s+user\s+-a\s+.*name=deploy.*(-b|--become)'
            )}}
        },
        @{
            Id = 'ans-adhoc-facts'; Tipo = 'Adhoc'
            Tarea = 'Recoge los facts (información del sistema) del host "servidor1".'
            Exp = 'ansible <host> -m setup recoge facts: SO, IP, CPU, RAM, discos... Se pueden usar como variables en playbooks.'
            R = @{ Ansible = @{ Ej = 'ansible servidor1 -m setup'; Rx = @(
                '^\s*ansible\s+servidor1\s+-m\s+setup'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Playbooks — ejecución y sintaxis
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-playbook-run'; Tipo = 'Playbook'
            Tarea = 'Ejecuta el playbook "site.yml".'
            Exp = 'ansible-playbook es el comando principal. Ejecuta las tareas del playbook en orden contra los hosts definidos.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook site.yml'; Rx = @(
                '^\s*ansible-playbook\s+site\.yml'
            )}}
        },
        @{
            Id = 'ans-playbook-check'; Tipo = 'Playbook'
            Tarea = 'Ejecuta el playbook "deploy.yml" en modo check (dry run, sin hacer cambios reales).'
            Exp = '--check es el "dry run" de Ansible. Muestra qué cambiaría SIN tocar nada. Algunos módulos no soportan check mode.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook deploy.yml --check'; Rx = @(
                '^\s*ansible-playbook\s+deploy\.yml\s+--check'
                '^\s*ansible-playbook\s+deploy\.yml\s+-C'
            )}}
        },
        @{
            Id = 'ans-playbook-diff'; Tipo = 'Playbook'
            Tarea = 'Ejecuta el playbook "config.yml" mostrando las diferencias de cada cambio (modo diff).'
            Exp = '--diff muestra un diff de los archivos modificados. Combinado con --check ves qué cambiaría sin hacerlo.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook config.yml --diff'; Rx = @(
                '^\s*ansible-playbook\s+config\.yml\s+--diff'
                '^\s*ansible-playbook\s+config\.yml\s+-D'
            )}}
        },
        @{
            Id = 'ans-playbook-limit'; Tipo = 'Playbook'
            Tarea = 'Ejecuta el playbook "site.yml" solo contra el host "servidor1".'
            Exp = '--limit restringe la ejecución a un host o grupo. Muy útil para probar cambios en un solo servidor antes de aplicar a todos.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook site.yml --limit servidor1'; Rx = @(
                '^\s*ansible-playbook\s+site\.yml\s+--limit\s+servidor1'
                '^\s*ansible-playbook\s+site\.yml\s+-l\s+servidor1'
            )}}
        },
        @{
            Id = 'ans-playbook-tags'; Tipo = 'Playbook'
            Tarea = 'Ejecuta solo las tareas etiquetadas con "config" del playbook "site.yml".'
            Exp = '--tags ejecuta SOLO las tareas con esa etiqueta. --skip-tags hace lo contrario. Las etiquetas se definen en las tareas del YAML.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook site.yml --tags config'; Rx = @(
                '^\s*ansible-playbook\s+site\.yml\s+--tags\s+config'
                '^\s*ansible-playbook\s+site\.yml\s+-t\s+config'
            )}}
        },
        @{
            Id = 'ans-playbook-verbose'; Tipo = 'Playbook'
            Tarea = 'Ejecuta el playbook "debug.yml" con máxima verbosidad para ver todo el detalle.'
            Exp = '-v aumenta la verbosidad (hasta -vvvv). -vvv muestra las conexiones SSH, -vvvv muestra los scripts enviados.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook debug.yml -vvvv'; Rx = @(
                '^\s*ansible-playbook\s+debug\.yml\s+-vvv'
            )}}
        },
        @{
            Id = 'ans-playbook-yaml'; Tipo = 'Playbook'
            Tarea = 'Escribe un playbook mínimo que instale nginx en los hosts del grupo "webservers" (con become, módulo apt).'
            Exp = 'Un playbook tiene: hosts (a quién), become (si necesita sudo), y tasks (qué hacer). Es un YAML con una lista de plays.'
            R = @{ Ansible = @{ Ej = @'
- hosts: webservers
  become: true
  tasks:
    - name: Instalar nginx
      apt:
        name: nginx
        state: present
'@; Rx = @(
                '-\s*hosts:\s*webservers[\s\S]*become:\s*true[\s\S]*tasks:[\s\S]*apt:[\s\S]*name:\s*nginx[\s\S]*state:\s*present'
                '-\s*hosts:\s*webservers[\s\S]*become:\s*(true|yes)[\s\S]*tasks:[\s\S]*ansible\.builtin\.apt:[\s\S]*name:\s*nginx'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Inventario
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-inventario-ini'; Tipo = 'Inventario'
            Tarea = 'Escribe un inventario INI con el grupo "webservers" que contenga los hosts "web1" (IP 10.0.1.10) y "web2" (IP 10.0.1.11).'
            Exp = 'El inventario define los hosts y grupos. Formato INI: [grupo] seguido de los hosts. Se puede añadir ansible_host= para la IP.'
            R = @{ Ansible = @{ Ej = @'
[webservers]
web1 ansible_host=10.0.1.10
web2 ansible_host=10.0.1.11
'@; Rx = @(
                '\[webservers\][\s\S]*web1\s+ansible_host=10\.0\.1\.10[\s\S]*web2\s+ansible_host=10\.0\.1\.11'
            )}}
        },
        @{
            Id = 'ans-inventario-cmd'; Tipo = 'Inventario'
            Tarea = 'Ejecuta el playbook "site.yml" usando el inventario del archivo "inventario/produccion".'
            Exp = '-i especifica el archivo de inventario. Sin -i, Ansible usa /etc/ansible/hosts. Puedes tener uno por entorno.'
            R = @{ Ansible = @{ Ej = 'ansible-playbook site.yml -i inventario/produccion'; Rx = @(
                '^\s*ansible-playbook\s+site\.yml\s+-i\s+inventario/produccion'
            )}}
        },
        @{
            Id = 'ans-inventario-listar'; Tipo = 'Inventario'
            Tarea = 'Lista todos los hosts del inventario por defecto mostrando a qué grupos pertenecen.'
            Exp = 'ansible-inventory --list muestra el inventario completo en JSON. --graph lo muestra como árbol. Útil para verificar la estructura.'
            R = @{ Ansible = @{ Ej = 'ansible-inventory --list'; Rx = @(
                '^\s*ansible-inventory\s+--list'
                '^\s*ansible-inventory\s+--graph'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Roles — estructura y creación
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-rol-init'; Tipo = 'Rol'
            Tarea = 'Crea la estructura de carpetas para un nuevo rol llamado "webserver".'
            Exp = 'ansible-galaxy role init crea la estructura estándar: tasks/, handlers/, templates/, files/, vars/, defaults/, meta/.'
            R = @{ Ansible = @{ Ej = 'ansible-galaxy role init webserver'; Rx = @(
                '^\s*ansible-galaxy\s+role\s+init\s+webserver'
            )}}
        },
        @{
            Id = 'ans-rol-usar'; Tipo = 'Rol'
            Tarea = 'Escribe un playbook que aplique los roles "common" y "webserver" a los hosts del grupo "webservers".'
            Exp = 'roles: define qué roles aplicar. Se ejecutan en orden. Cada rol es una unidad reutilizable con sus propias tareas, variables, templates, etc.'
            R = @{ Ansible = @{ Ej = @'
- hosts: webservers
  become: true
  roles:
    - common
    - webserver
'@; Rx = @(
                '-\s*hosts:\s*webservers[\s\S]*roles:[\s\S]*-\s*common[\s\S]*-\s*webserver'
            )}}
        },
        @{
            Id = 'ans-handler-yaml'; Tipo = 'Rol'
            Tarea = 'Escribe una tarea que copie un template de nginx y notifique al handler "Reiniciar nginx" cuando cambie.'
            Exp = 'Los handlers se ejecutan SOLO cuando una tarea los notifica con "notify". Se usan para reiniciar servicios tras cambios de configuración.'
            R = @{ Ansible = @{ Ej = @'
- name: Copiar configuracion nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Reiniciar nginx
'@; Rx = @(
                'template:[\s\S]*src:.*nginx[\s\S]*dest:.*nginx[\s\S]*notify:.*[Rr]einiciar nginx'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Módulos comunes — escritura de tareas
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-modulo-template'; Tipo = 'Modulo'
            Tarea = 'Escribe una tarea que despliegue el template "app.conf.j2" a "/etc/app/app.conf" con owner root y permisos 0644.'
            Exp = 'El módulo template procesa archivos Jinja2 y los copia al destino. A diferencia de copy, resuelve las variables {{ }} del template.'
            R = @{ Ansible = @{ Ej = @'
- name: Desplegar configuracion
  template:
    src: app.conf.j2
    dest: /etc/app/app.conf
    owner: root
    mode: "0644"
'@; Rx = @(
                'template:[\s\S]*src:\s*app\.conf\.j2[\s\S]*dest:\s*/etc/app/app\.conf[\s\S]*owner:\s*root[\s\S]*mode:.*0644'
            )}}
        },
        @{
            Id = 'ans-modulo-lineinfile'; Tipo = 'Modulo'
            Tarea = 'Escribe una tarea que asegure que la línea "PermitRootLogin no" existe en /etc/ssh/sshd_config.'
            Exp = 'lineinfile modifica una sola línea de un archivo. Si la línea existe la actualiza, si no la añade. Muy usado para configuraciones.'
            R = @{ Ansible = @{ Ej = @'
- name: Deshabilitar root login SSH
  lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "^PermitRootLogin"
    line: "PermitRootLogin no"
'@; Rx = @(
                'lineinfile:[\s\S]*path:\s*/etc/ssh/sshd_config[\s\S]*line:.*PermitRootLogin\s+no'
            )}}
        },
        @{
            Id = 'ans-modulo-file'; Tipo = 'Modulo'
            Tarea = 'Escribe una tarea que cree el directorio "/opt/app/logs" con owner "deploy", grupo "deploy" y permisos 0755.'
            Exp = 'El módulo file gestiona archivos y directorios. state: directory crea carpetas, state: absent borra, state: touch crea archivos vacíos.'
            R = @{ Ansible = @{ Ej = @'
- name: Crear directorio de logs
  file:
    path: /opt/app/logs
    state: directory
    owner: deploy
    group: deploy
    mode: "0755"
'@; Rx = @(
                'file:[\s\S]*path:\s*/opt/app/logs[\s\S]*state:\s*directory[\s\S]*owner:\s*deploy'
            )}}
        },
        @{
            Id = 'ans-modulo-when'; Tipo = 'Modulo'
            Tarea = 'Escribe una tarea que instale httpd con yum solo cuando el SO sea RedHat o CentOS (usando ansible_os_family).'
            Exp = 'when: es el condicional de Ansible. Usa los facts del sistema (ansible_os_family, ansible_distribution, etc.) para decidir si ejecutar la tarea.'
            R = @{ Ansible = @{ Ej = @'
- name: Instalar httpd en RedHat
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"
'@; Rx = @(
                'yum:[\s\S]*name:\s*httpd[\s\S]*when:.*ansible_os_family.*==.*"?RedHat"?'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Vault — secretos
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-vault-crear'; Tipo = 'Vault'
            Tarea = 'Crea un archivo cifrado con Ansible Vault llamado "secrets.yml".'
            Exp = 'ansible-vault create crea un nuevo archivo cifrado. Te pide una contraseña para cifrarlo. Edita con ansible-vault edit.'
            R = @{ Ansible = @{ Ej = 'ansible-vault create secrets.yml'; Rx = @(
                '^\s*ansible-vault\s+create\s+secrets\.yml'
            )}}
        },
        @{
            Id = 'ans-vault-encrypt'; Tipo = 'Vault'
            Tarea = 'Cifra el archivo existente "passwords.yml" con Ansible Vault.'
            Exp = 'ansible-vault encrypt cifra un archivo que ya existe en texto plano. decrypt lo descifra. view lo muestra sin descifrarlo permanentemente.'
            R = @{ Ansible = @{ Ej = 'ansible-vault encrypt passwords.yml'; Rx = @(
                '^\s*ansible-vault\s+encrypt\s+passwords\.yml'
            )}}
        },
        @{
            Id = 'ans-vault-playbook'; Tipo = 'Vault'
            Tarea = 'Ejecuta el playbook "deploy.yml" pidiéndote la contraseña de Vault por terminal.'
            Exp = '--ask-vault-pass pide la contraseña en la terminal. --vault-password-file apunta a un archivo con la contraseña (para CI/CD).'
            R = @{ Ansible = @{ Ej = 'ansible-playbook deploy.yml --ask-vault-pass'; Rx = @(
                '^\s*ansible-playbook\s+deploy\.yml\s+--ask-vault-pass'
                '^\s*ansible-playbook\s+deploy\.yml\s+--ask-vault-password'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  Galaxy — repositorio de roles y colecciones
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-galaxy-instalar'; Tipo = 'Galaxy'
            Tarea = 'Instala el rol "geerlingguy.docker" desde Ansible Galaxy.'
            Exp = 'Ansible Galaxy es el repositorio público de roles y colecciones. geerlingguy es uno de los autores más populares.'
            R = @{ Ansible = @{ Ej = 'ansible-galaxy role install geerlingguy.docker'; Rx = @(
                '^\s*ansible-galaxy\s+(role\s+)?install\s+geerlingguy\.docker'
            )}}
        },
        @{
            Id = 'ans-galaxy-requirements'; Tipo = 'Galaxy'
            Tarea = 'Instala todos los roles y colecciones definidos en el archivo "requirements.yml".'
            Exp = 'requirements.yml centraliza las dependencias externas del proyecto. Se instalan todas con un solo comando.'
            R = @{ Ansible = @{ Ej = 'ansible-galaxy install -r requirements.yml'; Rx = @(
                '^\s*ansible-galaxy\s+(role\s+)?install\s+-r\s+requirements\.yml'
            )}}
        },
        @{
            Id = 'ans-galaxy-collection'; Tipo = 'Galaxy'
            Tarea = 'Instala la colección "community.general" desde Ansible Galaxy.'
            Exp = 'Las colecciones agrupan módulos, roles y plugins. community.general tiene cientos de módulos extra que no vienen con Ansible core.'
            R = @{ Ansible = @{ Ej = 'ansible-galaxy collection install community.general'; Rx = @(
                '^\s*ansible-galaxy\s+collection\s+install\s+community\.general'
            )}}
        },

        # ─────────────────────────────────────────────────────────────
        #  General — otros comandos útiles
        # ─────────────────────────────────────────────────────────────
        @{
            Id = 'ans-version'; Tipo = 'General'
            Tarea = 'Muestra la versión de Ansible y la información de configuración.'
            Exp = 'ansible --version muestra la versión, la ruta del config, los módulos y el intérprete Python usado.'
            R = @{ Ansible = @{ Ej = 'ansible --version'; Rx = @(
                '^\s*ansible\s+--version'
            )}}
        },
        @{
            Id = 'ans-doc'; Tipo = 'General'
            Tarea = 'Consulta la documentación del módulo "apt" desde la terminal.'
            Exp = 'ansible-doc <módulo> muestra la documentación completa con ejemplos. -l lista todos los módulos disponibles.'
            R = @{ Ansible = @{ Ej = 'ansible-doc apt'; Rx = @(
                '^\s*ansible-doc\s+apt'
            )}}
        },
        @{
            Id = 'ans-lint'; Tipo = 'General'
            Tarea = 'Analiza el playbook "site.yml" con ansible-lint para detectar malas prácticas.'
            Exp = 'ansible-lint comprueba buenas prácticas: nombres en tareas, uso de command vs shell, permisos, etc. Se instala con pip.'
            R = @{ Ansible = @{ Ej = 'ansible-lint site.yml'; Rx = @(
                '^\s*ansible-lint\s+site\.yml'
            )}}
        },
        @{
            Id = 'ans-config'; Tipo = 'General'
            Tarea = 'Muestra la configuración activa de Ansible y de dónde la está leyendo.'
            Exp = 'ansible-config dump muestra TODA la configuración. --only-changed muestra solo lo que difiere del valor por defecto.'
            R = @{ Ansible = @{ Ej = 'ansible-config dump --only-changed'; Rx = @(
                '^\s*ansible-config\s+(dump|view|list)'
            )}}
        }
    )
}

# ================================================================= #
#                        LANZADOR                                    #
# ================================================================= #
function Invoke-Ansible {
    [CmdletBinding()]
    param(
        [int]$Preguntas = 5,

        # Filtrar por tema: Adhoc, Playbook, Inventario, Rol, Modulo, Vault, Galaxy, General
        [ValidateSet('Mix', 'Adhoc', 'Playbook', 'Inventario', 'Rol', 'Modulo', 'Vault', 'Galaxy', 'General')]
        [string]$Modo = 'Mix',

        # Solo lo que toca repasar hoy (Leitner)
        [switch]$Repaso
    )
    Invoke-DojoEngine -Banco (Get-AnsibleBanco) -Prefijo 'ansible' -Titulo 'ANSIBLE: ENTRENAMIENTO DE AUTOMATIZACIÓN Y CONFIGURACIÓN' -Preguntas $Preguntas -Modo $Modo -Repaso:$Repaso
}

Set-Alias ansible-dojo Invoke-Ansible
Set-Alias ans-dojo     Invoke-Ansible
