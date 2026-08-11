function Get-AuraApp {
    <#
    .SYNOPSIS
    Retrieves Aura applications from Azure AD/Entra ID.

    .DESCRIPTION
    Retrieves all applications in Azure AD/Entra ID that have been tagged as Aura applications.
    This includes applications created by New-AuraApp or manually tagged with 'aura'.

    .PARAMETER AppId
    If specified, retrieves only the Aura application with the specified Application (Client) ID.

    .PARAMETER Name
    If specified, retrieves only Aura applications with display names containing the specified text.

    .EXAMPLE
    Get-AuraApp

    Retrieves all Aura applications in the tenant.

    .EXAMPLE
    Get-AuraApp -AppId "12345678-1234-1234-1234-123456789012"

    Retrieves the specific Aura application with the given Application ID.

    .EXAMPLE
    Get-AuraApp -Name "DevOps"

    Retrieves all Aura applications that start with "DevOps" in their display name.

    .LINK
    https://aura.onetapas.com/docs/commands/Get-AuraApp
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
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

        # Filter by application display name (starts with)
        # The Application (Client) ID of the Aura app to update
        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [string] $Name
    )

    if (-not (Test-AuAzContext)) {
        return
    }

    Write-Verbose "Searching for Aura applications..."

    $select = "id,appId,displayName,description,tags,createdDateTime,signInAudience"

    if ($Id) {
        # If Id is specified, get the application directly
        Write-Verbose "Getting application with Object ID: $Id"
        $app = Invoke-AuAzureRequest -RelativeUri "applications/$Id" -Method GET -Graph -Select $select
        if ($null -eq $app.id) {
            Write-Warning "No application found with ID '$Id'."
            return
        }
        return Get-AuraAppInfo -App $app
    } else {
        # Build the filter
        $filters = @()

        # Add AppId filter if specified
        if ($AppId) {
            $filters += "appId eq '$AppId'"
        } else {
            # Filter by the aura tag
            $filters += "tags/any(t:t eq 'aura')"
        }

        # Add Name filter if specified
        if ($Name) {
            $filters += "startswith(displayName, '$Name')"
        }

        $filter = $filters -join ' and '

        Write-Verbose "Query URI: $path"
        $result = Invoke-AuAzureRequest -RelativeUri "applications" -Method GET -Graph -Filter $filter -Select $select

        $apps = $result.value

        if ($apps.Count -eq 0) {
            if ($AppId) {
                Write-Warning "No Aura application found with App ID '$AppId'."
            } elseif ($Name) {
                Write-Warning "No Aura applications found with name containing '$Name'."
            } else {
                Write-Warning "No Aura applications found in this tenant."
                Write-Host "Use New-AuraApp to create a new Aura application." -ForegroundColor Yellow
            }
            return
        }

        # Get service principal information for each app
        foreach ($app in $apps) {
            Get-AuraAppInfo -App $app
        }
        Write-Verbose "Found $($apps.Count) Aura application(s)"
    }
}
