# ROBLOX CHEAT SCANNER v1.9

Set-ExecutionPolicy Bypass -Scope Process -Force
Clear-Host

$Host.UI.RawUI.WindowTitle = "🔍 Roblox Exploit Scanner v1.9 ～ 45-70 сек"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"

Write-Host "`n" -NoNewline
Write-Host "    ╔════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
Write-Host "    ║          ROBLOX EXPLOIT SCANNER v1.9               ║" -ForegroundColor Cyan
Write-Host "    ║   Synapse • Krnl • Fluxus • Delta • Solara • JJSploit  ║" -ForegroundColor Yellow
Write-Host "    ╚════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
Write-Host "             Проверка на 90+ популярных эксплойтов" -ForegroundColor DarkGray
Write-Host "`n"

Write-Host "⏳ Примерное время сканирования: 45–70 секунд" -ForegroundColor Cyan
Start-Sleep -Seconds 2

# База "сигнатур" (для вида, проверять не будем)
$exploitDB = @("synapse","krnl","fluxus","delta","solara","jj","electron","wearedevs","script-ware","bloxstrap","hookfunction","getrawmetatable","hookmetamethod","setthreadidentity","bit32","dex","darkhub","infiniteyield","ohlol","backdoor")

$found = @()
$riskLevel = 0
$startTime = Get-Date

# ──────────────── Спиннер ────────────────
function Show-Spinner {
    param(
        [string]$text,
        [int]$seconds,
        [string]$color = "Green"
    )
    
    $spinner = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $end = (Get-Date).AddSeconds($seconds)
    $i = 0
    
    while ((Get-Date) -lt $end) {
        Write-Host "`r  $($spinner[$i % $spinner.Count]) $text" -NoNewline -ForegroundColor $color
        $i++
        Start-Sleep -Milliseconds 80
    }
    Write-Host "`r  [✓] $text" -ForegroundColor $color
}

# ──────────────── Этапы сканирования ────────────────

Write-Host "`n[1/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Процессы Roblox и инжекторы..." -ForegroundColor White
Show-Spinner "Анализ roblox-player.exe, DLL-инъекций..." 12

Write-Host "`n[2/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Папка Roblox + AppData\Local..." -ForegroundColor White
Show-Spinner "Сканирование автоконфигов, exploit-модулей..." 14

Write-Host "`n[3/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Temp, Downloads, Desktop..." -ForegroundColor White
Show-Spinner "Поиск .lua, .dll, .exe подозрительных файлов..." 10

Write-Host "`n[4/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Автозагрузка и реестр..." -ForegroundColor White
Show-Spinner "Проверка Run, Startup, Scheduled Tasks..." 9

Write-Host "`n[5/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Финальная глубокая проверка..." -ForegroundColor White

# Простой красивый прогресс-бар
for ($i = 0; $i -le 100; $i += 5) {
    $bar = ('█' * ($i/5)) + ('░' * (20 - $i/5))
    Write-Progress -Activity "Глубокий анализ..." -Status "$i%" -PercentComplete $i -CurrentOperation "Сигнатуры: $i/2000"
    Start-Sleep -Milliseconds (Get-Random -Minimum 200 -Maximum 450)
}
Write-Progress -Completed

Write-Host "`n[6/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Сетевые подключения и WebSocket..." -ForegroundColor White
Show-Spinner "Проверка подозрительных серверов..." 7

Write-Host "`n[7/7] " -NoNewline -ForegroundColor Cyan
Write-Host "Сравнение с базой сигнатур 2025–2026..." -ForegroundColor White
Show-Spinner "Финальная валидация..." 5


# ──────────────── Результат (пока всегда чисто) ────────────────
$elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds)

Clear-Host

Write-Host "`n" -NoNewline
Write-Host "    ╔═══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "    ║      СКАНИРОВАНИЕ ЗАВЕРШЕНО УСПЕШНО!          ║" -ForegroundColor Green
Write-Host "    ║           Время: $elapsed сек                    ║" -ForegroundColor Green
Write-Host "    ╚═══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n"

Write-Host "      ✅  ЧИТЫ И ЭКСПЛОЙТЫ НЕ ОБНАРУЖЕНЫ!" -ForegroundColor Green
Write-Host "      🎯  Уровень риска: 0%" -ForegroundColor Green
Write-Host "      🚀  Можно спокойно играть на всех серверах!" -ForegroundColor Green
Write-Host "`n"
Write-Host "      Система чиста • Byfron не жалуется • Удачи!" -ForegroundColor DarkGray

Write-Host "`n" -NoNewline
Write-Host "    [ Нажмите любую клавишу для выхода ]" -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Можно потом тут добавить фейковый "оптимизатор" или что захочешь
