Describe 'Get-AuRegistrableDomain' {
    It 'returns the registrable domain for standard public suffixes' {
        Get-AuRegistrableDomain -DomainName 'sub.example.co.uk' | Should -Be 'example.co.uk'
    }

    It 'handles wildcard public suffix rules' {
        Get-AuRegistrableDomain -DomainName 'foo.bar.compute.amazonaws.com' | Should -Be 'foo.bar.compute.amazonaws.com'
    }

    It 'handles wildcard exception rules' {
        Get-AuRegistrableDomain -DomainName 'a.city.kawasaki.jp' | Should -Be 'city.kawasaki.jp'
    }

    It 'returns the input when the domain is itself the registrable unit under a wildcard rule' {
        Get-AuRegistrableDomain -DomainName 'foo.sch.uk' | Should -Be 'foo.sch.uk'
    }
}
