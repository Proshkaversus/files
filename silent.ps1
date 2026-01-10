# Запуск от имени администратора проверяется автоматически
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Необходимо запустить скрипт от имени администратора."
    Exit
}

Write-Host "Отключение UAC..." -ForegroundColor Yellow
try {
    # Значение 0 отключает UAC. Без перезагрузки изменения могут не полностью вступить в силу.
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 -Type DWord
    Write-Host "UAC отключен. Для полного применения изменений обычно требуется перезагрузка." -ForegroundColor Green
} catch {
    Write-Error "Ошибка при отключении UAC: $_"
}

Write-Host "`nОтключение Windows Defender..." -ForegroundColor Yellow
try {
    # Отключение через реестр (DisableAntiSpyware)
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "DisableAntiSpyware" -Value 1 -Type DWord
    Write-Host "Windows Defender отключен (через реестр)." -ForegroundColor Green

    # Попытка остановки и отключения служб Defender (чтобы сработало без перезагрузки)
    Write-Host "Остановка служб Defender..." -ForegroundColor Gray
    Stop-Service -Name "WinDefend" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "WinDefend" -StartupType Disabled -ErrorAction SilentlyContinue
    
    # На современных версиях Windows 10/11 также используются эти службы
    Stop-Service -Name "SecurityHealthService" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "SecurityHealthService" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "Службы остановлены и отключены." -ForegroundColor Green

} catch {
    Write-Error "Ошибка при отключении Defender: $_"
}

Write-Host "`nГотово." -ForegroundColor Cyan
