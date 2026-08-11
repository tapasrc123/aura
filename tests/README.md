# Aura Tests

This folder contains the tests that Aura will run to validate your environment. The tests are organized into the following folders:

- **Custom**: Place your custom Pester tests in this directory. The file name should end with `.Tests.ps1`.
- **CIS**: Contains the tests that verifies the tenant's configuration conforms to the guidelines identified by the [Center for Internet Security (CIS) benchmark](https://www.cisecurity.org/benchmark/microsoft_365).
- **CISA**: Contains the tests that verifies the tenant’s configuration conforms to the policies described in the Secure Cloud Business Applications ([SCuBA](https://cisa.gov/scuba)) Security Configuration Baseline [documents](https://github.com/cisagov/ScubaGear/blob/main/baselines/README.md).
- **EIDSCA**: Contains tests based on the [Entra ID Security Config Analyzer](https://aura.onetapas.com/docs/tests/eidsca/).
- **Aura**: Contains the tests that are built by the Aura team with contributions from the community. To learn more about the tests see [Aura Tests](https://aura.onetapas.com/docs/tests/aura).

## Running Aura

To run the tests in this folder run the following PowerShell commands. To learn more see [aura.onetapas.com](https://aura.onetapas.com).

```powershell
Connect-Aura
Invoke-Aura
```

## Keeping your Aura tests up to date

The Aura team will add new tests over time. To get the latest updates, use the commands below to update this folder with the latest tests.

- Update the `Aura` PowerShell module to the latest version and load it.
- Change to the folder that has the tests.
- Run `Update-AuraTests`.

```powershell
Update-Module Aura -Force
Import-Module Aura
Update-AuraTests
```

## Customizing Severity Levels

### Customizing Severity Levels for Out of the Box Tests

You can customize the severity levels of the out of the box tests tests.

To do this create a file named `aura-config.json` in your `./Custom` folder.

Provide the severity levels for the tests you want to customize, using the format below.

The severity levels are:

- Critical
- High
- Medium
- Low
- Info

```json
{
    "TestSettings": [
        {
            "Id": "CIS.M365.1.1.1",
            "Severity": "High"
        }
    ]
}
```

### Defining severity levels for custom tests

You can define severity levels for your custom tests using the above approach (`aura-config.json`) or by using the `-Tag` parameter in the `Describe` or `It` block of your Pester tests.

The tag needs to be in the format of `Severity:<SeverityLevel>`.

E.g.

```powershell
Describe 'My Custom Test' {
    It 'Cus.1001: My custom test' -Tag 'Severity:High' {
        # Your test code here
    }
}
```

If a Severity level is defined in both the `aura-config.json` file and the test, the one in the `./Custom/aura-config.json` will take precedence.
