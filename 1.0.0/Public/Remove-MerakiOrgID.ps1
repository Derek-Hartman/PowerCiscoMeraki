<#
.Synopsis
    Deleted the encrypted OrgID

.EXAMPLE
    Delete-MerakiOrgID

.NOTES
   Modified by: Derek Hartman
   Date: 11/11/2019

#>

function Delete-MerakiOrgID {
    Remove-ItemProperty -Path "HKCU:\Software\PowerCiscoMeraki" -Name "OrgID"    
}