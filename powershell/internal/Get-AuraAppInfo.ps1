function Get-AuraAppInfo {
    <#
    .SYNOPSIS
    Returns a formatted object with information about a Aura application created in Entra.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [object] $App
    )

    if($__AuSession.AdminPortalUrl){
        $adminBaseUrl = $__AuSession.AdminPortalUrl
    }
    else{
        $adminBaseUrl = 'https://entra.microsoft.com/'
    }
    $portalLink = "$($adminBaseUrl)#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Overview/appId/$($app.appId)"

    # Create the output object
    $appInfo = [PSCustomObject]@{
        DisplayName     = $app.displayName
        AppId           = $app.appId
        Id        = $app.id
        PortalLink      = $portalLink
        Description     = $app.description
        CreatedDateTime = $app.createdDateTime
        Tags            = $app.tags
    }

    return $appInfo
}
