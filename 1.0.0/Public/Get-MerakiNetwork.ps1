<#
.SYNOPSIS
    Outputs info on specific network

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiNetwork {
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
            "networks" = "https://api.meraki.com/api/v0/networks/$NetworkID"
        }

        $networks = Invoke-RestMethod -Method GET -Uri $Uri.networks -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $networks ) {
            $Settings = $item | Select-Object -Property *
            $networksProperties = @{
                disableMyMerakiCom      = $Settings.disableMyMerakiCom
                id                      = $Settings.id
                name                    = $Settings.name
                organizationId          = $Settings.organizationId
                tags                    = $Settings.tags
                timeZone                = $Settings.timeZone
                type                    = $Settings.type
                disableRemoteStatusPage = $Settings.disableRemoteStatusPage
                productTypes            = $Settings.productTypes
            }
            $obj = New-Object -TypeName PSObject -Property $networksProperties
            Write-Output $obj
        }
    }
}