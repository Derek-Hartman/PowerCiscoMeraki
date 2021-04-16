<#
.SYNOPSIS
    Update the L3 firewall rules of an MX network.
    Requires passing a json with all rules to apply. 

.Example
    Set-MerakiMXL3FirewallRules -NetworkID "NID" -Json $JSON
    Set-MerakiMXL3FirewallRules -ApiKey "key" -NetworkID "NID" -Json $JSON

.NOTES
    Modified by: Derek Hartman
    Date: 11/12/2019
#>

Function Set-MerakiMXL3FirewallRules {
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
        [string[]]$NetworkID,

         [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your Rules JSON.")]
        [string[]]$JSON
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
            "l3FirewallRules" = "https://api.meraki.com/api/v1/networks/$NetworkID/appliance/firewall/l3FirewallRules"
        }

        $Rest = Invoke-RestMethod -Method PUT -Uri $Uri.l3FirewallRules -Body $JSON -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }
        Write-Output $Rest.rules
    }
}