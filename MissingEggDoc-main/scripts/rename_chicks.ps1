$files = @(
    'docs\characters\小鸡侦探团-对话脚本-树状.md',
    'docs\characters\小鸡侦探团-对话脚本.md',
    'docs\characters\小鸡侦探团.md',
    'docs\11-美术方向.md',
    'docs\14-待解决笔记.md'
)
$root = Split-Path $PSScriptRoot -Parent

$map = [ordered]@{
    '跟班A' = '米粒'
    '跟班B' = '豆豆'
    '跟班C' = '瓜子'
    '跟班 A' = '米粒'
    '跟班 B' = '豆豆'
    '跟班 C' = '瓜子'
    '领头' = '阿满'
}

$extras = [ordered]@{
    '阿满：（压声）C！别说了！' = '阿满：（压声）瓜子！别说了！'
    '阿满："（压声）C！别说了！"' = '阿满："（压声）瓜子！别说了！"'
    '阿满：C！' = '阿满：瓜子！'
    '阿满："C！"' = '阿满："瓜子！"'
    '阿满：（急）C——！' = '阿满：（急）瓜子——！'
    '阿满："（急）C——！"' = '阿满："（急）瓜子——！"'
    '阿满：（压声）B！！' = '阿满：（压声）豆豆！！'
    '阿满："（压声）B！！"' = '阿满："（压声）豆豆！！"'
    'C 差点漏嘴' = '瓜子差点漏嘴'
    '阿满和跟班对视' = '阿满和米粒、豆豆、瓜子对视'
    '描述：阿满和跟班对视' = '描述：阿满和米粒、豆豆、瓜子对视'
    '跟班A、B、C一起点头' = '米粒、豆豆、瓜子一起点头'
    '跟班 A、B 接茬' = '米粒、豆豆接茬'
    '跟班补刀' = '豆豆补刀'
    '阿满带三只跟班' = '阿满带米粒、豆豆、瓜子'
    '领头带三只跟班' = '阿满带米粒、豆豆、瓜子'
    '阿满扯 C 一把' = '阿满扯瓜子一把'
    '领头扯 C 一把' = '阿满扯瓜子一把'
    'A 向左转、B 向右躲、C 低头' = '米粒向左转、豆豆向右躲、瓜子低头'
    'A 低头不看、B 嘴撅气鼓、C 嘴抿紧' = '米粒低头不看、豆豆嘴撅气鼓、瓜子嘴抿紧'
    '跟班用墨镜' = '米粒、豆豆、瓜子用墨镜'
}

foreach ($rel in $files) {
    $path = Join-Path $root $rel
    if (-not (Test-Path $path)) { continue }
    $t = [IO.File]::ReadAllText($path, [Text.UTF8Encoding]::new($false))
    $orig = $t
    foreach ($k in $map.Keys) { $t = $t.Replace($k, $map[$k]) }
    foreach ($k in $extras.Keys) { $t = $t.Replace($k, $extras[$k]) }
    if ($t -ne $orig) {
        [IO.File]::WriteAllText($path, $t, [Text.UTF8Encoding]::new($false))
        Write-Host "updated $rel"
    }
}
