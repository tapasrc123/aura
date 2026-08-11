# Script used to initialize the CISA Entra test docs

gci *.md|%{$x=$_.Name;"";$x;gc $x}|?{$_ -match "(?<cmdlet>Test-AuCisa.*.md)" -or $_ -match ".*(?<url>https.*baselines.*)\)"}|%{$Matches['control'];$Matches['cmdlet'];$Matches['url']}|clip
$x=@"
Test-AuCisaActivationNotification,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad78v1;https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad78v1
Test-AuCisaAppAdminConsent,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad53v1
Test-AuCisaAppGroupOwnerConsent,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad54v1
Test-AuCisaAppRegistration,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad51v1
Test-AuCisaAppUserConsent,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad52v1
Test-AuCisaAssignmentNotification,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad77v1
Test-AuCisaAuthenticatorContext,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad33v2
Test-AuCisaBlockHighRiskSignIn,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad23v1
Test-AuCisaBlockHighRiskUser,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad21v1
Test-AuCisaBlockLegacyAuth,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#1-legacy-authentication
Test-AuCisaCloudGlobalAdmin,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad73v1
Test-AuCisaGlobalAdminCount,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad71v1
Test-AuCisaGlobalAdminRatio,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad72v1
Test-AuCisaGuestInvitation,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad82v1
Test-AuCisaGuestUserAccess,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad81v1
Test-AuCisaManagedDevice,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad37v1
Test-AuCisaManagedDeviceRegistration,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad38v1
Test-AuCisaMethodsMigration,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad34v1
Test-AuCisaMfa,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad32v1
Test-AuCisaNotifyHighRisk,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad22v1
Test-AuCisaPasswordExpiration,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad61v1
Test-AuCisaPermanentRoleAssignment,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad74v1
Test-AuCisaPhishResistant,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad31v1
Test-AuCisaPrivilegedPhishResistant,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#highly-privileged-roles;https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad36v1
Test-AuCisaRequireActivationApproval,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad76v1
Test-AuCisaUnmanagedRoleAssignment,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad75v1
Test-AuCisaWeakFactor,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad35v1
"@
gci *.md|%{$x=$_.Name;"";$x;gc $x}|?{$_ -match "(?<cmdlet>Test-AuCisa.*.md)" -or $_ -match ".*(?<control>MS.AAD.\d.\d).*"}|%{$Matches['control'];$Matches['cmdlet'];$Matches['url']}|clip
$y=@"
Test-AuCisaActivationNotification,MS.AAD.7.8;MS.AAD.7.9
Test-AuCisaAppAdminConsent,MS.AAD.5.3
Test-AuCisaAppGroupOwnerConsent,MS.AAD.5.4
Test-AuCisaAppRegistration,MS.AAD.5.1
Test-AuCisaAppUserConsent,MS.AAD.5.2
Test-AuCisaAssignmentNotification,MS.AAD.7.7
Test-AuCisaAuthenticatorContext,MS.AAD.3.3
Test-AuCisaBlockHighRiskSignIn,MS.AAD.2.3
Test-AuCisaBlockHighRiskUser,MS.AAD.2.1
Test-AuCisaBlockLegacyAuth,MS.AAD.1.1
Test-AuCisaCloudGlobalAdmin,MS.AAD.7.3
Test-AuCisaGlobalAdminCount,MS.AAD.7.1
Test-AuCisaGlobalAdminRatio,MS.AAD.7.1;MS.AAD.7.1;MS.AAD.7.2
Test-AuCisaGuestInvitation,MS.AAD.8.2
Test-AuCisaGuestUserAccess,MS.AAD.8.1
Test-AuCisaManagedDevice,MS.AAD.3.7
Test-AuCisaManagedDeviceRegistration,MS.AAD.3.8
Test-AuCisaMethodsMigration,MS.AAD.3.4
Test-AuCisaMfa,MS.AAD.3.2
Test-AuCisaNotifyHighRisk,MS.AAD.2.2
Test-AuCisaPasswordExpiration,MS.AAD.6.1
Test-AuCisaPermanentRoleAssignment,MS.AAD.7.4
Test-AuCisaPhishResistant,MS.AAD.3.1
Test-AuCisaPrivilegedPhishResistant,MS.AAD.3.6
Test-AuCisaRequireActivationApproval,MS.AAD.7.6
Test-AuCisaUnmanagedRoleAssignment,MS.AAD.7.5
Test-AuCisaWeakFactor,MS.AAD.3.5
"@

$xs=$x|ConvertFrom-Csv -Header "cmdlet","link"
$ys=$y|ConvertFrom-Csv -Header "cmdlet","control"

$f=""
foreach($x in $xs){
    $f+="$($x.cmdlet),$(($ys|?{$_.cmdlet -eq $x.cmdlet}).control),$($x.link)`n"
}
$f|clip

$a=@"
Test-AuCisaActivationNotification,MS.AAD.7.8;MS.AAD.7.9,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad78v1;https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad78v1
Test-AuCisaAppAdminConsent,MS.AAD.5.3,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad53v1
Test-AuCisaAppGroupOwnerConsent,MS.AAD.5.4,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad54v1
Test-AuCisaAppRegistration,MS.AAD.5.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad51v1
Test-AuCisaAppUserConsent,MS.AAD.5.2,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad52v1
Test-AuCisaAssignmentNotification,MS.AAD.7.7,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad77v1
Test-AuCisaAuthenticatorContext,MS.AAD.3.3,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad33v2
Test-AuCisaBlockHighRiskSignIn,MS.AAD.2.3,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad23v1
Test-AuCisaBlockHighRiskUser,MS.AAD.2.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad21v1
Test-AuCisaBlockLegacyAuth,MS.AAD.1.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#1-legacy-authentication
Test-AuCisaCloudGlobalAdmin,MS.AAD.7.3,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad73v1
Test-AuCisaGlobalAdminCount,MS.AAD.7.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad71v1
Test-AuCisaGlobalAdminRatio,MS.AAD.7.1;MS.AAD.7.1;MS.AAD.7.2,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad72v1
Test-AuCisaGuestInvitation,MS.AAD.8.2,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad82v1
Test-AuCisaGuestUserAccess,MS.AAD.8.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad81v1
Test-AuCisaManagedDevice,MS.AAD.3.7,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad37v1
Test-AuCisaManagedDeviceRegistration,MS.AAD.3.8,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad38v1
Test-AuCisaMethodsMigration,MS.AAD.3.4,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad34v1
Test-AuCisaMfa,MS.AAD.3.2,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad32v1
Test-AuCisaNotifyHighRisk,MS.AAD.2.2,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad22v1
Test-AuCisaPasswordExpiration,MS.AAD.6.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad61v1
Test-AuCisaPermanentRoleAssignment,MS.AAD.7.4,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad74v1
Test-AuCisaPhishResistant,MS.AAD.3.1,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad31v1
Test-AuCisaPrivilegedPhishResistant,MS.AAD.3.6,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#highly-privileged-roles;https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad36v1
Test-AuCisaRequireActivationApproval,MS.AAD.7.6,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad76v1
Test-AuCisaUnmanagedRoleAssignment,MS.AAD.7.5,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad75v1
Test-AuCisaWeakFactor,MS.AAD.3.5,https://github.com/cisagov/ScubaGear/blob/main/PowerShell/ScubaGear/baselines/aad.md#msaad35v1
"@

$a=$a|ConvertFrom-Csv -Header "cmdlet","control","url"
$a | ForEach-Object { "* $($_.cmdlet) - [$($_.control)]($($_.url))" } | Set-Clipboard
