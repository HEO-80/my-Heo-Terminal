# ================================================================= #
#                    CONFIGURACION CyberPunk 2077                   #
#                    my-Heo-Terminal (private)                       #
# ================================================================= #
# IMPORTANTE: guardar como UTF-8 con BOM (o usar PowerShell 7).

Clear-Host

# ── Helper de color ANSI directo ──────────────────────────────────
function Write-Cyber {
    param(
        [string]$Text,
        [string]$Color = "#FCEE0A",
        [switch]$NoNewline
    )
    $esc   = [char]27
    $r     = [Convert]::ToInt32($Color.Substring(1,2), 16)
    $g     = [Convert]::ToInt32($Color.Substring(3,2), 16)
    $b     = [Convert]::ToInt32($Color.Substring(5,2), 16)
    $ansi  = "${esc}[38;2;${r};${g};${b}m"
    $reset = "${esc}[0m"
    if ($NoNewline) {
        Write-Host "$ansi$Text$reset" -NoNewline
    } else {
        Write-Host "$ansi$Text$reset"
    }
}

# ── Paleta global ─────────────────────────────────────────────────
$global:CY = @{
    Yellow  = "#FCEE0A"
    Green   = "#39FF14"
    Cyan    = "#00F0FF"
    Magenta = "#C678DD"
    Dark    = "#555555"
    Dim     = "#888888"
}

# Banner (definido en el perfil)
if ($global:ShowBanner -and (Get-Command Show-AsciiArt -ErrorAction SilentlyContinue)) {
    Show-AsciiArt
}

# ================================================================= #
#                        MODULOS Y HERRAMIENTAS                     #
# ================================================================= #
function Import-ModuleSafe {
    param([string]$Name)
    try {
        Import-Module $Name -ErrorAction Stop
        return $true
    } catch {
        Write-Cyber "  [!] Falta el modulo '$Name'  ->  Install-Module $Name -Scope CurrentUser" $global:CY.Dim
        return $false
    }
}

$null = Import-ModuleSafe "Terminal-Icons"

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
} else {
    Write-Cyber "  [!] zoxide no instalado  ->  winget install ajeetdsouza.zoxide" $global:CY.Dim
}

# fzf + PSFzf
if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
    $fzfPath = Get-ChildItem "$env:LocalAppData\Microsoft\WinGet\Packages\junegunn.fzf*\fzf.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty DirectoryName
    if ($fzfPath) { $env:PATH += ";$fzfPath" }
}

# ── PSReadLine ────────────────────────────────────────────────────
try { Set-PSReadLineOption -PredictionSource History } catch {}
try { Set-PSReadLineOption -PredictionViewStyle InlineView } catch {}
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -BellStyle None

Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+a    -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+e    -Function EndOfLine
Set-PSReadLineKeyHandler -Key Alt+d     -Function KillWord
Set-PSReadLineKeyHandler -Key Ctrl+w    -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+l    -Function ClearScreen

if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Import-ModuleSafe "PSFzf")) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ================================================================= #
#                           OH MY POSH                              #
# ================================================================= #
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config (Join-Path $PSScriptRoot "omp_cyberpunk.json") | Invoke-Expression
} else {
    Write-Cyber "  [!] oh-my-posh no instalado  ->  winget install JanDeDobbeleer.OhMyPosh" $global:CY.Dim
}

# ================================================================= #
#                    ATAJOS Y FUNCIONES PERSONALES                  #
# ================================================================= #
$global:ReposPath = Join-Path $HOME "Source\Repos"

function n    { Start-Process "https://www.notion.so/" }
function o    { Start-Process "obsidian://" }
function g    { Start-Process "https://mail.google.com" }
function vsc  { code . }
function proj { code $global:ReposPath }

# ================================================================= #
#                 COMANDOS ERGONOMICOS                              #
# ================================================================= #

function top-size ($count = 10) {
    Get-ChildItem -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $count Name, @{N="Tamano (MB)"; E={[math]::Round($_.Length / 1MB, 2)}}
}

function top-cpu ($count = 5) {
    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First $count ProcessName, @{N="CPU (s)"; E={[math]::Round($_.CPU, 1)}}, @{N="RAM (MB)"; E={[math]::Round($_.WorkingSet64 / 1MB, 1)}}
}

function matar {
    param(
        [Parameter(Mandatory)]
        [ValidateLength(1,50)]
        [string]$Objetivo
    )
    if ($Objetivo -match '^\d+$') {
        $procs = @(Get-Process -Id ([int]$Objetivo) -ErrorAction SilentlyContinue)
    } else {
        if ($Objetivo.Length -lt 3) { Write-Cyber "Por nombre, escribe al menos 3 letras (o usa el PID: matar 12345)." $global:CY.Dim; return }
        $procs = @(Get-Process -Name "*$Objetivo*" -ErrorAction SilentlyContinue)
    }
    if ($procs.Count -eq 0) {
        Write-Cyber "Sin coincidencias para '$Objetivo'." $global:CY.Dim
        return
    }
    $procs |
        Stop-Process -Confirm -PassThru |
        ForEach-Object { Write-Cyber "Proceso detenido: $($_.ProcessName) (PID: $($_.Id))" $global:CY.Green }
}

function puertos {
    Get-NetTCPConnection -State Listen |
        Select-Object LocalAddress, LocalPort, OwningProcess,
            @{N="Proceso"; E={ (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName }} |
        Sort-Object LocalPort
}

function clean-logs {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param()
    Get-ChildItem -Include *.log, *.tmp -Recurse -File -ErrorAction SilentlyContinue |
        Remove-Item -Force -Verbose
}

# ================================================================= #
#                     CARGAR TRAINING                               #
# ================================================================= #
$_trainingDir = Join-Path (Split-Path $PSScriptRoot) "training"
if (Test-Path $_trainingDir) {
    # Motor.ps1 primero (sistema Leitner para todo)
    foreach ($f in "Motor.ps1", "Dojo.ps1", "Dojo2.ps1", "Tatami1.ps1", "Tatami2.ps1", "Forja.ps1", "Santuario.ps1", "Reto.ps1", "PwShell.ps1", "PwShell2.ps1", "Comandos.ps1", "Terraform.ps1", "AwsCli.ps1", "AzureCli.ps1", "Ansible.ps1") {
        $ruta = Join-Path $_trainingDir $f
        if (Test-Path $ruta) { . $ruta }
    }
    # Dev.ps1 esta en themes/
    $devFile = Join-Path $PSScriptRoot "Dev.ps1"
    if (Test-Path $devFile) { . $devFile }
}

# ================================================================= #
#                    WORKSPACE LAUNCHER                             #
# ================================================================= #
function Open-Chrome {
    param([string]$Prof)
    Start-Process "chrome.exe" "--profile-directory=`"$Prof`""
}

function Start-Workspaces {
    Write-Host "Abriendo perfiles de Chrome..." -ForegroundColor Cyan
    Open-Chrome "Profile 9"   # DeV
    Open-Chrome "Profile 7"   # Docencia
    Open-Chrome "Profile 10"  # Study
    Open-Chrome "Profile 8"   # Ocio
    Open-Chrome "Default"     # Hector (principal)
    Write-Host "Todos los perfiles abiertos. Arrastra cada ventana a su escritorio con Win+Shift+Flechas." -ForegroundColor Green
}

function chrome-dev      { Open-Chrome "Profile 9" }
function chrome-docencia { Open-Chrome "Profile 7" }
function chrome-study    { Open-Chrome "Profile 10" }
function chrome-ocio     { Open-Chrome "Profile 8" }
function chrome-hector   { Open-Chrome "Default" }
function chrome-heroes   { Open-Chrome "Profile 2" }
function chrome-vault    { Open-Chrome "Profile 1" }

Set-Alias workspaces Start-Workspaces

function Start-MySetup {
    chrome-dev
    Start-Sleep -Seconds 2
    chrome-study
    Start-Sleep -Seconds 2
    chrome-ocio
    Start-Process "https://192.168.1.141:8006/?console=kvm&novnc=1&vmid=100&vmname=kali-cyber&node=cyberlab"
    Write-Host "Todo abierto. Reparte con Win+Shift+Flechas." -ForegroundColor Green
}

Set-Alias setup Start-MySetup

# ================================================================= #
#                  DATOS UNICOS (dashboard + ayuda)                 #
# ================================================================= #

$global:Shortcuts = @(
    @{ Label = "Notion (n)";        Value = "Start-Process https://www.notion.so/" }
    @{ Label = "Obsidian (o)";      Value = "Start-Process obsidian://" }
    @{ Label = "Gmail (g)";         Value = "Start-Process https://mail.google.com" }
    @{ Label = "VS Code (vsc)";     Value = "code ." }
    @{ Label = "Abrir Proj (proj)"; Value = "code $($global:ReposPath)" }
    @{ Label = "CyberLab (lab)";    Value = "ssh cyberlab   (Proxmox)" }
    @{ Label = "Kali (kali)";       Value = "ssh kali       (LAN)" }
    @{ Label = "Kali remoto (kalir)"; Value = "ssh kali-remote (Tailscale)" }
    @{ Label = "Proxmox (proxmox)"; Value = "https://100.74.146.107:8006" }
)

$global:HelpData = [ordered]@{
    "NAVEGACION Y PANTALLA (SIN RATON)" = @(
        @{ K = "Shift + RePag / AvPag";       D = "Scroll arriba/abajo en Windows Terminal, sin raton" }
        @{ K = "Ctrl + Shift + Arriba/Abajo"; D = "Desplazar la pantalla linea a linea (Windows Terminal)" }
        @{ K = "ls | more";                   D = "Paginar listas largas (Espacio avanza, Q sale)" }
        @{ K = "cd -";                        D = "Volver a la carpeta anterior (solo PowerShell 7)" }
        @{ K = "z <nombre>";                  D = "zoxide: saltar a carpetas frecuentes (zi = interactivo)" }
    )
    "ATAJOS DE WINDOWS Y ESCRITORIOS" = @(
        @{ K = "Win + R  ->  wt";        D = "Lanzar Windows Terminal al instante" }
        @{ K = "Win + Flechas";          D = "Maximizar, minimizar o acoplar ventana a los lados" }
        @{ K = "Alt + Tab";              D = "Cambiar a la siguiente ventana" }
        @{ K = "Ctrl + Win + Flechas";   D = "Cambiar entre escritorios virtuales (izq/der)" }
        @{ K = "Ctrl + Win + D";         D = "Crear un nuevo escritorio virtual" }
    )
    "HERRAMIENTAS INSTALADAS" = @(
        @{ K = "Terminal-Icons"; D = "ls / dir  ->  iconos junto a archivos y carpetas" }
        @{ K = "fzf (PSFzf)";    D = "Busqueda difusa de archivos e historial (ver Ctrl+T / Ctrl+R)" }
        @{ K = "PSReadLine";     D = "Prediccion del historial en gris (Flecha derecha la acepta)" }
        @{ K = "zoxide";         D = "z nombre_carpeta  ->  salta a carpetas visitadas" }
        @{ K = "Oh My Posh";     D = "Prompt con rama git, ruta y colores (automatico)" }
    )
    "ATAJOS DE TECLADO" = @(
        @{ K = "Tab";              D = "Menu de autocompletado navegable" }
        @{ K = "Ctrl + T";         D = "fzf: buscar archivos en la carpeta actual" }
        @{ K = "Ctrl + R";         D = "fzf: buscar en el historial" }
        @{ K = "Ctrl + A / Ctrl + E"; D = "Inicio / final de linea" }
        @{ K = "Alt + D";          D = "Borrar palabra hacia adelante" }
        @{ K = "Ctrl + W";         D = "Borrar palabra hacia atras" }
        @{ K = "Ctrl + L";         D = "Limpiar pantalla" }
    )
    "FUNCIONES PERSONALES" = @(
        @{ K = "n / o / g";           D = "Abrir Notion / Obsidian / Gmail" }
        @{ K = "vsc / proj";          D = "Abrir VS Code (carpeta actual / repositorios)" }
        @{ K = "top-size [n]";        D = "Los N archivos mas pesados de la carpeta" }
        @{ K = "top-cpu [n]";         D = "Los N procesos con mas consumo de CPU" }
        @{ K = "matar <nombre|pid>";  D = "Cerrar procesos por nombre o PID; pide confirmacion" }
        @{ K = "puertos";             D = "Puertos locales en escucha, con su proceso" }
        @{ K = "clean-logs [-WhatIf]"; D = "Borra .log y .tmp recursivamente (-WhatIf = simular)" }
        @{ K = "dojo / quiz";         D = "Dojo 1 (nombres de comandos): -Modo Linux|PowerShell|Cmd" }
        @{ K = "dojo2";               D = "Dojo 2 (comandos completos, nivel intermedio)" }
        @{ K = "rosetta";             D = "Tabla de equivalencias Linux / PowerShell / cmd" }
        @{ K = "tatami [-Repaso]";    D = "Tatami 1: misiones basicas en un sandbox temporal" }
        @{ K = "tatami2 [-Repaso]";   D = "Tatami 2: misiones intermedias" }
        @{ K = "forja [-Repaso]";     D = "Forja: escribe scripts PowerShell con tests" }
        @{ K = "santuario [-Repaso]"; D = "Santuario: escribe scripts bash (WSL)" }
        @{ K = "reto [-Repaso]";      D = "Reto: archivos, carpetas y permisos (icacls, attrib)" }
        @{ K = "pwshell2";            D = "Scripting avanzado: variables, funciones, JSON, servicios" }
        @{ K = "comandos";            D = "CMD y scripts .bat" }
        @{ K = "terraform-dojo";      D = "Terraform: init, plan, apply, state, modules" }
        @{ K = "awscli";              D = "AWS CLI: S3, EC2, IAM, VPC, Lambda, CloudWatch" }
        @{ K = "azcli";               D = "Azure CLI: VMs, App Service, AKS, Storage, IAM" }
        @{ K = "ansible-dojo";        D = "Ansible: ad-hoc, playbooks, roles, vault, galaxy" }
        @{ K = "progreso";            D = "Tu estado: dominados, pendientes, los que mas fallas" }
        @{ K = "bee / lab / kali";    D = "SSH al Beelink / CyberLab / Kali" }
        @{ K = "workspaces / setup";  D = "Abrir todos los Chrome / mi setup completo" }
        @{ K = "Show-Dashboard";      D = "Dashboard (-Refresh actualiza cache, -SinDocker lo omite)" }
        @{ K = "Measure-Profile";     D = "Mide cuanto tarda en arrancar el perfil" }
        @{ K = "help-ps";             D = "Mostrar este menu de ayuda" }
    )
}

# ================================================================= #
#                            DASHBOARD                              #
# ================================================================= #
function Get-SysInfoCached {
    param([switch]$Refresh)
    $dir = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA "CyberProfile" } else { Join-Path $HOME ".cache/cyberprofile" }
    $file = Join-Path $dir "sysinfo.json"
    if ($Refresh -and (Test-Path $file)) { Remove-Item $file -Force -ErrorAction SilentlyContinue }
    if (Test-Path $file) {
        $edad = (Get-Date) - (Get-Item $file).LastWriteTime
        if ($edad.TotalHours -lt 24) {
            try { return (Get-Content $file -Raw | ConvertFrom-Json) } catch {}
        }
    }
    try {
        $cpu = ((Get-CimInstance Win32_Processor | Select-Object -First 1).Name -replace 'AMD | 8-Core| Processor| @.*$', '').Trim()
        $ram = "{0:N2} GB" -f ((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        $os  = (Get-CimInstance Win32_OperatingSystem).Caption
    } catch {
        $cpu = "n/d"; $ram = "n/d"; $os = "n/d"
    }
    $info = [pscustomobject]@{ CPU = $cpu; RAM = $ram; OS = $os }
    try {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        $info | ConvertTo-Json | Set-Content -Path $file -Encoding UTF8
    } catch {}
    return $info
}

function Show-Dashboard {
    param(
        [switch]$Refresh,
        [switch]$SinDocker
    )

    $c   = $global:CY
    $sys = Get-SysInfoCached -Refresh:$Refresh

    $sessionInfo = [ordered]@{
        "Started" = (Get-Date -Format "yyyy-MM-dd HH:mm")
        "Shell"   = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor) $($PSVersionTable.PSEdition)"
        "CPU"     = $sys.CPU
        "RAM"     = $sys.RAM
        "User"    = [Environment]::UserName
        "OS"      = $sys.OS
    }

    $shortcuts = $global:Shortcuts
    $features  = $global:HelpData["HERRAMIENTAS INSTALADAS"]

    $sep  = "=" * 80
    $sep2 = "-" * 80
    $colIzq = 38

    Write-Cyber $sep $c.Magenta
    Write-Host ""
    Write-Cyber "$("System Info".PadRight($colIzq))| Shortcuts" $c.Green
    Write-Host ""

    $maxLines = [System.Math]::Max($sessionInfo.Count, $shortcuts.Count)
    $sysKeys  = @($sessionInfo.Keys)

    for ($i = 0; $i -lt $maxLines; $i++) {
        if ($i -lt $sysKeys.Count) {
            $k = $sysKeys[$i]
            $v = "$($sessionInfo[$k])"
            if ($v.Length -gt 26) { $v = $v.Substring(0, 25) + "..." }
            Write-Cyber "$($k.PadRight(10))" $c.Yellow -NoNewline
            Write-Cyber ": " $c.Magenta -NoNewline
            Write-Cyber $v.PadRight(26) $c.Cyan -NoNewline
        } else {
            Write-Host "".PadRight($colIzq) -NoNewline
        }
        if ($i -lt $shortcuts.Count) {
            Write-Cyber "| " $c.Magenta -NoNewline
            Write-Cyber "$($shortcuts[$i].Label.PadRight(18))" $c.Yellow -NoNewline
            Write-Cyber " $($shortcuts[$i].Value)" $c.Cyan
        } else { Write-Host "" }
    }

    Write-Host ""
    Write-Cyber $sep2 $c.Magenta
    Write-Host ""
    Write-Cyber "  Features instalados   (help-ps para todo)" $c.Green
    Write-Host ""
    foreach ($f in $features) {
        Write-Cyber "  $($f.K.PadRight(16))" $c.Yellow -NoNewline
        Write-Cyber "  $($f.D)" $c.Cyan
    }

    if (Get-Command Get-CyberDueCount -ErrorAction SilentlyContinue) {
        $pend = Get-CyberDueCount
        if ($pend -gt 0) {
            Write-Host ""
            Write-Cyber "  Repaso pendiente: $pend  ->  dojo/tatami/forja/reto/pwshell2/comandos/terraform/awscli/azcli/ansible  con  -Repaso" $c.Magenta
        }
    }

    if (-not $SinDocker) {
        Write-Host ""
        Write-Cyber $sep2 $c.Magenta
        Write-Host ""
        Write-Cyber "  Docker" $c.Green
        Write-Host ""
        if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
            Write-Cyber "  Docker no instalado o no disponible en PATH." $c.Dim
        }
        elseif (-not (Get-Process -Name "com.docker.backend", "dockerd" -ErrorAction SilentlyContinue)) {
            Write-Cyber "  Docker parado (arranca Docker Desktop)." $c.Dim
        }
        else {
            try {
                $containers = docker ps --format "{{.Names}}|{{.Image}}|{{.Status}}|{{.Ports}}" 2>$null
                if ($containers) {
                    Write-Cyber "  $("NOMBRE".PadRight(22)) $("IMAGEN".PadRight(25)) $("ESTADO".PadRight(20)) PUERTOS" $c.Cyan
                    Write-Cyber "  $("-" * 76)" $c.Dark
                    foreach ($line in $containers) {
                        $parts  = $line -split "\|"
                        Write-Cyber "  $($parts[0].PadRight(22)) " $c.Yellow -NoNewline
                        Write-Cyber "$($parts[1].PadRight(25)) " $c.Cyan -NoNewline
                        Write-Cyber "$($parts[2].PadRight(20)) " $c.Green -NoNewline
                        Write-Cyber "$(if ($parts[3]) { $parts[3] } else { '-' })" $c.Dim
                    }
                } else {
                    Write-Cyber "  Sin contenedores activos." $c.Dim
                }
            } catch {
                Write-Cyber "  No se pudo conectar con el daemon de Docker." $c.Dim
            }
        }
    }

    Write-Host ""
    Write-Cyber $sep $c.Magenta
    Write-Host ""
}

Show-Dashboard

# ================================================================= #
#                          AYUDA Y ATAJOS                           #
# ================================================================= #
function Show-Help {
    $c   = $global:CY
    $bar = "=" * 70

    foreach ($seccion in $global:HelpData.Keys) {
        Write-Host ""
        Write-Cyber $bar $c.Magenta
        Write-Cyber "  $seccion" $c.Green
        Write-Cyber $bar $c.Magenta
        foreach ($item in $global:HelpData[$seccion]) {
            Write-Cyber "  $($item.K.PadRight(28))" $c.Yellow -NoNewline
            Write-Cyber "$($item.D)" $c.Cyan
        }
    }
    Write-Host ""
    Write-Cyber "  Consejo: comprueba cualquier atajo con  Get-PSReadLineKeyHandler" $c.Dim
    Write-Host ""
}

Set-Alias help-ps Show-Help

# ================================================================= #
#                      MEDIR EL ARRANQUE                            #
# ================================================================= #
function Measure-Profile {
    $exe = (Get-Process -Id $PID).Path
    Write-Host "Midiendo (unos segundos)..." -ForegroundColor DarkGray
    $con = [math]::Round((Measure-Command { & $exe -NoLogo -Command exit }).TotalMilliseconds, 0)
    $sin = [math]::Round((Measure-Command { & $exe -NoLogo -NoProfile -Command exit }).TotalMilliseconds, 0)
    Write-Host "Con perfil : $con ms"
    Write-Host "Sin perfil : $sin ms"
    Write-Host "Coste del perfil: $($con - $sin) ms"
}
