# Validate dialogue tree scripts against docs/17-全局游戏状态变量.md
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate_dialogue_vars.ps1
# Exit: 1 if any ERROR, else 0

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$VarDoc = Join-Path $Root 'docs\17-全局游戏状态变量.md'
$TreePattern = Join-Path $Root 'docs\characters\*-树状*.md'

$Shorthand = @{
    'E07'              = 'E07_ViewNapSpot'
    'E08'              = 'E08_ViewBurnMark'
    'E10'              = 'E10_ViewWhiteStone'
    'E13'              = 'E13_ViewDoorBlocked'
    'E17'              = 'E17_ViewEmptyBucket'
    'E18'              = 'E18_ViewBootprints'
    'Started'          = 'BlackCat_CaseLineStarted'
    'Done'             = 'BlackCat_CaseLineDone'
    'StoneRevealShown' = 'BlackCat_StoneRevealShown'
    'CaseLineDone'     = 'BlackCat_CaseLineDone'
    'MintFishLineDone' = 'BlackCat_MintFishLineDone'
    'MintFishPending'  = 'BlackCat_MintFishPending'
}

$AlwaysOk = @(
    'NGPlus', 'Comic_Revealed', 'CheeseCount', 'ChickTraceCount',
    'TreeClueCount', 'DogStatus', 'ChickStatus'
)

# E 点代号（13 氛围/环境点，非 bool 变量）— 出现在说明性括号里时不报错
$EPointRefs = @(
    'E04','E06','E20','E30','E31','E32','E33','E34','E35','E36','E37','E38','E39'
)

$VarPrefixes = @(
    'E', 'Dog_', 'BlackCat_', 'Chick_', 'Shufen_', 'Crow_',
    'Frog_', 'Mouse_', 'RedRoof_', 'MintFish_', 'Flash_', 'Comic_'
)

function Test-VarPrefix {
    param([string]$Name)
    foreach ($p in $VarPrefixes) {
        if ($Name.StartsWith($p)) { return $true }
    }
    return $false
}

function Resolve-Token {
    param([string]$Raw)
    $tok = $Raw.Trim()
    if ([string]::IsNullOrWhiteSpace($tok)) { return $null }
    if ($tok -match '^\d+$') { return $null }
    if ($tok -eq 'E') { return $null }
    if ($EPointRefs -contains $tok) { return $null }
    if ($Shorthand.ContainsKey($tok)) { $tok = $Shorthand[$tok] }
    if ($AlwaysOk -contains $tok) { return $tok }
    if ($tok -match '^E\d{2}$' -and $Shorthand.ContainsKey($tok)) {
        return $Shorthand[$tok]
    }
    if (Test-VarPrefix $tok) { return $tok }
    return $null
}

function Get-TokensInCondition {
    param([string]$Cond)
    $found = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($m in [regex]::Matches($Cond, '`([A-Za-z][A-Za-z0-9_]*)`')) {
        $v = Resolve-Token $m.Groups[1].Value
        if ($v) { [void]$found.Add($v) }
    }
    foreach ($m in [regex]::Matches($Cond, '\b(E\d{2}_[A-Za-z0-9_]+)\b')) {
        $v = Resolve-Token $m.Groups[1].Value
        if ($v) { [void]$found.Add($v) }
    }
    foreach ($m in [regex]::Matches($Cond, '!?([A-Za-z][A-Za-z0-9_]*)')) {
        $v = Resolve-Token $m.Groups[1].Value
        if ($v) { [void]$found.Add($v) }
    }
    return $found
}

function Get-ConditionsFromLine {
    param([string]$Line)
    $conds = [System.Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($Line, '（([^）]+)）\s*→')) {
        $c = $m.Groups[1].Value.Trim()
        if ($c -notmatch '\*\*') { [void]$conds.Add($c) }
    }
    if ($Line -match '→.+（([^）]+)）\s*$') {
        $c = $Matches[1].Trim()
        if ($c -notmatch '\*\*') { [void]$conds.Add($c) }
    }
    return $conds
}

function Load-RegisteredVars {
    param([string]$Path)
    $text = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $registered = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($a in $AlwaysOk) { [void]$registered.Add($a) }
    foreach ($m in [regex]::Matches($text, '`([A-Za-z][A-Za-z0-9_]*)`')) {
        $name = $m.Groups[1].Value
        if ((Test-VarPrefix $name) -or ($AlwaysOk -contains $name)) {
            [void]$registered.Add($name)
        }
    }
    return $registered
}

function Scan-TreeFile {
    param(
        [string]$Path,
        [System.Collections.Generic.HashSet[string]]$Registered
    )
    $text = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $lines = $text -split "`r?`n"
    $hasHubRule = $text -match 'hub\s*子树'
    $errors = [System.Collections.Generic.List[object]]::new()
    $warnings = [System.Collections.Generic.List[object]]::new()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNo = $i + 1
        $stripped = $lines[$i].Trim()

        foreach ($cond in (Get-ConditionsFromLine $stripped)) {
            foreach ($var in (Get-TokensInCondition $cond)) {
                if (-not $Registered.Contains($var)) {
                    $errors.Add([pscustomobject]@{
                        Line = $lineNo
                        Message = "未登记变量 ``$var`` in （$cond）"
                    })
                }
            }
        }

        if ($hasHubRule -and $stripped.StartsWith('→') -and ($stripped -match 'hub')) {
            if ($stripped -match 'BlackCat_Entered|!BlackCat_Entered') {
                $warnings.Add([pscustomobject]@{
                    Line = $lineNo
                    Message = '返链含 BlackCat_Entered（hub 子树铁则建议省略）'
                })
            }
            # 跨 hub 例外（如 1-F 仅 DogStatus==4）不警告；复合条件才警告
            if ($stripped -match 'DogStatus\s*==\s*4' -and $stripped -match 'Dog_BlackCatSummoned|BlackCat_Entered|RedRoof_') {
                $warnings.Add([pscustomobject]@{
                    Line = $lineNo
                    Message = '返链含 DogStatus==4 复合条件（hub 子树铁则建议省略）'
                })
            }
        }
    }

    return $errors, $warnings
}

if (-not (Test-Path -LiteralPath $VarDoc)) {
    Write-Error "missing $VarDoc"
    exit 1
}

$registered = Load-RegisteredVars $VarDoc
Write-Host "Registered variables: $($registered.Count)"

$allErrors = [System.Collections.Generic.List[object]]::new()
$allWarnings = [System.Collections.Generic.List[object]]::new()

Get-ChildItem -Path $TreePattern -File | Sort-Object FullName | ForEach-Object {
    $rel = $_.FullName.Substring($Root.Length + 1) -replace '\\', '/'
    $errs, $warns = Scan-TreeFile $_.FullName $registered
    foreach ($e in $errs) {
        $allErrors.Add([pscustomobject]@{ File = $rel; Line = $e.Line; Message = $e.Message })
    }
    foreach ($w in $warns) {
        $allWarnings.Add([pscustomobject]@{ File = $rel; Line = $w.Line; Message = $w.Message })
    }
}

if ($allWarnings.Count -gt 0) {
    Write-Host ''
    Write-Host '--- WARNINGS ---'
    foreach ($w in $allWarnings) {
        Write-Host "  $($w.File):$($w.Line): $($w.Message)"
    }
}

if ($allErrors.Count -gt 0) {
    Write-Host ''
    Write-Host '--- ERRORS ---'
    foreach ($e in $allErrors) {
        Write-Host "  $($e.File):$($e.Line): $($e.Message)"
    }
    Write-Host ''
    Write-Host "$($allErrors.Count) error(s)"
    exit 1
}

Write-Host ''
Write-Host 'OK: no unregistered variable errors.'
if ($allWarnings.Count -gt 0) {
    Write-Host "$($allWarnings.Count) warning(s)"
}
exit 0
