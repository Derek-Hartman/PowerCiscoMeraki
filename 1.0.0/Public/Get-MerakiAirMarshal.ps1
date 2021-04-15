<#
.SYNOPSIS
    Outputs results from Air Marshal

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiAirMarshal {
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
            HelpMessage = "Enter your time span in seconds (e.g. 3600). Must be a maximum of one month in seconds.")]
        [Alias('TS')]
        [string[]]$TimeSpan

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
            "timespan" = "https://api.meraki.com/api/v1/networks/$NetworkID/wireless/airMarshal?timespan=$TimeSpan"
        }

        $timespaned = Invoke-RestMethod -Method GET -Uri $Uri.timespan -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }
        Write-Output $timespaned
    }
}