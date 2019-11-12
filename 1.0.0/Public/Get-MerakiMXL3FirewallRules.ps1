<#
.SYNOPSIS
    Returns MX L3 firewall Rules for a Network

.Example
    Get-MerakiMXL3FirewallRules -NetworkID "NID"
    Get-MerakiMXL3FirewallRules -ApiKey "key" -NetworkID "NID"

.NOTES
    Modified by: Derek Hartman
    Date: 11/12/2019
#>

Function Get-MerakiMXL3FirewallRules {
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
            "l3FirewallRules" = "https://api.meraki.com/api/v0/networks/$NetworkID/l3FirewallRules"
        }

        $Rest = Invoke-RestMethod -Method GET -Uri $Uri.l3FirewallRules -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $Rest ) {
            $Settings = $item | Select-Object -Property *
            $l3FirewallRulesProperties = @{
                comment       = $Settings.comment
                policy        = $Settings.policy
                protocol      = $Settings.protocol
                srcPort       = $Settings.srcPort
                srcCidr       = $Settings.srcCidr
                destCidr      = $Settings.destCidr
                syslogEnabled = $Settings.syslogEnabled
            }
            $obj = New-Object -TypeName PSObject -Property $l3FirewallRulesProperties
            Write-Output $obj
        }
    }
}