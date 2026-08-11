function Get-AuHtmlReport {
    <#
    .Synopsis
    Generates a formatted html report using the AuraResults object created by ConvertTo-AuraResult

    .Description
    The generated html is a single file that provides a visual representation of the test
    results with a summary view and click through of the details.

    Supports both single-tenant results (from ConvertTo-AuraResult) and multi-tenant
    results (from Merge-AuraResult).

    .Example
    $pesterResults = Invoke-Pester -PassThru
    $auraResults = ConvertTo-AuraResult $pesterResults
    $output = Get-AuHtmlReport -AuraResults $auraResults
    $output | Out-File -FilePath $out.OutputHtmlFile -Encoding UTF8

    This example shows how to generate the html report and save it to a file by using Invoke-Pester

    .Example
    $auraResults = Invoke-Aura -PassThru
    $output = Get-AuHtmlReport -AuraResults $auraResults
    $output | Out-File -FilePath $out.OutputHtmlFile -Encoding UTF8

    This example shows how to generate the html report and save it to a file by using Invoke-Aura

    .Example
    $result1 = Invoke-Aura -PassThru
    $result2 = Invoke-Aura -PassThru
    $merged = Merge-AuraResult -AuraResults @($result1, $result2)
    $output = Get-AuHtmlReport -AuraResults $merged
    $output | Out-File -FilePath "MultiTenantReport.html" -Encoding UTF8

    This example shows how to generate a multi-tenant html report

    .LINK
    https://aura.onetapas.com/docs/commands/Get-AuHtmlReport
    #>
    [CmdletBinding()]
    param(
        # The Aura test results returned from `Invoke-Pester -PassThru | ConvertTo-AuraResult`
        # or from `Merge-AuraResult` for multi-tenant reports.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [psobject] $AuraResults
    )

    process {
        # Use depth 7 for multi-tenant to handle: Tenants > Tests > ErrorRecord > nested objects
        $isMultiTenant = $AuraResults.PSObject.Properties.Name -contains 'Tenants'
        $depth = if ($isMultiTenant) { 7 } else { 5 }

        Write-Verbose "Generating HTML report."
        $json = $AuraResults | ConvertTo-Json -Depth $depth -Compress -WarningAction Ignore

        $htmlFilePath = Join-Path -Path $PSScriptRoot -ChildPath '../../assets/ReportTemplate.html'
        $templateHtml = Get-Content -Path $htmlFilePath -Raw

        # Insert the test results json into the template.
        # Locate the EndOfJson sentinel (handles both double-quote and backtick strings
        # produced by different Vite/Rolldown versions) then walk back to the variable
        # assignment that owns the placeholder object so the same variable name is preserved.
        $endPattern = 'EndOfJson:(?:"EndOfJson"|`EndOfJson`)\}'
        $endMatch = [regex]::Match($templateHtml, $endPattern)
        $insertLocationEnd = $endMatch.Index + $endMatch.Length

        # Find the last variable declaration (var/const/let NAME=) before the end marker.
        $startMatches = [regex]::Matches($templateHtml.Substring(0, $endMatch.Index), '(?:var|const|let)\s+\w+\s*=')
        $startMatch = $startMatches[$startMatches.Count - 1]
        $insertLocationStart = $startMatch.Index + $startMatch.Value.Length  # position just after the '='

        $outputHtml = $templateHtml.Substring(0, $insertLocationStart)
        $outputHtml += $json
        $outputHtml += $templateHtml.Substring($insertLocationEnd)

        return $outputHtml
    }
}
