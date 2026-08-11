function Add-AuraAppFederatedCredential {
    <#
    .SYNOPSIS
    Adds a federated credential to a Aura application for GitHub Actions authentication.

    .DESCRIPTION
    Adds a federated credential (workload identity) to a Aura application to enable
    authentication from GitHub Actions workflows without using client secrets.
    The credential allows the specified GitHub repository and branch to authenticate
    as the application.

    .PARAMETER Id
    The Object ID of the Aura application to add the federated credential to.

    .PARAMETER AppId
    The Application (Client) ID of the Aura application to add the federated credential to.

    .PARAMETER GitHubRepository
    The GitHub repository name (without the organization). E.g. aura-tests.
    If both -GitHubOrganization and -GitHubRepository are omitted and the current working
    directory is inside a git repository whose 'origin' remote points at GitHub, both
    values are auto-detected from `git remote get-url origin`. Specifying one without
    the other is not supported - either pass both explicitly, or pass neither and rely
    on auto-detection.

    .PARAMETER GitHubBranch
    The GitHub branch that can use this credential. Defaults to 'main'.

    .PARAMETER Name
    The name for the federated credential. Defaults to 'aura-devops-<org>-<repo>'.

    .PARAMETER SetGitHubSecrets
    If specified, sets the AZURE_CLIENT_ID and AZURE_TENANT_ID secrets on the target
    GitHub repository using the GitHub CLI (`gh`). Requires `gh` to be installed and
    authenticated (`gh auth login`). When the secrets cannot be set automatically the
    cmdlet falls back to printing the manual setup instructions.

    Re-running the cmdlet with -SetGitHubSecrets against an app that already has a
    matching federated credential will skip the credential creation step and proceed
    directly to (re)setting the secrets.

    .EXAMPLE
    Add-AuraAppFederatedCredential -AppId "12345678-1234-1234-1234-123456789012" -GitHubOrganization "myorg" -GitHubRepository "myrepo"

    Adds a federated credential for the main branch of myorg/myrepo to the specified Aura app.

    .EXAMPLE
    Add-AuraAppFederatedCredential -Id "87654321-4321-4321-4321-210987654321" -GitHubOrganization "myorg" -GitHubRepository "myrepo" -Name "aura-develop"

    Adds a federated credential for the develop branch with a custom name.

    .EXAMPLE
    Add-AuraAppFederatedCredential -AppId "12345678-1234-1234-1234-123456789012" -SetGitHubSecrets

    Auto-detects the GitHub organization and repository from the current git remote, adds
    the federated credential, and pushes AZURE_CLIENT_ID / AZURE_TENANT_ID to the repo's
    Actions secrets via the GitHub CLI.

    .LINK
    https://aura.onetapas.com/docs/commands/Add-AuraAppFederatedCredential
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

        # Your GitHub organization name or GitHub username. E.g. jasonf.
        # If omitted (together with -GitHubRepository) the value is auto-detected from
        # the local git remote ('origin') when the current directory is a git repo.
        [Parameter(Mandatory = $false)]
        [string] $GitHubOrganization,

        # Your GitHub repository name where the GitHub Actions workflow is located. E.g. aura-tests.
        # Auto-detected from the local git remote ('origin') when omitted.
        [Parameter(Mandatory = $false)]
        [string] $GitHubRepository,

        # The GitHub branch that can use this credential
        [Parameter(Mandatory = $false)]
        [string] $GitHubBranch = 'main',

        # The name for the federated credential
        [Parameter(Mandatory = $false)]
        [string] $Name,

        # If set, also pushes AZURE_CLIENT_ID and AZURE_TENANT_ID to the GitHub repo's
        # Actions secrets using the GitHub CLI (`gh`). Falls back to printing manual
        # instructions if `gh` is not installed or not authenticated.
        [Parameter(Mandatory = $false)]
        [switch] $SetGitHubSecrets
    )

    if (-not (Test-AuAzContext)) {
        return
    }

    # Auto-detect GitHub org/repo from the local git remote. Only triggers when BOTH
    # parameters were omitted - mixing an explicit value with an auto-detected one is
    # ambiguous (which repo did the caller really mean?) so we require both-or-neither.
    if (-not $GitHubOrganization -and -not $GitHubRepository) {
        $detected = Get-AuGitHubRepoFromGit
        if ($detected) {
            $GitHubOrganization = $detected.Organization
            $GitHubRepository   = $detected.Repository
            Write-Host "Auto-detected GitHub repository from git remote: $GitHubOrganization/$GitHubRepository" -ForegroundColor Cyan
        }
    } elseif (-not $GitHubOrganization -or -not $GitHubRepository) {
        Write-Error "Specify both -GitHubOrganization and -GitHubRepository, or omit both to auto-detect from the local git remote."
        return
    }

    if (-not $GitHubOrganization -or -not $GitHubRepository) {
        Write-Error "GitHubOrganization and GitHubRepository are required. They can be auto-detected when the current directory is a git working tree whose 'origin' remote points at GitHub."
        return
    }

    try {
        if ($Id) {
            $params = @{ Id = $Id }
        } elseif ($AppId) {
            $params = @{ AppId = $AppId }
        }

        $app = Get-AuraApp @params
        if (-not $app) {
            $errorId = if($Id) { $Id } else { $AppId }
            Write-Error "Aura application not found with the specified identifier: $errorId."
            return
        }

        Write-Host "Adding federated credential to Aura application" -ForegroundColor Green
        Write-Output $app

        if (-not $Name) { # Set default name if not provided
            $Name = "aura-devops-$($GitHubOrganization)-$($GitHubRepository)"
        }
        $githubIssuer = "https://token.actions.githubusercontent.com"

        # Check for existing federated credentials
        Write-Verbose "Checking for existing federated credentials..."
        $existingCredsResponse = Invoke-AuAzureRequest -RelativeUri "applications/$($app.id)/federatedIdentityCredentials" -Method GET -Graph

        $existingCreds = $existingCredsResponse.value

        # Check if a similar credential already exists
        $duplicateName = $existingCreds | Where-Object { $_.name -eq $Name }
        $duplicateSubject = $existingCreds | Where-Object {
            ($_.subject -eq "repo:$GitHubOrganization/$GitHubRepository`:ref:refs/heads/$GitHubBranch" -and $_.issuer -eq $githubIssuer)
        }

        if ($duplicateName -or $duplicateSubject) {
            # duplicateSubject = an existing credential already grants the requested
            # repo/branch. That is not a failure - the desired end state already exists,
            # so we treat re-runs as idempotent (and continue to secrets setup when asked).
            #
            # duplicateName without duplicateSubject = the name is taken by a credential
            # for a DIFFERENT repo/branch. The requested credential cannot be created,
            # so this remains a hard error so callers / automation detect the failure.
            if ($duplicateSubject) {
                Write-Warning "A federated credential for this repository already exists:"
                $duplicateCred = $duplicateSubject
            }
            elseif ($duplicateName) {
                Write-Error "A federated credential with the name '$Name' already exists for a different repository or branch. Choose a different -Name or remove the existing credential."
                $duplicateName | ForEach-Object {
                    Write-Host "  Name: $($_.name)" -ForegroundColor Yellow
                    Write-Host "  Subject: $($_.subject)" -ForegroundColor Yellow
                    Write-Host ""
                }
                return
            }

            $duplicateCred | ForEach-Object {
                Write-Host "  Name: $($_.name)" -ForegroundColor Yellow
                Write-Host "  Subject: $($_.subject)" -ForegroundColor Yellow
                Write-Host ""
            }

            # If the existing credential already matches the requested repo/branch and the
            # caller asked us to also set secrets, do that work instead of silently returning.
            # This makes `-SetGitHubSecrets` idempotent on re-runs.
            if ($duplicateSubject -and $SetGitHubSecrets) {
                Write-Host "Existing credential matches - proceeding to (re)set GitHub Actions secrets." -ForegroundColor Cyan
                $tenantId = (Get-AzContext).Tenant.Id
                $secretsConfigured = Set-AuGitHubActionsSecret -GitHubRepository "$GitHubOrganization/$GitHubRepository" -ClientId $app.AppId -TenantId $tenantId
                if (-not $secretsConfigured) {
                    Write-AuGitHubSecretsManualInstruction -GitHubOrganization $GitHubOrganization -GitHubRepository $GitHubRepository -ClientId $app.AppId -TenantId $tenantId -AttemptedAutomatic
                }
                return $duplicateSubject
            }

            return
        }

        # Create the federated credential
        $federatedCredential = @{
            name        = $Name
            issuer      = $githubIssuer
            subject     = "repo:$GitHubOrganization/$GitHubRepository`:ref:refs/heads/$GitHubBranch"
            audiences   = @("api://AzureADTokenExchange")
            description = "Federated credential for GitHub Actions in $GitHubOrganization/$GitHubRepository ($GitHubBranch branch) - Created by Aura"
        } | ConvertTo-Json -Depth 3

        Write-Verbose "Creating federated credential with payload: $federatedCredential"

        $createdCredential = Invoke-AuAzureRequest -RelativeUri "applications/$($app.id)/federatedIdentityCredentials" -Method POST -Payload $federatedCredential -Graph

        if ($createdCredential.error) {
            throw "Failed to create federated credential. Error: $($createdCredential.error.message)"
        }

        $tenantId = (Get-AzContext).Tenant.Id

        Write-Host ""
        Write-Host "🎉 Federated credential created successfully!" -ForegroundColor Green
        Write-Host ""

        $secretsConfigured = $false
        if ($SetGitHubSecrets) {
            $secretsConfigured = Set-AuGitHubActionsSecret -GitHubRepository "$GitHubOrganization/$GitHubRepository" -ClientId $app.AppId -TenantId $tenantId
        }

        if (-not $secretsConfigured) {
            $manualParams = @{
                GitHubOrganization = $GitHubOrganization
                GitHubRepository   = $GitHubRepository
                ClientId           = $app.AppId
                TenantId           = $tenantId
            }
            if ($SetGitHubSecrets) { $manualParams['AttemptedAutomatic'] = $true }
            Write-AuGitHubSecretsManualInstruction @manualParams
        }

        return $createdCredential

    } catch {
        Write-Error "Failed to add federated credential: $($_.Exception.Message)"
        throw
    }
}
