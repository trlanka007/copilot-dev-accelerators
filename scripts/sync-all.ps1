# Rebuilds plugins/all from the area plugins (the source of truth).
$ErrorActionPreference = 'Stop'
$plugins = Join-Path (Split-Path $PSScriptRoot -Parent) 'plugins'
$all = Join-Path $plugins 'all'
foreach ($d in 'skills', 'agents', 'hooks') {
    $p = Join-Path $all $d
    if (Test-Path $p) { Remove-Item $p -Recurse -Force }
    New-Item -ItemType Directory $p | Out-Null
}
foreach ($area in 'pr-workflow', 'spec-driven-infra', 'guardrails') {
    foreach ($d in 'skills', 'agents', 'hooks') {
        $src = Join-Path $plugins "$area\$d"
        if (Test-Path $src) { Copy-Item "$src\*" (Join-Path $all $d) -Recurse -Force }
    }
}
Copy-Item (Join-Path $plugins 'guardrails\hooks.json') (Join-Path $all 'hooks.json') -Force
Write-Host 'plugins/all synced'
