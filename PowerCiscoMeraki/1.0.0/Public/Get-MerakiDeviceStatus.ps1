<#
.SYNOPSIS
    List Devices status within Meraki

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiDeviceStatus {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $False,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your API Key.")]
        [Alias('API')]
        [string[]]$ApiKey,

        [Parameter(Mandatory = $False,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your Organization ID.")]
        [Alias('OrgID')]
        [string[]]$OrganizationID

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

    If ([string]::IsNullOrEmpty($key.OrgID)) {
    }
    Else {
        $securestring = convertto-securestring -string ($key.OrgID)
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring)
        $ak = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        $OrganizationID = $ak
    }

    If ([string]::IsNullOrEmpty($OrganizationID)) {
        Write-Host "-OrganizationID needs to be given or set running Set-MerakiOrgID function" -ForegroundColor Yellow -BackgroundColor Red
    }
    Else {

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        $Uri = @{
            "deviceStatuses" = "https://api.meraki.com/api/v0/organizations/$OrganizationID/deviceStatuses"
        }

        $deviceStatuses = Invoke-RestMethod -Method GET -Uri $Uri.deviceStatuses -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $device in $deviceStatuses ) {
            $item = $device | Select-Object -Property *
            $DeviceProperties = @{
                lanIp          = $item.lanIp
                mac            = $item.mac
                name           = $item.name
                networkId      = $item.networkId
                publicIp       = $item.publicIp
                serial         = $item.serial
                status         = $item.status
                lastReportedAt = $item.lastReportedAt
            }
            $obj = New-Object -TypeName PSObject -Property $DeviceProperties
            Write-Output $obj
        }
    }
}