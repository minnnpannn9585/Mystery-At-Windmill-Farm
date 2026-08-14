# Fix tree dialogue format - branches at nodes not per line
$root = Split-Path $PSScriptRoot -Parent

$files = @(
    'docs\characters\乌鸦-对话脚本-树状.md',
    'docs\characters\淑芬-对话脚本-树状.md',
    'docs\characters\小鸡侦探团-对话脚本-树状.md',
    'docs\characters\悲伤蛙-对话脚本-树状.md',
    'docs\characters\老鼠兄弟-对话脚本-树状.md'
)

$structMarkers = @('【回访】', '【菜单】', '【轮播】', '【条件】')

function Is-TopLevelBranch($line) {
    return $line -match '^[├└]─'
}

function Is-IndentedBranch($line) {
    return $line -match '^\s+[├└]─'
}

function Is-Structural($line) {
    if (-not (Is-TopLevelBranch $line)) { return $false }
    $content = $line.Substring(2).Trim()
    foreach ($m in $structMarkers) {
        if ($content.StartsWith($m)) { return $true }
    }
    return $false
}

function Is-NodeHeader($line) {
    $s = $line.Trim()
    if ($s -eq '│' -or $s -eq '') { return $false }
    if ($s.StartsWith('→') -or $s.StartsWith('【变量】')) { return $false }
    if ($s.StartsWith('· ')) { return $false }
    if (Is-TopLevelBranch $line) { return $false }
    return $true
}

function Strip-Branch($line) {
    return ($line.Trim() -replace '^[├└]─\s*', '')
}

function Fix-TextBlock($blockLines) {
    $out = @()
    $i = 0
    while ($i -lt $blockLines.Count) {
        $line = $blockLines[$i]
        $stripped = $line.Trim()

        if ($stripped.StartsWith('→') -or $stripped.StartsWith('【变量】') -or $stripped.StartsWith('· ')) {
            $out += $line
            $i++
            continue
        }

        if (Is-NodeHeader $line) {
            $out += $line
            $i++
            continue
        }

        if (-not (Is-TopLevelBranch $line)) {
            $out += $line
            $i++
            continue
        }

        if (Is-Structural $line) {
            $out += $line
            $i++
            while ($i -lt $blockLines.Count) {
                $l = $blockLines[$i]
                if (Is-TopLevelBranch $l) { break }
                $out += $l
                $i++
            }
            continue
        }

        $collected = @()
        while ($i -lt $blockLines.Count) {
            $l = $blockLines[$i]
            $st = $l.Trim()
            if ($st.StartsWith('→') -or $st.StartsWith('【变量】') -or $st.StartsWith('· ')) { break }
            if (Is-NodeHeader $l) { break }
            if (Is-TopLevelBranch $l) {
                if (Is-Structural $l) { break }
                $collected += (Strip-Branch $l)
                $i++
            } else { break }
        }

        if ($collected.Count -gt 0) {
            $out += ('└─ ' + $collected[0])
            for ($j = 1; $j -lt $collected.Count; $j++) {
                $out += ('   ' + $collected[$j])
            }
        } else {
            $out += $line
            $i++
        }
    }
    return $out
}

foreach ($f in $files) {
    $path = Join-Path $root $f
    $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $changed = $false
    $sb = New-Object System.Text.StringBuilder
    $pos = 0
    while ($true) {
        $start = $text.IndexOf('```text', $pos)
        if ($start -lt 0) {
            $sb.Append($text.Substring($pos))
            break
        }
        $sb.Append($text.Substring($pos, $start - $pos))
        $contentStart = $start + 7
        if ($contentStart -lt $text.Length -and $text[$contentStart] -eq "`n") { $contentStart++ }
        if ($contentStart -lt $text.Length -and $text[$contentStart] -eq "`r") { $contentStart++ }
        $end = $text.IndexOf('```', $contentStart)
        if ($end -lt 0) {
            $sb.Append($text.Substring($start))
            break
        }
        $blockLines = ($text.Substring($contentStart, $end - $contentStart) -split "`r?`n")
        $fixed = Fix-TextBlock $blockLines
        if (($fixed -join "`n") -ne ($blockLines -join "`n")) { $changed = $true }
        $sb.Append('```text')
        $sb.Append("`n")
        $sb.Append(($fixed -join "`n"))
        $sb.Append('```')
        $pos = $end + 3
    }
    if ($changed) {
        [System.IO.File]::WriteAllText($path, $sb.ToString(), [System.Text.Encoding]::UTF8)
        Write-Host "FIXED $f"
    } else {
        Write-Host "UNCHANGED $f"
    }
}
