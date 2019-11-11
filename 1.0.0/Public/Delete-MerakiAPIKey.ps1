<#
.Synopsis
    Deleted the encrypted Key

.EXAMPLE
    Delete-MerakiAPIKey

.NOTES
   Modified by: Derek Hartman
   Date: 11/11/2019

#>

function Delete-MerakiAPIKey {
    Remove-ItemProperty -Path "HKCU:\Software\PowerCiscoMeraki" -Name "APIKey"    
}