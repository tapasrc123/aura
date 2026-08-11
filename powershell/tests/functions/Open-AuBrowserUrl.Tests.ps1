BeforeAll {
    Import-Module "$PSScriptRoot/../../Aura.psd1" -Force
}

Describe 'Open-AuBrowserUrl' {
    Context 'URL validation' {
        It 'Returns false for whitespace input' {
            InModuleScope Aura {
                Open-AuBrowserUrl -Uri '   ' | Should -BeFalse
            }
        }

        It 'Rejects non-HTTP(S) and non-absolute URLs before launching' -TestCases @(
            @{ Uri = 'file:///tmp/aura-open-browser-url-test' }
            @{ Uri = '/tmp/aura-open-browser-url-test' }
            @{ Uri = 'C:\Windows\notepad.exe' }
            @{ Uri = './relative/path' }
            @{ Uri = 'mailto:test@example.com' }
            @{ Uri = 'javascript:alert(1)' }
        ) {
            param($Uri)

            InModuleScope Aura -Parameters @{ TestUri = $Uri } {
                Open-AuBrowserUrl -Uri $TestUri | Should -BeFalse
            }
        }
    }
}
