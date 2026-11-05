# ================================================================= #
#           my-Heo-Terminal · install.ps1 (private)                 #
#         github.com/HEO-80/my-Heo-Terminal                        #
#                                                                   #
#  ONE-LINER (paste this in PowerShell):                           #
#    irm https://raw.githubusercontent.com/HEO-80/my-Heo-Terminal/main/install.ps1 | iex
#                                                                   #
#  OR clone and run locally:                                        #
#    git clone https://github.com/HEO-80/my-Heo-Terminal           #
#    .\my-Heo-Terminal\install.ps1                                  #
# ================================================================= #

$ErrorActionPreference = "Stop"
$esc = [char]27

function Write-Step  { param($t) Write-Host "${esc}[38;2;252;238;10m  > $t${esc}[0m" }
function Write-OK    { param($t) Write-Host "${esc}[38;2;57;255;20m  OK $t${esc}[0m" }
function Write-Warn  { param($t) Write-Host "${esc}[38;2;198;120;221m  ! $t${esc}[0m" }
function Write-Fail  { param($t) Write-Host "${esc}[38;2;255;48;48m  X $t${esc}[0m" }

Write-Host ""
Write-Host "${esc}[38;2;252;238;10m  ========================================${esc}[0m"
Write-Host "${esc}[38;2;252;238;10m   my-Heo-Terminal  ·  installer          ${esc}[0m"
Write-Host "${esc}[38;2;252;238;10m  ========================================${esc}[0m"
Write-Host ""

# ── 0. Determine install directory ────────────────────────────────
$_root = $PSScriptRoot
$_cloned = $false

if (-not $_root -or -not (Test-Path (Join-Path $_root "themes"))) {
    $_installDir = Join-Path $HOME ".my-Heo-Terminal"

    if (Test-Path $_installDir) {
        Write-Step "Updating existing installation..."
        git -C $_installDir pull --ff-only 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "Could not update. Removing and re-cloning..."
            Remove-Item $_installDir -Recurse -Force
        }
    }

    if (-not (Test-Path $_installDir)) {
        Write-Step "Cloning my-Heo-Terminal..."
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git clone --depth 1 https://github.com/HEO-80/my-Heo-Terminal.git $_installDir
            if ($LASTEXITCODE -ne 0) {
                Write-Fail "git clone failed. Is the repo accessible? Check your SSH keys / token."
                return
            }
        } else {
            Write-Fail "Git is required. Install it: winget install Git.Git"
            return
        }
    }

    $_root = $_installDir
    $_cloned = $true
    Write-OK "Repository ready at $_root"
}

# ── 1. Oh My Posh ────────────────────────────────────────────────
Write-Step "Checking Oh My Posh..."
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Warn "Installing Oh My Posh..."
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements 2>$null
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    Write-OK "Oh My Posh installed"
} else { Write-OK "Oh My Posh OK" }

# ── 2. Nerd Font ─────────────────────────────────────────────────
Write-Step "Checking Nerd Font..."
$_fontInstalled = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\*CaskaydiaCove*" -ErrorAction SilentlyContinue
if (-not $_fontInstalled) {
    $_fontInstalled = Get-ChildItem "C:\Windows\Fonts\*CaskaydiaCove*" -ErrorAction SilentlyContinue
}
if (-not $_fontInstalled) {
    Write-Warn "Installing CaskaydiaCove Nerd Font..."
    try { oh-my-posh font install CascadiaCode 2>$null; Write-OK "Nerd Font installed" }
    catch { Write-Warn "Could not auto-install font. Download from: https://www.nerdfonts.com/font-downloads" }
} else { Write-OK "Nerd Font OK" }

# ── 3. PowerShell modules ────────────────────────────────────────
foreach ($_mod in @("Terminal-Icons", "PSFzf")) {
    Write-Step "Checking module: $_mod..."
    if (-not (Get-Module -ListAvailable -Name $_mod -ErrorAction SilentlyContinue)) {
        Install-Module $_mod -Scope CurrentUser -Force -SkipPublisherCheck
        Write-OK "$_mod installed"
    } else { Write-OK "$_mod OK" }
}

# ── 4. CLI tools ─────────────────────────────────────────────────
foreach ($_tool in @(
    @{ Name = "fzf";    Cmd = "fzf";    Pkg = "junegunn.fzf" },
    @{ Name = "zoxide"; Cmd = "zoxide"; Pkg = "ajeetdsouza.zoxide" }
)) {
    Write-Step "Checking $_($_.Name)..."
    if (-not (Get-Command $_tool.Cmd -ErrorAction SilentlyContinue)) {
        winget install $_tool.Pkg -s winget --accept-package-agreements --accept-source-agreements 2>$null
        Write-OK "$($_tool.Name) installed"
    } else { Write-OK "$($_tool.Name) OK" }
}

# ── 5. Hook into $PROFILE ────────────────────────────────────────
Write-Step "Setting up PowerShell profile..."
$_profileLine = ". `"$_root\Profile.ps1`""

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Warn "Created new profile at: $PROFILE"
}

$_profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($_profileContent -notmatch [regex]::Escape("my-Heo-Terminal")) {
    # Remove old powershell-cyberpunk hook if present
    if ($_profileContent -match "powershell-cyberpunk") {
        $lines = Get-Content $PROFILE
        $lines = $lines | Where-Object { $_ -notmatch "powershell-cyberpunk" }
        $lines | Set-Content $PROFILE
        Write-Warn "Removed old powershell-cyberpunk hook (replaced by my-Heo-Terminal)"
    }
    Add-Content -Path $PROFILE -Value "`n# my-Heo-Terminal`n$_profileLine"
    Write-OK "Profile hooked: $PROFILE"
} else {
    Write-OK "Profile already configured"
}

# ── Done ─────────────────────────────────────────────────────────
Write-Host ""
Write-Host "${esc}[38;2;57;255;20m  ========================================${esc}[0m"
Write-Host "${esc}[38;2;57;255;20m   Installation complete!                 ${esc}[0m"
Write-Host "${esc}[38;2;57;255;20m  ========================================${esc}[0m"
Write-Host ""
Write-Host "  Restart PowerShell or run: ${esc}[38;2;252;238;10m. `$PROFILE${esc}[0m"
Write-Host ""
Write-Host "  ${esc}[38;2;136;136;136mSet your terminal font to 'CaskaydiaCove Nerd Font'${esc}[0m"
Write-Host "  ${esc}[38;2;136;136;136mWindows Terminal: Settings > Profiles > Defaults > Font Face${esc}[0m"
Write-Host ""
