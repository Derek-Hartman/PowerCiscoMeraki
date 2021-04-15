<#
.SYNOPSIS
    Creates a New Meraki Network by coping another network

.Example
    New-MerakiNetwork -Name "Derek PowerShell Test" -TimeZone "US/Eastern" -NetworkID "NID"
    New-MerakiNetwork -$OrganizationID "OrgID" -ApiKey "key" -Name "Derek PowerShell Test" -TimeZone "US/Eastern" -NetworkID "NID"

.NOTES
    Modified by: Derek Hartman
    Date: 4/9/2021
#>

Function New-MerakiNetwork {
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
        [string[]]$OrganizationID,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter New Network Name")]
        [string[]]$Name,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter New Network Time Zone")]
        [string[]]$TimeZone,

        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            HelpMessage = "Enter New Network Id to Copy from")]
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
            "networks" = "https://api-mp.meraki.com/api/v1/organizations/$OrganizationID/networks"
        }
        #$Name = "Derek PowerShell Test"
        #$TimeZone = "US/Eastern"
        #$Type = "combined"

        $Body = @{"name" = "$Name"}
        $Body += @{"timeZone" = "$TimeZone"}
        #$Body += @{"tags" = @()}
        $Body += @{"notes" = ""}
        $Body += @{"productTypes" = @("appliance","switch","wireless" ) }
        $Body += @{"copyFromNetworkId" = "$NetworkID"}


        $postData = ConvertTo-Json $Body

        $networks = Invoke-RestMethod -Method POST -Uri $Uri.networks -Body $postData -Headers @{
            'X-Cisco-Meraki-API-Key' = "$ApiKey"
            'Accept'                 = "application/json"
            'Content-Type'           = 'application/json'            
        }

        Write-Output $networks
    }
}