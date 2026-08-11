Describe 'Test-AuCaMfaForGuest' {
  BeforeAll {
    Import-Module $PSScriptRoot/../../Aura.psd1 -Force
    Mock -ModuleName Aura Get-AuLicenseInformation { return "P1" }

    function Get-AllUserMfaPolicyNoExcludeGuest {
      $policyJson = @"
[
  {
    "state": "enabled",
    "conditions": {
      "clientAppTypes": [
        "all"
      ],
      "applications": {
        "includeApplications": [
          "All"
        ]
      },
      "users": {
        "includeUsers": [
          "All"
        ]
      }
    },
    "grantControls": {
      "operator": "OR",
      "builtInControls": [
        "mfa"
      ]
    }
  }
]
"@
      return $policyJson | ConvertFrom-Json
    }

    function Get-AllUserMfaPolicyExcludeGuest {
      $policyJson = @"
[
  {
    "state": "enabled",
    "conditions": {
      "clientAppTypes": [
        "all"
      ],
      "applications": {
        "includeApplications": [
          "All"
        ]
      },
      "users": {
        "excludeUsers": [
          "513f3db2-044c-41be-af14-431bf88a2b3e"
        ],
        "includeGuestsOrExternalUsers": {
          "guestOrExternalUserTypes": "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider",
          "externalTenants": {
            "@odata.type": "#microsoft.graph.conditionalAccessAllExternalTenants",
            "membershipKind": "all"
          }
        },
        "excludeGuestsOrExternalUsers": {
          "guestOrExternalUserTypes": "b2bCollaborationGuest",
          "externalTenants": {
            "@odata.type": "#microsoft.graph.conditionalAccessAllExternalTenants",
            "membershipKind": "all"
          }
        }
      }
    },
    "grantControls": {
      "operator": "OR",
      "builtInControls": [
        "mfa"
      ]
    }
  }
]
"@
      return $policyJson | ConvertFrom-Json
    }


    function Get-GuestMfaPolicyNoExcludeGuest {
      $policyJson = @"
[
  {
    "state": "enabled",
    "conditions": {
      "clientAppTypes": [
        "all"
      ],
      "applications": {
        "includeApplications": [
          "All"
        ]
      },
      "users": {
        "includeGuestsOrExternalUsers": {
          "guestOrExternalUserTypes": "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider",
          "externalTenants": {
            "@odata.type": "#microsoft.graph.conditionalAccessAllExternalTenants",
            "membershipKind": "all"
          }
        },
        "excludeGuestsOrExternalUsers": null
      }
    },
    "grantControls": {
      "operator": "OR",
      "builtInControls": [
        "mfa"
      ]
    }
  }
]
"@
      return $policyJson | ConvertFrom-Json
    }

    function Get-GuestMfaPolicyExcludeGuest {
      $policyJson = @"
[
  {
    "state": "enabled",
    "conditions": {
      "clientAppTypes": [
        "all"
      ],
      "applications": {
        "includeApplications": [
          "All"
        ]
      },
      "users": {
        "includeGuestsOrExternalUsers": {
          "guestOrExternalUserTypes": "internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider",
          "externalTenants": {
            "@odata.type": "#microsoft.graph.conditionalAccessAllExternalTenants",
            "membershipKind": "all"
          }
        },
        "excludeGuestsOrExternalUsers": {
          "guestOrExternalUserTypes": "b2bCollaborationGuest",
          "externalTenants": {
            "@odata.type": "#microsoft.graph.conditionalAccessAllExternalTenants",
            "membershipKind": "all"
          }
        }
      }
    },
    "grantControls": {
      "operator": "OR",
      "builtInControls": [
        "mfa"
      ]
    }
  }
]
"@
      return $policyJson | ConvertFrom-Json
    }
  }

  Context "CA: MFA for Guest" {

    It 'MFA for All users should pass even if not targeting guests' {
      $policy = Get-AllUserMfaPolicyNoExcludeGuest

      Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

      Test-AuCaMfaForGuest | Should -BeTrue
    }

    It 'MFA for All users that excludes any guest type should fail' {
      $policy = Get-AllUserMfaPolicyExcludeGuest

      Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

      Test-AuCaMfaForGuest | Should -BeFalse
    }

    It 'MFA for Guests should pass' {
      $policy = Get-GuestMfaPolicyNoExcludeGuest

      Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

      Test-AuCaMfaForGuest | Should -BeTrue
    }

    It 'MFA for Guests that excludes any guest type should fail' {
      $policy = Get-GuestMfaPolicyExcludeGuest

      Mock -ModuleName Aura Get-AuConditionalAccessPolicy { return $policy }

      Test-AuCaMfaForGuest | Should -BeFalse
    }

  }
}
