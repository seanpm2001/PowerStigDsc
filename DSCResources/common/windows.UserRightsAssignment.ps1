# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
$rules = Get-RuleClassData -StigData $StigData -Name UserRightRule

$domainGroupTranslation = @{
    'Administrators'            = 'Builtin\Administrators'
    'Auditors'                  = '{0}\auditors'
    'Authenticated Users'       = 'Authenticated Users'
    'Domain Admins'             = '{0}\Domain Admins'
    'Guests'                    = 'Guests'
    'Local Service'             = 'NT Authority\Local Service'
    'Network Service'           = 'NT Authority\Network Service'
    'NT Service\WdiServiceHost' = 'NT Service\WdiServiceHost'
    'NULL'                      = ''
    'Security'                  = '{0}\security'
    'Service'                   = 'Service'
    'Window Manager\Window Manager Group' = 'Window Manager\Window Manager Group'
}

$forestGroupTranslation = @{
    'Enterprise Admins'         = '{0}\Enterprise Admins'
    'Schema Admins'             = '{0}\Schema Admins'
}

# This requires a local forest and/or domain name to be injected to ensure a valid account name.
$domainName = PowerStig\Get-DomainName -DomainName $DomainName -Format NetbiosName
$forestName = PowerStig\Get-DomainName -ForestName $ForestName -Format NetbiosName

#endregion Header
#region Resource
Foreach ( $rule in $rules )
{
    Write-Verbose $rule
    $identitySplit = $rule.Identity -split ","
    [System.Collections.ArrayList]  $IdentityList = @()

    foreach ($identity in $identitySplit)
    {
        if ($domainGroupTranslation.Contains($identity))
        {
            [void] $IdentityList.Add($domainGroupTranslation.$identity -f $domainName )
        }
        elseif ($forestGroupTranslation.Contains($identity))
        {
            [void] $IdentityList.Add($forestGroupTranslation.$identity -f $forestName )
        }
    }

    UserRightsAssignment (Get-ResourceTitle -Rule $rule)
    {
        Policy   = ($rule.DisplayName -replace " ", "_")
        Identity = $IdentityList
    }
}
#endregion Resource