﻿<#
.SYNOPSIS
    Return the inbound firewall rules for an MX network

.Example
    Get-MerakiMXL3FirewallRules -NetworkID "NID"
    Get-MerakiMXL3FirewallRules -ApiKey "key" -NetworkID "NID"

.NOTES
    Modified by: Derek Hartman
    Date: 4/15/2021
#>

Function Get-MerakiMXInboundFirewallRules {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $False,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your API Key.")]
        [Alias('API')]
        [string[]]$ApiKey,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your Network ID.")]
        [Alias('NetID')]
        [string[]]$NetworkID
    )

    $RegistryKeyPath = "HKCU:\Software\PowerCiscoMeraki"
    $Key = Get-ItemProperty -Path $RegistryKeyPath

    If ([string]::IsNullOrEmpty($key.APIKey)) {
    }
    Else {
        $securestring = convertto-securestring -string ($key.APIKey)
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring)
        $ak = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        $ApiKey = $ak
    }

    If ([string]::IsNullOrEmpty($ApiKey)) {
        Write-Host "-APIKey needs to be given or set running Set-MerakiAPIKey function" -ForegroundColor Yellow -BackgroundColor Red
    }
    Else {

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $Uri = @{
            "inboundFirewallRules" = "https://api.meraki.com/api/v1/networks/$NetworkID/appliance/firewall/inboundFirewallRules"
        }

        $Rest = Invoke-RestMethod -Method GET -Uri $Uri.inboundFirewallRules -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }
        Write-Output $Rest.rules
    }
}