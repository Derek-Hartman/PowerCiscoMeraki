<#
.Synopsis
    list organizations in Meraki

.EXAMPLE
    Get-MerakiOrganization

.EXAMPLE
    Get-MerakiOrganization -ApiKey "ApiKey"

.NOTES
   Modified by: Derek Hartman
   Date: 10/31/2019

#>

Function Get-MerakiOrganization {
	[CmdletBinding()]

	param(
		[Parameter(Mandatory = $False,
			ValueFromPipeline = $True,
			HelpMessage = "Enter your API Key.")]
		[Alias('API')]
		[string[]]$ApiKey
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
		    "organization" = 'https://api.meraki.com/api/v0/organizations'
	    }

	    $Organizations = Invoke-RestMethod -Method GET -Uri $Uri.organization -Headers @{
		    'X-Cisco-Meraki-API-Key' = "$ApiKey"
		    'Content-Type'           = 'application/json'
	    }

	    foreach ( $Organization in $Organizations ) {
		    $Org = $Organization | Select-Object -Property *
		    $OrgProperties = @{
			    ID       = $Org.id
			    Name     = $Org.name
			    SAMLUrl  = $Org.samlConsumerUrl
			    SAMLUrls = $Org.samlConsumerUrls
		    }
	        $obj = New-Object -TypeName PSObject -Property $OrgProperties
	        Write-Output $obj
        }
    }
}