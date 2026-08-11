function Update-AuraApp {
    <#
    .SYNOPSIS
    Updates an existing Aura application with the latest required permissions.

    .DESCRIPTION
    Updates an existing Aura application in Azure AD/Entra ID with the current set of required
    Graph API permissions. This is useful when new permissions are added to Aura and existing
    applications need to be updated to include them.

    .PARAMETER ApplicationId
    The Application (Client) ID of the existing Aura application to update.

    .PARAMETER SendMail
    If specified, includes the Mail.Send permission scope.

    .PARAMETER SendTeamsMessage
    If specified, includes the ChannelMessage.Send permission scope.

    .PARAMETER Privileged
    If specified, includes privileged permission scopes for read-write operations.

    .PARAMETER Scopes
    Additional custom permission scopes to include beyond the default Aura scopes.

    .EXAMPLE
    Update-AuraApp -AppId "12345678-1234-1234-1234-123456789012"

    Updates the specified Aura app with the current default permissions.

    .EXAMPLE
    Update-AuraApp -AppId "12345678-1234-1234-1234-123456789012" -SendMail -Privileged

    Updates the specified Aura app with mail sending and privileged capabilities.

    .EXAMPLE
    Update-AuraApp -AppId "12345678-1234-1234-1234-123456789012" -Scopes @("User.Read.All")

    Updates the specified Aura app with additional custom scopes.

    .LINK
    https://aura.onetapas.com/docs/commands/Update-AuraApp
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
    [CmdletBinding()]
    param(
        # The ID of the Aura app to update
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [Alias('ObjectId')]
        [string] $Id,

        # The Application (Client) ID of the Aura app to update
        [Parameter(Mandatory = $true, ParameterSetName = 'ByApplicationId')]
        [Alias('ClientId')]
        [string] $AppId,

        # Include Mail.Send permission scope
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [ValidateSet('ById', 'ByApplicationId')]
        [switch] $SendMail,

        # Include ChannelMessage.Send permission scope
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [ValidateSet('ById', 'ByApplicationId')]
        [switch] $SendTeamsMessage,

        # Include privileged permission scopes
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [ValidateSet('ById', 'ByApplicationId')]
        [switch] $Privileged,

        # Additional custom permission scopes
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [string[]] $Scopes = @()
    )

    process {
        if (-not (Test-AuAzContext)) {
            return
        }
        try {

            if ($Id) {
                $app = Get-AuraApp -Id $Id -ErrorAction Stop
                if (-not $app) {
                    Write-Error "Aura application with ID '$Id' not found. Use Get-AuraApp to find existing Aura applications."
                    return
                }
                $AppId = $app.appId
            } else {
                # Find the application by AppId
                $appFilter = "appId eq '$AppId'"
                $result = Invoke-AuAzureRequest -RelativeUri 'applications' -Filter $appFilter -Method GET -Graph
                $apps = $result.value
                if ($apps.Count -eq 0) {
                    Write-Error "Application with ID '$AppId' not found. Use Get-AuraApp to find existing Aura applications."
                    return
                }

                $app = $apps[0]
            }

            Write-Host "✅ Found application: $($app.displayName)" -ForegroundColor Green

            # Verify this is a Aura app
            if ($app.tags -notcontains "aura") {
                Write-Warning "Application '$($app.displayName)' does not have the 'aura' tag. Do you want to tag this as a Aura application?"
                $confirmation = Read-Host "Do you want to continue? (y/N)"
                if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
                    Write-Host "Update cancelled." -ForegroundColor Yellow
                    return
                }
            }

            # Get the required scopes
            $scopeParams = @{}
            if ($SendMail) { $scopeParams['SendMail'] = $true }
            if ($SendTeamsMessage) { $scopeParams['SendTeamsMessage'] = $true }
            if ($Privileged) { $scopeParams['Privileged'] = $true }

            $requiredScopes = Get-AuGraphScope @scopeParams

            # Add any additional custom scopes
            if ($Scopes) {
                $requiredScopes += $Scopes
                $requiredScopes = $requiredScopes | Sort-Object -Unique
            }

            Write-Host "Updating permissions..." -ForegroundColor Yellow
            Write-Verbose "Required scopes: $($requiredScopes -join ', ')"

            # Set the permissions
            Set-AuraAppPermission -AppId $app.appId -Scopes $requiredScopes

            # Update the application tags and description
            $updateBody = @{
                tags        = @("aura")
                description = "Application created by Aura for running security assessments in DevOps pipelines"
            } | ConvertTo-Json

            Write-Host "Updating application metadata..." -ForegroundColor Yellow
            Invoke-AuAzureRequest -RelativeUri "applications/$($app.id)" -Method PATCH -Payload $updateBody -Graph | Out-Null
            Write-Host "✅ Application metadata updated successfully" -ForegroundColor Green

            # Output the result
            $result = Get-AuraAppInfo -App $app

            Write-Host ""
            Write-Host "🎉 Aura application updated successfully!" -ForegroundColor Green

            return $result

        } catch {
            Write-Error "Failed to update Aura application: $($_.Exception.Message)"
            throw
        }
    }
}
