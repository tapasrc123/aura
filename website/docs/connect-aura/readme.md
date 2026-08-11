---
sidebar_label: Connect-Aura
sidebar_position: 1
title: Connect-Aura
---

# Connect-Aura

## Overview

`Connect-Aura` is a helper command that simplifies the process of authenticating to the services required to run Aura tests including Microsoft Graph PowerShell, Azure PowerShell and Exchange Online PowerShell.

While `Connect-Aura` will handle the most common interactive authentication scenarios, it does not replicate all of the authentication options available in the respective modules.

:::tip
The `Connect-Aura` command is completely optional if your current PowerShell session is already connected to Microsoft Graph using Connect-MgGraph.
:::

Examining the code for `Connect-Aura` will reveal that it simply calls `Connect-MgGraph`.

```mermaid
graph TD;
    Connect-Aura-->Connect-MgGraph;
```

What this means is that you can use `Connect-MgGraph` directly if you prefer to have more control over the authentication process. See the [Connect-MgGraph: Microsoft Graph authentication](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands) documentation for more information on all the options available including the use of certificates, secrets, managed identities, different clouds and more.

## Using Connect-Aura

### Connect to Microsoft Graph

To connect to Microsoft Graph, use the following command:

```powershell
Connect-Aura
```

Running `Connect-Aura` is the same as running the following:

```powershell
Connect-MgGraph -Scopes (Get-AuGraphScope)
```

#### Send Mail and Teams message

Connects to Microsoft Graph with the Mail.Send scope in addition to the default Aura scopes. This allows you to use the required permission to send email when using the `Send-AuMail` command or when using `Invoke-Aura -MailRecipient john@contoso.com`

```powershell
Connect-Aura -SendMail
```

This is the same as running

```powershell
Connect-MgGraph -Scopes (Get-AuGraphScope -SendMail)
```

The same applies to the `-SendTeamsMessage` in `Connect-Aura`.

#### Privileged scope

Aura is designed to require read-only access to a tenant to run tests.

However, certain tests like [Test-AuExoMoeraMailActivity](../commands/Test-AuExoMoeraMailActivity.mdx) require privileged permission scopes to call certain APIs. If the permission is not granted, the specific test will be skipped.

Connecting with privileged scopes is optional. To connect with privileged scopes, use the `-Privileged` switch:

```powershell
Connect-Aura -Privileged
```

#### Device code

The `-DeviceCode` switch allows you to sign in using the device code flow. This will open a browser window to prompt for authentication and is useful on Windows when you want to avoid single signing on as the current user.

```powershell
Connect-Aura -UseDeviceCode
```

### Connect to SharePoint Online (optional)

Aura includes SharePoint Online security tests that use the [PnP PowerShell](https://pnp.github.io/powershell/) module.

Install the PnP PowerShell module if you haven't already:

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
```

A dedicated Entra ID app registration configured for PnP interactive login is required. The easiest way to create one is to follow the official [PnP app registration guide](https://pnp.github.io/powershell/articles/registerapplication.html) and run `Register-PnPEntraIDAppForInteractiveLogin`, which outputs the **Client ID** you will supply to `-SharePointClientId`. For the Aura-specific SharePoint permission setup, see [Grant permissions to SharePoint Online](../sections/create-entra-app.md).


Connect to SharePoint Online together with Microsoft Graph (the admin URL is auto-discovered from your tenant's initial domain):

```powershell
Connect-Aura -Service Graph,SharePointOnline -SharePointClientId '<Client ID>'
```

If auto-discovery does not work (e.g. in government or custom-domain tenants), supply the admin URL explicitly:

```powershell
Connect-Aura -Service Graph,SharePointOnline -SharePointClientId '<Client ID>' -SharePointAdminUrl 'https://contoso-admin.sharepoint.com'
```

If the PnP PowerShell module is not installed or there is no active connection, all SharePoint Online tests are skipped automatically.

### Connect to Azure, Exchange Online, Copilot Studio and Teams

`Connect-Aura` also provides options to connect to Azure, Copilot Studio (via the Dataverse API), Exchange Online and Teams for running tests that use the Azure PowerShell, Dataverse OData API, Exchange Online PowerShell or Teams PowerShell modules.

The `-All` switch can be used to connect to all the services used by the Aura tests. This includes Microsoft Graph, Azure, Copilot Studio (Dataverse), Exchange Online, Security Compliance, Microsoft Teams, and SharePoint Online.

If `-SharePointClientId` is not provided, the SharePoint Online connection is skipped with a warning.

```powershell
Connect-Aura -Service All
```

If you need to connect to just a subset of the services you can specifiy them using the `-Service` parameter.

```powershell
Connect-Aura -Service Azure,Graph,Teams
```

### Connect to Copilot Studio (via Dataverse)

To run the Copilot Studio Security Tests (MT.1113–MT.1122), connect with the `Dataverse` service:

```powershell
Connect-Aura -Service Graph,Dataverse
```

This uses `Az.Accounts` to authenticate and obtain a Dataverse access token for the Copilot Studio environment configured in `aura-config.json`.

### Connect to GitHub (optional)

Aura includes optional GitHub security tests that require an active GitHub organization connection. GitHub is not included in `Connect-Aura -Service All` because it is not a Microsoft 365 service. Add `GitHub` explicitly when you want to run GitHub tests.

For interactive sessions, the preferred option is the [Aura GitHub App](https://github.com/apps/aura-cli). It uses GitHub OAuth device flow, so you do not need to create, paste, or store a personal access token for day-to-day interactive use.

```powershell
Connect-Aura -Service Graph,GitHub -GitHubOrganization '<github-organization>'
```

You can also connect only to GitHub:

```powershell
Connect-Aura -Service GitHub -GitHubOrganization '<github-organization>'
```

The first time you connect, Aura opens the GitHub device authorization page and shows a code to enter. If the Aura GitHub App is not installed or approved for the organization, Aura explains why the app is needed and asks before opening the [install page](https://github.com/apps/aura-cli/installations/new). A GitHub organization owner may need to install or approve the app for the organization.

You can avoid typing the organization every time by setting `GitHubOrganization` in `aura-config.json`:

```json
{
  "GlobalSettings": {
    "GitHubOrganization": "contoso"
  }
}
```

Then connect with:

```powershell
Connect-Aura -Service Graph,GitHub
```

For automation, use a GitHub token instead of the interactive GitHub App device flow. `Connect-Aura` checks `AURA_GITHUB_TOKEN` first and then `GH_TOKEN`.

```powershell
$env:AURA_GITHUB_TOKEN = '<token>'
Connect-Aura -Service Graph,GitHub -GitHubOrganization '<github-organization>'
```

Use a token that can read organization membership and organization administration settings. For example, use a classic PAT with `admin:org`, or a fine-grained token with **Organization Members: read** and **Organization Administration: read**.

Use `Disconnect-Aura` or `Disconnect-AuGitHub` to clear the in-memory GitHub session when you are finished.

### Connect to Azure DevOps (optional)

Aura includes an *optional* set of Azure DevOps security tests (AZDO.*).
These tests require the community [`ADOPS`](https://www.powershellgallery.com/packages/ADOPS) PowerShell module and an active connection to your Azure DevOps organization.

Connecting to Azure DevOps is **not** part of `Connect-Aura` and must be done separately:

```powershell
Install-Module ADOPS -Scope CurrentUser
Connect-ADOPS -Organization <your-organization>
```

If the `ADOPS` module is not installed or there is no active connection, the Azure DevOps tests are skipped automatically.

See the [installation guide](../installation.md#installing-azure-devops-powershell-module) for prerequisites and permissions, and the [Azure DevOps tests for Aura](/blog/azuredevops-tests-for-aura) blog post for the full list of available tests.

### Connect to US Government, US DoD, China and Germany and other clouds

`Connect-Aura` also provides options to connect to the US Government, China and Germany clouds for Microsoft Graph, Azure and Exchange Online.

#### US Government

```powershell
Connect-Aura -Environment USGov -AzureEnvironment AzureUSGovernment -ExchangeEnvironmentName O365USGovGCCHigh
```

#### US Department of Defense (DoD)

```powershell
Connect-Aura -Environment USGovDoD -AzureEnvironment AzureUSGovernment -ExchangeEnvironmentName O365USGovDoD
```

#### China

```powershell
Connect-Aura -Environment China -AzureEnvironment AzureChinaCloud -ExchangeEnvironmentName O365China
```

#### Germany

```powershell
Connect-Aura -Environment Germany
```

### Connect using a custom application

You can use `Connect-Aura` to connect to Microsoft Graph using a custom application by specifying the `-GraphClientId` parameter. This is useful if you wish to use a custom application for Aura instead of using the default Graph PowerShell application.

```powershell
Connect-Aura -GraphClientId 'f45ec3ad-32f0-4c06-8b69-47682afe0216'
```

To learn more about how to create a custom application for Microsoft Graph PowerShell see [Use delegated access with a custom application for Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0#use-delegated-access-with-a-custom-application-for-microsoft-graph-powershell).
