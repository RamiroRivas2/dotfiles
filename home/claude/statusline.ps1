# Claude Code status line: "<model> | ctx: N% used"
# PowerShell translation of the bash+jq one-liner in kunchen's .claude/settings.json.
$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$model = $data.model.display_name
$used = $data.context_window.used_percentage
if ($null -ne $used -and "$used" -ne '') {
    '{0} | ctx: {1:0}% used' -f $model, [double]$used
} else {
    "$model"
}
