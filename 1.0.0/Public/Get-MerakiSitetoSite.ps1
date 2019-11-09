<#
.SYNOPSIS
    List settings for site to site VPN

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiSitetoSite {
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
            "siteToSiteVpn" = "https://api.meraki.com/api/v0/networks/$NetworkID/siteToSiteVpn"
        }

        $siteToSiteVpn = Invoke-RestMethod -Method GET -Uri $Uri.siteToSiteVpn -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $siteToSiteVpn ) {
            $Settings = $item | Select-Object -Property *
            $siteToSiteVpnProperties = @{
                mode    = $Settings.mode
                hubs    = $Settings.hubs
                subnets = $Settings.subnets
            }
            $obj = New-Object -TypeName PSObject -Property $siteToSiteVpnProperties
            Write-Output $obj
        }
    }
}