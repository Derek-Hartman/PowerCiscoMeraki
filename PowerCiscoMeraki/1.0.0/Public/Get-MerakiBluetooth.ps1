<#
.SYNOPSIS
    Provides details for Bluetooth settings configured on the Meraki Devices.

.NOTES
    Modified by: Derek Hartman
    Date: 10/31/2019
#>

Function Get-MerakiBluetooth {
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
            "bluetoothSettings" = "https://api.meraki.com/api/v0/networks/$NetworkID/bluetoothSettings"
        }

        $bluetoothSettings = Invoke-RestMethod -Method GET -Uri $Uri.bluetoothSettings -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }

        foreach ( $item in $bluetoothSettings ) {
            $Settings = $item | Select-Object -Property *
            $bluetoothSettingsProperties = @{
                scanningEnabled          = $Settings.scanningEnabled
                advertisingEnabled       = $Settings.advertisingEnabled
                uuid                     = $Settings.uuid
                majorMinorAssignmentMode = $Settings.majorMinorAssignmentMode
                major                    = $Settings.major
                minor                    = $Settings.minor
                type                     = $Settings.type
            }          
            $obj = New-Object -TypeName PSObject -Property $bluetoothSettingsProperties
            Write-Output $obj
        }
    }
}