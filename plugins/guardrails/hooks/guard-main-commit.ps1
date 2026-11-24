# PreToolUse guard: block direct commits/pushes to the protected `main` branch.
# Reads the hook payload from stdin, and if the terminal command is a git commit
# while HEAD is on `main`, or a git push targeting `main`, returns an "ask"
# permission decision so the operation requires explicit confirmation.

$ErrorActionPreference = 'SilentlyContinue'

$raw = [Console]::In.ReadToEnd()
$cmd = ''
if ($raw) {
    try {
        $json = $raw | ConvertFrom-Json
        foreach ($candidate in @(
                $json.tool_input.command,
                $json.toolInput.command,
                $json.input.command,
                $json.command)) {
            if ($candidate) { $cmd = "$cmd $candidate" }
        }
    } catch { }
}
$cmd = $cmd.ToLower()

function Request-Confirmation([string]$reason) {
    $payload = @{
        hookSpecificOutput = @{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'ask'
            permissionDecisionReason = $reason
        }
    } | ConvertTo-Json -Compress
    Write-Output $payload
    exit 0
}

# Only inspect git commands.
if ($cmd -notmatch 'git') { exit 0 }

if ($cmd -match 'git\s+commit') {
    $branch = (& git rev-parse --abbrev-ref HEAD 2>$null)
    if ($branch -eq 'main') {
        Request-Confirmation 'Blocked: committing directly on main. main is protected - create a feature branch (feat/ fix/ docs/ chore/) first.'
    }
}

if ($cmd -match 'git\s+push' -and $cmd -match '(^|[\s:])main($|[\s:])') {
        Request-Confirmation 'Blocked: pushing to main. main is protected - push a feature branch and open a PR instead.'
}

exit 0
