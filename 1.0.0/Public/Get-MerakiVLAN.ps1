<#
.SYNOPSIS
    List specific vlan details for specific vlan in network

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiVLAN {
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
            HelpMessage = "Enter your VLAN ID.")]
        [Alias('vID')]
        [string[]]$vlanID

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
            "vlans" = "https://api.meraki.com/api/v0/networks/$NetworkID/vlans/$vlanID"
        }

        $vlans = Invoke-RestMethod -Method GET -Uri $Uri.vlans -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $vlans ) {
            $Settings = $item | Select-Object -Property *
            $vlansProperties = @{
                id                 = $Settings.id
                networkId          = $Settings.networkId
                name               = $Settings.name
                applianceIp        = $Settings.applianceIp
                subnet             = $Settings.subnet
                fixedIpAssignments = $Settings.fixedIpAssignments
                reservedIpRanges   = $Settings.reservedIpRanges
                dnsNameservers     = $Settings.dnsNameservers
                dhcpHandling       = $Settings.dhcpHandling
            }
            $obj = New-Object -TypeName PSObject -Property $vlansProperties
            Write-Output $obj
        }
    }
}