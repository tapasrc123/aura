function Test-AuCaAgentRiskBlockPolicy {
    <#
    .Synopsis
    Checks if the tenant has at least one Conditional Access policy that blocks agent identities based on their risk level.

    .Description
    Organizations should block agent identities that are detected as high risk by Microsoft Entra ID Protection to helping prevent potentially compromised AI agents from accessing your organization's resources.

    Learn more:
    https://learn.microsoft.com/entra/identity/conditional-access/policy-agent-block-high-risk

    .Example
    Test-AuCaAgentRiskBlockPolicy

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuCaAgentRiskBlockPolicy
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    try {
        $policies =  Get-AuConditionalAccessPolicy | Where-Object { $_.state -eq 'enabled'}

        $policiesResult = New-Object System.Collections.ArrayList
        $result = $false

        foreach ($policy in $policies) {
            if ($policy.conditions.agentIdRiskLevels -match 'high' -and $policy.grantControls.builtInControls -match 'block'){
                $result = $true
                $policiesResult.Add($policy) | Out-Null
            } else {
                $CurrentResult = $false
            }
            Write-Verbose "$($policy.displayName) - $CurrentResult"
        }

        if ( $result ) {
            $testResult = "Well done! The following Conditional Access policies sufficiently block high-risk agent identities:`n`n%TestResult%"
        } else {
            $testResult = 'No Conditional Access policy found that targets high risk agent identities.'
        }

        Add-AuTestResultDetail -Result $testResult -GraphObjects $policiesResult -GraphObjectType ConditionalAccess
        return $result
    } catch {
        Add-AuTestResultDetail -SkippedBecause Error -SkippedError $_
        return $null
    }
}
