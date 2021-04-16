<#
.SYNOPSIS
    Update the L3 firewall rules of an MX network

.Example
    Set-MerakiMXL3FirewallRules -NetworkID "NID"
    Set-MerakiMXL3FirewallRules -ApiKey "key" -NetworkID "NID"

.NOTES
    !!!!!Not Ready will wipe out all run except 1!!!!
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
            "l3FirewallRules" = "https://api.meraki.com/api/v1/networks/$NetworkID/appliance/firewall/l3FirewallRules"
        }
        $RuleConfig = @{"comment" = "PS Rule Test2"}
        $RuleConfig += @{"policy" = "allow"}
        $RuleConfig += @{"protocol" = "tcp"}
        $RuleConfig += @{"destPort" = "447"}
        $RuleConfig += @{"destCidr" = "192.168.1.0/24"}
        $RuleConfig += @{"srcPort" = "Any"}
        $RuleConfig += @{"srcCidr" = "Any"}
        $RuleConfig += @{"syslogEnabled" = "false"}
        $Body = @{"rules" = @($RuleConfig)}


        $postData = ConvertTo-Json $Body

        $Rest = Invoke-RestMethod -Method PUT -Uri $Uri.l3FirewallRules -Body $postData -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }
        Write-Output $Rest.rules
    }
}