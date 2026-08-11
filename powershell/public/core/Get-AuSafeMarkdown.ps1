function Get-AuSafeMarkdown {
    <#
	.SYNOPSIS
		Escapes text to be safe to use in markdown.

	.DESCRIPTION
		Escapes text to be safe to use in markdown.

	.PARAMETER Text
		The text to escape

	.EXAMPLE
		PS C:\> Get-AuSafeMarkdown -Text $tenantName

		Converts the content of $tenantName into something safe to use in markdown.

	.LINK
		https://aura.onetapas.com/docs/commands/Get-AuSafeMarkdown
	#>
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Text
    )
    Write-Verbose "Escaping markdown text."
    $Text -replace "\[", "\[" -replace "\]", "\]"
}
