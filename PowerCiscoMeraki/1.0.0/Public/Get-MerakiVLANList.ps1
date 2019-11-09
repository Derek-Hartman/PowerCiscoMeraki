<#
.SYNOPSIS
    List vlans for a network

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiVLANList {
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
            "vlans" = "https://api.meraki.com/api/v0/networks/$NetworkID/vlans"
        }

        $vlans = Invoke-RestMethod -Method GET -Uri $Uri.vlans -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $vlans ) {
            $Settings = $item | Select-Object -Property *
            $vlansProperties = @{
                id                     = $Settings.id
                networkId              = $Settings.networkId
                name                   = $Settings.name
                applianceIp            = $Settings.applianceIp
                subnet                 = $Settings.subnet
                fixedIpAssignments     = $Settings.fixedIpAssignments
                reservedIpRanges       = $Settings.reservedIpRanges 
                dnsNameservers         = $Settings.dnsNameservers
                dhcpHandling           = $Settings.dhcpHandling
                dhcpLeaseTime          = $Settings.dhcpLeaseTime
                dhcpBootOptionsEnabled = $Settings.dhcpBootOptionsEnabled
                dhcpOptions            = $Settings.dhcpOptions
            }
            $obj = New-Object -TypeName PSObject -Property $vlansProperties
            Write-Output $obj
        }
    }
}