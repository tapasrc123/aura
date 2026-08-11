function Compare-AuGraphScope {
    <#
    .SYNOPSIS
    Compares the scopes in a Microsoft Graph context with required Aura scopes.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter()]
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $CurrentScopes = @(),

        [Parameter()]
        [AllowNull()]
        [AllowEmptyCollection()]
        [string[]] $RequiredScopes = @()
    )

    $includedScopes = @(
        $CurrentScopes |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
    )

    $normalizedRequiredScopes = @(
        $RequiredScopes |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
    )

    $missingScopes = @(
        $normalizedRequiredScopes |
            Where-Object {
                $readWriteEquivalent = $_ -replace '\.Read(?=\.|$)', '.ReadWrite'

                $includedScopes -notcontains $_ -and
                    $includedScopes -notcontains $readWriteEquivalent
            }
    )

    [PSCustomObject]@{
        PSTypeName     = 'Aura.GraphScopeComparison'
        IncludedScopes = $includedScopes
        RequiredScopes = $normalizedRequiredScopes
        MissingScopes  = $missingScopes
    }
}
