# ================================================================= #
#                       POWERSHELL PROFILE                          #
#                    my-Heo-Terminal (private)                       #
# ================================================================= #
# IMPORTANTE: guardar como UTF-8 con BOM (o usar PowerShell 7).

# GUARD: evita doble carga si el perfil se dot-sourcea mas de una vez
if ($global:ProfileLoaded) { return }
$global:ProfileLoaded = $true

# Consola en UTF-8 (iconos, tildes, bloques del ASCII art)
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $OutputEncoding           = [System.Text.Encoding]::UTF8
} catch {}

# Mostrar el banner ASCII al arrancar ($false para desactivarlo)
$global:ShowBanner = $true

# Carpeta donde vive este perfil (y los temas)
$global:ProfileDir = Split-Path $PROFILE

# ================================================================= #
#                           ASCII ART                               #
# ================================================================= #

function Show-AsciiArt {
    $asciiArt = @"
 ██╗  ██╗███████╗ ██████╗      ██████╗ ███████╗██╗   ██╗
 ██║  ██║██╔════╝██╔═══██╗     ██╔══██╗██╔════╝██║   ██║
 ███████║█████╗  ██║   ██║     ██║  ██║█████╗  ██║   ██║
 ██╔══██║██╔══╝  ██║   ██║     ██║  ██║██╔══╝  ╚██╗ ██╔╝
 ██║  ██║███████╗╚██████╔╝     ██████╔╝███████╗ ╚████╔╝
 ╚═╝  ╚═╝╚══════╝ ╚═════╝      ╚═════╝ ╚══════╝  ╚═══╝

      > Mi Terminal CyberPowerShell Personalizada <
"@
    Write-Host $asciiArt -ForegroundColor Magenta
    Write-Host ""
}

# ================================================================= #
#                   LOGICA DE CARGA DE TEMAS                        #
# ================================================================= #

$_root = $PSScriptRoot

$global:Themes = @{
    "Cyberpunk2077" = Join-Path $_root "themes\Cyberpunk2077.ps1"
}

$DefaultTheme = "Cyberpunk2077"
if ($env:TemaActivo -and $global:Themes.ContainsKey($env:TemaActivo)) {
    $DefaultTheme = $env:TemaActivo
}
$ThemeFile = $global:Themes[$DefaultTheme]

function Set-Theme {
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({ $global:Themes.Keys | Sort-Object })]
        [ValidateScript({ $global:Themes.ContainsKey($_) })]
        [string]$Name
    )
    $file = $global:Themes[$Name]
    if (-not (Test-Path $file)) {
        Write-Host "Error: no se encontro el tema '$Name' en: $file" -ForegroundColor Red
        return
    }
    Write-Host "Cambiando a tema: $Name" -ForegroundColor Green
    . $file
}

if ($DefaultTheme -ne "Cyberpunk2077" -and $global:ShowBanner) {
    Show-AsciiArt
}

if (Test-Path $ThemeFile) {
    . $ThemeFile
} else {
    Write-Host "Error: No se encontro el tema '$DefaultTheme' en: $ThemeFile" -ForegroundColor Red
    if ($global:ShowBanner) { Show-AsciiArt }
}

# ================================================================= #
#                   CONEXION INTELIGENTE SSH                        #
# ================================================================= #
function Ir-SSH {
    param([string]$HostAlias = "beelink")

    if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
        Write-Host "No encuentro 'ssh'. Instala el cliente OpenSSH de Windows." -ForegroundColor Red
        return
    }

    $cfg      = @(ssh -G $HostAlias 2>$null)
    $hostName = ($cfg | Where-Object { $_ -like "hostname *" } | Select-Object -First 1) -replace "^hostname ", ""
    $portTxt  = ($cfg | Where-Object { $_ -like "port *" }     | Select-Object -First 1) -replace "^port ", ""
    $port     = 22
    if ($portTxt -match "^\d+$") { $port = [int]$portTxt }

    if (-not $hostName) {
        Write-Host "No pude leer la configuracion SSH de '$HostAlias'." -ForegroundColor Red
        return
    }

    Write-Host "Buscando senal de ${HostAlias} (${hostName}:${port})..." -NoNewline -ForegroundColor Yellow

    $online = $false
    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $online = $client.ConnectAsync($hostName, $port).Wait(1500) -and $client.Connected
    } catch {
        $online = $false
    } finally {
        $client.Dispose()
    }

    if ($online) {
        Write-Host " [ONLINE]" -ForegroundColor Green
        Write-Host "Conectando..." -ForegroundColor Cyan
        ssh $HostAlias
    } else {
        Write-Host " [OFFLINE]" -ForegroundColor Red
        Write-Host "El puerto SSH no responde. Esta encendido el servidor?" -ForegroundColor DarkGray
    }
}

# ================================================================= #
#                       CYBERLAB SHORTCUTS                          #
# ================================================================= #
function Ir-CyberLab    { Ir-SSH -HostAlias "cyberlab" }
function Ir-Kali        { Ir-SSH -HostAlias "kali" }
function Ir-KaliRemote  { Ir-SSH -HostAlias "kali-remote" }
function Open-Proxmox      { Start-Process "https://100.74.146.107:8006" }
function Open-ProxmoxLocal { Start-Process "https://192.168.1.141:8006" }

Set-Alias bee      Ir-SSH
Set-Alias lab      Ir-CyberLab
Set-Alias kali     Ir-Kali
Set-Alias kalir    Ir-KaliRemote
Set-Alias proxmox  Open-Proxmox
Set-Alias proxlocal Open-ProxmoxLocal

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

# ================================================================= #
#                      COMMAND LOGGER                               #
# ================================================================= #
$CommandLoggerFile = Join-Path $_root "command-logger-powershell.ps1"
if (Test-Path $CommandLoggerFile) {
    . $CommandLoggerFile
}
