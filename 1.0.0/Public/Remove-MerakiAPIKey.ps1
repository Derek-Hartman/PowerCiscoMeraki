<#
.Synopsis
    Deleted the encrypted Key

.EXAMPLE
    Remove-MerakiAPIKey

.NOTES
   Modified by: Derek Hartman
   Date: 11/11/2019

#>

function Remove-MerakiAPIKey {
    Remove-ItemProperty -Path "HKCU:\Software\PowerCiscoMeraki" -Name "APIKey"    
}