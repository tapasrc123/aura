function Test-AuAdDcAllFsmoRolesCount {
    <#
    .SYNOPSIS
    Counts domain controllers that hold all 5 FSMO roles.

    .DESCRIPTION
    This test identifies domain controllers that hold all 5 FSMO (Flexible Single Master Operations)
    roles. While not inherently a security issue, concentrating all FSMO roles on a single DC
    creates a single point of failure and may indicate a lack of proper AD design.

    .EXAMPLE
    Test-AuAdDcAllFsmoRolesCount

    Returns $true if FSMO role data is accessible.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuAdDcAllFsmoRolesCount
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Write-Verbose "Starting Test-AuAdDcAllFsmoRolesCount"

    # Get AD domain state data (uses cached data if available)
    $adState = Get-AuADDomainState

    # If unable to retrieve AD data, skip the test
    if ($null -eq $adState) {
        Add-AuTestResultDetail -SkippedBecause NotConnectedActiveDirectory
        return $null
    }

    $domain = $adState.Domain
    $forest = $adState.Forest
    $dcCount = ($adState.DomainControllers | Measure-Object).Count

    # Get all FSMO role holders
    $fsmoRoles = @{
        'Schema Master' = $forest.SchemaMaster
        'Domain Naming Master' = $forest.DomainNamingMaster
        'PDC Emulator' = $domain.PDCEmulator
        'RID Master' = $domain.RIDMaster
        'Infrastructure Master' = $domain.InfrastructureMaster
    }

    # Count how many unique DCs hold FSMO roles
    $uniqueFsmoHolders = $fsmoRoles.Values | Select-Object -Unique
    $uniqueFsmoCount = ($uniqueFsmoHolders | Measure-Object).Count

    # Find DCs holding all 5 roles
    $allRolesHolders = $uniqueFsmoHolders | Where-Object {
        $dc = $_
        ($fsmoRoles.Values | Where-Object { $_ -eq $dc } | Measure-Object).Count -eq 5
    }
    $allRolesCount = ($allRolesHolders | Measure-Object).Count

    # Test passes if we successfully retrieved FSMO data
    $testResult = $dcCount -gt 0

    # Generate markdown results
    $result = "| Metric | Value |" + "`n"
    $result += "| --- | --- |" + "`n"
    $result += "| Total Domain Controllers | $dcCount |" + "`n"
    $result += "| Unique FSMO Role Holders | $uniqueFsmoCount |" + "`n"
    $result += "| DCs with All 5 FSMO Roles | $allRolesCount |" + "`n" + "`n"

    $result += "| FSMO Role | Current Holder |" + "`n"
    $result += "| --- | --- |" + "`n"
    foreach ($role in $fsmoRoles.Keys) {
        $result += "| $role | $($fsmoRoles[$role]) |" + "`n"
    }

    if ($allRolesCount -gt 0) {
        $testResultMarkdown = "⚠️ **Design Notice**: $allRolesCount domain controller(s) hold all 5 FSMO roles. Consider distributing roles for redundancy.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "✅ **Good Distribution**: FSMO roles are distributed across $uniqueFsmoCount domain controller(s).`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $result

    Add-AuTestResultDetail -Result $testResultMarkdown

    return $testResult
}
