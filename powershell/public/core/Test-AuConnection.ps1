function Test-AuConnection {
    <#
    .SYNOPSIS
    Checks if the current session is connected to the specified service. Use -Verbose to see the connection status for each service.

    .DESCRIPTION
    Tests the connection for each service and returns $true if the session is connected to the specified service.

    .PARAMETER Service
    The service to check the connection for. Valid values are 'ActiveDirectory', 'All', 'Azure', 'AzureDevOps', 'ExchangeOnline', 'GitHub', 'Graph', 'SecurityCompliance' (or 'EOP'), 'SharePointOnline', and 'Teams'. The default Boolean check is for Microsoft Graph. When -Details is used without -Service, all services are checked and summarized.

    Active Directory and GitHub require an explicit connection before testing; unlike other services they have no auto-detection. Active Directory is not included in -Service All. GitHub is not included in -Service All. Their current session state is included in the default -Details summary.

    .PARAMETER Details
    Return connection details instead of just a Boolean value. When -Service is omitted, the summary includes all default and opt-in services. Microsoft Graph details include the scopes in the current context and any required Aura scopes that are missing.

    .EXAMPLE
    Test-AuConnection -Service All

    Checks if the current session is connected to all Microsoft 365 services including Azure, Microsoft Graph, Exchange Online, Exchange Online Protection (SecurityCompliance), SharePoint Online (PnP), and Microsoft Teams. Returns a Boolean value.

    .EXAMPLE
    Test-AuConnection -Details

    Returns a connection summary for all supported services. Default services are listed first, followed by the opt-in Active Directory and GitHub services.

    .EXAMPLE
    Test-AuConnection -Service Azure

    Checks if the current session is connected to Azure and returns a Boolean result.

    .EXAMPLE
    Test-AuConnection -Service ActiveDirectory

    Checks whether Connect-Aura -Service ActiveDirectory completed successfully in this session.

    .EXAMPLE
    Test-AuConnection -Service GitHub

    Checks if the current session is connected to GitHub and returns a Boolean result.
    Returns $false if Connect-AuGitHub has not been called in this session.

    .LINK
    https://aura.onetapas.com/docs/commands/Test-AuConnection
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', 'AvoidUsingWriteHost', Justification = 'Sending colorful output to host in addition to rich object output.')]
    param(
        # Checks if the current session is connected to the specified service
        [ValidateSet('ActiveDirectory', 'All', 'Azure', 'AzureDevOps', 'ExchangeOnline', 'EOP', 'GitHub', 'Graph', 'SecurityCompliance', 'SharePointOnline', 'Teams')]
        [Parameter(Position = 0)]
        [string[]]$Service = 'Graph',

        # Return the full details of the connections
        [Parameter()]
        [switch]$Details
    )

    begin {
        $ServicesToCheck = if ($Details.IsPresent -and -not $PSBoundParameters.ContainsKey('Service')) {
            @('All', 'ActiveDirectory', 'GitHub')
        } else {
            @($Service)
        }

        $AuConnections = [PSCustomObject]@{
            PSTypeName               = 'Aura.Connections'
            ServicesChecked          = $ServicesToCheck
            ActiveDirectory          = $null
            Azure                    = $null
            AzureDevOps              = $null
            GitHub                   = $null
            Graph                    = $null
            GraphScopeDetails        = $null
            ExchangeOnline           = $null
            ExchangeOnlineProtection = $null
            SharePointOnline         = $null
            Teams                    = $null
            AllConnected             = $false
        }

        # This can potentially be replaced by $AuConnections.AllConnected but all functions that reference this function would need to be updated.
        $ConnectionState = $true
    }

    process {
        #region Active Directory
        if ($ServicesToCheck -contains 'ActiveDirectory') {
            $IsConnected = $false
            if ($null -ne $__AuSession.ADConnection -and $__AuSession.ADConnection.Connected -eq $true) {
                $AuConnections.ActiveDirectory = $__AuSession.ADConnection
                $IsConnected = $true
            }
            Write-Verbose "Active Directory: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion Active Directory

        #region Azure
        if ($ServicesToCheck -contains 'Azure' -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false
            try {
                $AuConnections.Azure = Get-AzContext
                $IsConnected = $null -ne ($AuConnections.Azure)
                # Validate that the credentials are still valid
                if ($IsConnected) {
                    $azError = @()
                    Invoke-AzRestMethod -Method GET -Path 'subscriptions?api-version=2022-12-01' -ErrorAction SilentlyContinue -ErrorVariable azError | Out-Null
                    if ($azError.Count -gt 0) {
                        $IsConnected = $false
                        $AuConnections.Azure = $null
                    }
                }
            } catch {
                $IsConnected = $false
                Write-Debug "Azure: $false"
            }
            Write-Verbose "Azure: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion Azure

        #region Graph
        if ($ServicesToCheck -contains 'Graph' -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false

            try {
                $AuConnections.Graph = Get-MgContext
                $IsConnected = $null -ne ($AuConnections.Graph)
            } catch {
                $AuConnections.Graph = $null
                Write-Debug "Graph connection check failed: $($_.Exception.Message)"
            }

            if ($IsConnected -and $Details.IsPresent) {
                $IncludedScopes = @()

                try {
                    $ScopeComparison = Compare-AuGraphScope `
                        -CurrentScopes $AuConnections.Graph.Scopes
                    $IncludedScopes = $ScopeComparison.IncludedScopes

                    $RequiredScopes = @(Get-AuGraphScope)
                    $ScopeComparison = Compare-AuGraphScope `
                        -CurrentScopes $IncludedScopes `
                        -RequiredScopes $RequiredScopes

                    $AuConnections.GraphScopeDetails = [PSCustomObject]@{
                        PSTypeName       = 'Aura.GraphScopeDetails'
                        EvaluationStatus = 'Succeeded'
                        IncludedScopes   = $ScopeComparison.IncludedScopes
                        RequiredScopes   = $ScopeComparison.RequiredScopes
                        MissingScopes    = $ScopeComparison.MissingScopes
                    }
                } catch {
                    $AuConnections.GraphScopeDetails = [PSCustomObject]@{
                        PSTypeName       = 'Aura.GraphScopeDetails'
                        EvaluationStatus = 'Failed'
                        IncludedScopes   = $IncludedScopes
                        RequiredScopes   = $null
                        MissingScopes    = $null
                    }
                    Write-Debug "Graph scope evaluation failed: $($_.Exception.Message)"
                }
            }

            Write-Verbose "Graph: $IsConnected"

            if (!$IsConnected) {
                $ConnectionState = $false
            }
        }
        #endregion Graph

        #region Exchange Online
        if ($ServicesToCheck -contains 'ExchangeOnline' -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false
            try {
                # Cache the connection information to avoid multiple calls to Get-ConnectionInformation. See https://github.com/tapasrc123/aura/pull/1207
                $AuConnections.ExchangeOnline = (Get-AuExo -Request ConnectionInformation | Where-Object { $_.Name -match 'ExchangeOnline' -and $_.state -eq 'Connected' -and -not $_.IsEopSession })
                $IsConnected = $null -ne ($AuConnections.ExchangeOnline)
            } catch {
                Write-Debug "Exchange Online: $false"
            }
            Write-Verbose "Exchange Online: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion Exchange Online

        #region Exchange Online Protection (EOP)
        if (($ServicesToCheck -contains 'SecurityCompliance' -or $ServicesToCheck -contains 'EOP') -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false
            try {
                # Cache the connection information to avoid multiple calls to Get-ConnectionInformation. See https://github.com/tapasrc123/aura/pull/1207
                $AuConnections.ExchangeOnlineProtection = (Get-AuExo -Request ConnectionInformation | Where-Object { $_.Name -match 'ExchangeOnline' -and $_.state -eq 'Connected' -and $_.IsEopSession })
                $IsConnected = $null -ne ($AuConnections.ExchangeOnlineProtection)
            } catch {
                # Re-test
                Write-Debug "Security & Compliance: $false"
            }
            Write-Verbose "Security & Compliance: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion Exchange Online Protection (EOP)

        #region Teams
        if ($ServicesToCheck -contains 'Teams' -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false
            try {
                $AuConnections.Teams = Get-CsTenant
                $IsConnected = $null -ne ($AuConnections.Teams)
            } catch {
                # Re-test
                Write-Debug "Teams: $false"
            }
            Write-Verbose "Teams: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion Teams

        #region SharePoint
        if ($ServicesToCheck -contains 'SharePointOnline' -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false
            try {
                $AuConnections.SharePointOnline = Get-PnPConnection
                $IsConnected = $null -ne ($AuConnections.SharePointOnline)
            } catch {
                Write-Debug "SharePointOnline: $false"
            }
            Write-Verbose "SharePointOnline: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion SharePoint

        #region AzureDevOps
        if ($ServicesToCheck -contains 'AzureDevOps' -or $ServicesToCheck -contains 'All') {
            $IsConnected = $false
            if ($null -ne $__AuSession.AzureDevOpsConnectionCache) {
                # Use cached probe result to avoid re-running the connection check on every test.
                if ($__AuSession.AzureDevOpsConnectionCache -is [string] -and $__AuSession.AzureDevOpsConnectionCache -eq 'NotConnected') {
                    $IsConnected = $false
                } else {
                    $AuConnections.AzureDevOps = $__AuSession.AzureDevOpsConnectionCache
                    $IsConnected = $true
                }
            } else {
                try {
                    if ($null -ne (Get-Command -Name Get-ADOPSConnection -ErrorAction Stop)) {
                        $connection = Get-ADOPSConnection
                        if ($null -ne $connection -and $null -ne $connection['Organization']) {
                            $AuConnections.AzureDevOps = $connection
                            $__AuSession.AzureDevOpsConnectionCache = $connection
                            $IsConnected = $true
                        }
                    }
                } catch {
                    Write-Debug "AzureDevOps: $false"
                }
                if (-not $IsConnected) {
                    # Cache negative result so subsequent calls skip the probe.
                    $__AuSession.AzureDevOpsConnectionCache = 'NotConnected'
                }
            }
            Write-Verbose "AzureDevOps: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion AzureDevOps

        #region GitHub
        if ($ServicesToCheck -contains 'GitHub') {
            $IsConnected = $false
            if ($null -ne $__AuSession.GitHubConnection) {
                if ($__AuSession.GitHubConnection.Connected -eq $true) {
                    $AuConnections.GitHub = $__AuSession.GitHubConnection
                    $IsConnected = $true
                }
            } else {
                # No session state — GitHub requires explicit Connect-AuGitHub (no module auto-detect)
                $__AuSession.GitHubConnection = [PSCustomObject]@{ Connected = $false; FailureReason = 'NotCalled' }
            }
            Write-Verbose "GitHub: $IsConnected"
            if (!$IsConnected) { $ConnectionState = $false }
        }
        #endregion GitHub

        $AuConnections.AllConnected = $ConnectionState

    }

    end {
        if ($Details.IsPresent) {
            # Return the full details of all active connections.
            $AuConnections
        } else {
            # Only return a boolean value indicating if all sessions are connected.
            $ConnectionState
        }
    }
}
