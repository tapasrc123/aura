<#
.SYNOPSIS
    Tests if AI agents are dormant.

.DESCRIPTION
    Checks all published Copilot Studio agents for those that have not been
    modified or republished within 180 days.
    Dormant agents may have outdated configurations, unpatched vulnerabilities,
    or stale permissions that present unnecessary risk.

.OUTPUTS
    [bool] - Returns $true if no dormant agents are found, $false if any
    published agent exceeds the inactivity threshold, $null if data is unavailable.

.EXAMPLE
    Test-AuAIAgentDormant

.LINK
    https://aura.onetapas.com/docs/commands/Test-AuAIAgentDormant
#>

function Test-AuAIAgentDormant {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    $agents = Get-AuAIAgentInfo
    if ($null -eq $agents) {
        Add-AuTestResultDetail -SkippedBecause 'Custom' -SkippedCustomReason 'No Copilot Studio agent data available. Ensure DataverseEnvironmentUrl is configured in aura-config.json and Connect-Aura -Service Dataverse has been run. See https://aura.onetapas.com/docs/tests/MT.1117 for prerequisites.'
        return $null
    }

    Write-Verbose "Checking $($agents.Count) agent(s) for dormant status"

    $thresholdDays = 180
    $threshold = (Get-Date).AddDays(-$thresholdDays)

    $failedAgents = $agents | Where-Object {
        $_.AgentStatus -eq "Published" -and
        $null -ne $_.LastModifiedTime -and
        [datetime]$_.LastModifiedTime -lt $threshold
    }

    if ($failedAgents.Count -eq 0) {
        $testResultMarkdown = "Well done. No dormant AI agents found (threshold: $thresholdDays days)."
    } else {
        $testResultMarkdown = "Found $($failedAgents.Count) AI agent(s) that have not been modified in over $thresholdDays days.`n`n%TestResult%"
        $result = "| Agent Name | Environment | Last Modified | Last Published |`n"
        $result += "| --- | --- | --- | --- |`n"
        foreach ($agent in $failedAgents) {
            $lastModified = if ($agent.LastModifiedTime) { ([datetime]$agent.LastModifiedTime).ToString("yyyy-MM-dd") } else { "Unknown" }
            $lastPublished = if ($agent.LastPublishedTime) { ([datetime]$agent.LastPublishedTime).ToString("yyyy-MM-dd") } else { "Unknown" }
            $result += "| $($agent.AIAgentName) | $($agent.EnvironmentId) | $lastModified | $lastPublished |`n"
        }
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result
    }

    Add-AuTestResultDetail -Result $testResultMarkdown -Severity "Low"
    return $failedAgents.Count -eq 0
}
