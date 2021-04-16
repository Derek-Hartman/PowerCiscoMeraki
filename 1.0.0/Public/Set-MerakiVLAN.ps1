<#
.SYNOPSIS
    Add a VLAN 

.Example
    Set-MerakiVLAN -NetworkID "NID" -ID "1234" -Name "My VLAN" -Subnet "192.168.1.0/24" -ApplianceIP "192.168.1.2" -GroupPolicyID "101"
    Set-MerakiVLAN -ApiKey "key" -NetworkID "NID" -ID "1234" -Name "My VLAN" -Subnet "192.168.1.0/24" -ApplianceIP "192.168.1.2" -GroupPolicyID "101"

.NOTES
    Modified by: Derek Hartman
    Date: 4/16/2021
#>

Function Set-MerakiVLAN {
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
        [string[]]$ID,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your VLAN Name.")]
        [string[]]$Name,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your VLAN Subnet.")]
        [string[]]$Subnet,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your VLAN Appliance IP.")]
        [string[]]$ApplianceIP,

        [Parameter(Mandatory = $False,
            ValueFromPipeline = $True,
            HelpMessage = "Enter your VLAN GroupPolicyID.")]
        [string[]]$GroupPolicyID
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
            "vlans" = "https://api.meraki.com/api/v1/networks/$NetworkID/appliance/vlans"
        }
        $NewVlan = New-Object PSObject
        $NewVlan | Add-Member -MemberType NoteProperty -Name "id" -Value "$ID"
        $NewVlan | Add-Member -MemberType NoteProperty -Name "name" -Value "$Name"
        $NewVlan | Add-Member -MemberType NoteProperty -Name "subnet" -Value "$Subnet"
        $NewVlan | Add-Member -MemberType NoteProperty -Name "applianceIp" -Value "$ApplianceIP"
        $NewVlan | Add-Member -MemberType NoteProperty -Name "groupPolicyId" -Value "$GroupPolicyID"

        $JSON = ConvertTo-Json $NewVlan
        $JSON

        $Rest = Invoke-RestMethod -Method POST -Uri $Uri.vlans -Body $JSON -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Content-Type'           = 'application/json'
        }
        Write-Output $Rest
    }
}