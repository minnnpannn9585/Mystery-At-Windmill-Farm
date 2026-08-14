$root = Split-Path $PSScriptRoot -Parent
$names = @('乌鸦','淑芬','小鸡侦探团','悲伤蛙','老鼠兄弟')
foreach ($n in $names) {
    $p = Join-Path $root "docs\characters\$n-对话脚本-树状.md"
    $t = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
    $n2 = [regex]::Replace($t, '```text\r?\n\r?\n', '```text' + "`n")
    if ($n2 -ne $t) {
        [System.IO.File]::WriteAllText($p, $n2, [System.Text.Encoding]::UTF8)
        Write-Host "cleaned $n"
    }
}
