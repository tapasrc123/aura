function Disconnect-Aura {
   <#
    .Synopsis
    Disconnects the services connected through Connect-Aura.

    .Description
    Use this cmdlet to sign out of the services connected through Connect-Aura.
    It also clears Aura Active Directory and GitHub session state. Use
    Disconnect-AuGraph when you only want to disconnect Microsoft Graph.

    .Example
    Disconnect-AuGraph

    .Example
    Disconnect-Aura

    .Example
    Disconnect-Aura

    .LINK
    https://aura.onetapas.com/docs/commands/Disconnect-Aura
    #>
   [Alias("Disconnect-Aura", "Disconnect-AuGraph")]
   [CmdletBinding()]
   param()

   if ($__AuSession.Connections -contains "Graph" -or $__AuSession.Connections -contains "All") {
      Write-Verbose -Message "Disconnecting from Microsoft Graph."
      Disconnect-MgGraph
   }

   if ($__AuSession.Connections -contains "Azure" -or $__AuSession.Connections -contains "Dataverse" -or $__AuSession.Connections -contains "All") {
      Write-Verbose -Message "Disconnecting from Microsoft Azure."
      try {
         Disconnect-AzAccount -ErrorAction Stop | Out-Null
      } catch {
         Write-Verbose "Disconnect-AzAccount encountered an error: $($_.Exception.Message)"
      }
   }

   if ($__AuSession.Connections -contains "ExchangeOnline" -or $__AuSession.Connections -contains "SecurityCompliance" -or $__AuSession.Connections -contains "All") {
      Write-Verbose -Message "Disconnecting from Microsoft Exchange Online."
      Disconnect-ExchangeOnline
   }
   if ($__AuSession.Connections -contains "SharePointOnline" -or $__AuSession.Connections -contains "All") {
      Write-Verbose -Message "Disconnecting from SharePoint Online (PnP)."
      try {
         Disconnect-PnPOnline -ErrorAction Stop
      } catch {
         Write-Verbose "Disconnect-PnPOnline encountered an error: $($_.Exception.Message)"
      }
      $__AuSession.SpoCache = @{}
   }

   if ($__AuSession.Connections -contains "Teams" -or $__AuSession.Connections -contains "All") {
      Write-Verbose -Message "Disconnecting from Microsoft Teams."
      Disconnect-MicrosoftTeams
   }

   if ($MyInvocation.InvocationName -notmatch '(^|\\)Disconnect-AuGraph$') {
      if ($null -ne $__AuSession.ADConnection) {
         Write-Verbose -Message "Clearing Active Directory connection data."
         $__AuSession.ADConnection = $null
         Clear-AuADCache
      }

      Write-Verbose -Message "Disconnecting from GitHub."
      Disconnect-AuGitHub
   }
}
