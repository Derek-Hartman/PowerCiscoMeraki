<#
.Synopsis
    Access policy for a specific network ID.

.EXAMPLE
    Get-MerakiNetworks -NetworkID NetIDGoesHere

.EXAMPLE
    Get-MerakiNetworks -ApiKey APIKeyGoesHere -NetworkID NetIDGoesHere

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019

#>

Function Get-MerakiAccessPolicy {
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
            "accessPolicies" = "https://api.meraki.com/api/v0/networks/$NetworkID/accessPolicies"
        }

        $accessPolicies = Invoke-RestMethod -Method GET -Uri $Uri.accessPolicies -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $accessPolicies ) {
            $Settings = $item | Select-Object -Property *
            $accessPoliciesProperties = @{
                number        = $Settings.number
                name          = $Settings.name
                accessType    = $Settings.accessType
                guestVlan     = $Settings.guestVlan
                radiusServers = $Settings.radiusServers
            }
            $obj = New-Object -TypeName PSObject -Property $accessPoliciesProperties
            Write-Output $obj
        }
    }
}