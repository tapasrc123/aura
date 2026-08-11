---
title: Overview
sidebar_position: 1
---

# Configure Aura

Aura uses a configuration file called `aura-config.json` to customize how tests are run and to define global settings for your environment. This guide explains how the configuration system works and how to customize it for your organization.

## How Configuration Works

Aura uses a two-tier configuration system:

1. **Main Configuration** (`./tests/aura-config.json`) - Contains the default settings for all Aura tests. This file is maintained by the Aura team and is updated when you run `Update-AuraTests`.

2. **Custom Configuration** (`./tests/Custom/aura-config.json`) - Your organization-specific overrides. Settings in this file take precedence over the main configuration.

:::warning Important
Never edit the main `aura-config.json` file in the `./tests` folder directly. Your changes will be overwritten when you update Aura tests.

Always use the `./tests/Custom/aura-config.json` file for your customizations.
:::

## Configuration File Structure

The configuration file has two main sections:

```json
{
  "GlobalSettings": {
    // Organization-wide settings that apply to multiple tests
  },
  "TestSettings": [
    // Test-specific settings like severity levels
  ]
}
```

### GlobalSettings

The `GlobalSettings` section contains organization-wide configuration that can be used by multiple tests. For example, you can define your emergency access accounts here so that all related tests use the same accounts.

### TestSettings

The `TestSettings` section allows you to customize individual test behavior, such as overriding the default severity level. See [Severity Levels](./severity-levels) for more details.

## Creating Your Custom Configuration

To create your custom configuration file:

1. Navigate to your Aura tests folder
2. Create a file called `aura-config.json` in the `Custom` folder
3. Add your custom settings

```bash
# Create the custom config file
./tests/Custom/aura-config.json
```

Here's a complete example of a custom configuration file:

```json
{
  "GlobalSettings": {
    "EmergencyAccessAccounts": [
      {
        "UserPrincipalName": "BreakGlass1@contoso.com",
        "Type": "User"
      },
      {
        "Id": "00000000-0000-0000-0000-000000000000",
        "Type": "Group"
      }
    ]
  },
  "TestSettings": [
    {
      "Id": "MT.1005",
      "Severity": "Critical"
    }
  ]
}
```

## Available Global Settings

The following global settings are available for customization:

| Setting | Description | Documentation |
|---------|-------------|---------------|
| `EmergencyAccessAccounts` | Define your break glass accounts and groups | [Emergency Access Accounts](./emergency-access-accounts.md) |

## How Settings Are Merged

When Aura loads the configuration:

1. It first loads the main `aura-config.json` from the `./tests` folder
2. Then it looks for `./tests/Custom/aura-config.json`
3. Any settings in the custom file **override** the corresponding settings in the main file
4. New settings in the custom file are **added** to the configuration

This means you only need to include the settings you want to change or add in your custom configuration file.

## Validating Your Configuration

After creating or modifying your configuration file, you can verify it's being loaded correctly by running Aura with verbose output:

```powershell
Invoke-Aura -Verbose
```

Look for messages indicating your custom configuration was found and merged.
