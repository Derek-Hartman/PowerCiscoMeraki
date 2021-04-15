<#
.Synopsis
    Deleted the encrypted OrgID

.EXAMPLE
    Remove-MerakiOrgID

.NOTES
   Modified by: Derek Hartman
   Date: 11/11/2019

#>

function Remove-MerakiOrgID {
    Remove-ItemProperty -Path "HKCU:\Software\PowerCiscoMeraki" -Name "OrgID"    
}