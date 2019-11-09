<#
.Synopsis
    Sets the OrgID for the current user in registry

.EXAMPLE
    Set-MerakiOrgID -OrgID "OrgID"

.NOTES
   Modified by: Derek Hartman
   Date: 10/31/2019

#>

function Set-MerakiOrgID {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$OrgID,
	
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$RegistryKeyPath = "HKCU:\Software\PowerCiscoMeraki"
	)

	function encrypt([string]$TextToEncrypt) {
		$secure = ConvertTo-SecureString $TextToEncrypt -AsPlainText -Force
		$encrypted = $secure | ConvertFrom-SecureString
		return $encrypted
	}
		
	if (-not (Test-Path -Path $RegistryKeyPath)) {
		New-Item -Path ($RegistryKeyPath | Split-Path -Parent) -Name ($RegistryKeyPath | Split-Path -Leaf) | Out-Null
	}
	
	$values = 'OrgID'
	foreach ($val in $values) {
		if ((Get-Item $RegistryKeyPath).GetValue($val)) {
			Write-Verbose "'$RegistryKeyPath\$val' already exists. Skipping."
		} else {
			Write-Verbose "Creating $RegistryKeyPath\$val"
			New-ItemProperty $RegistryKeyPath -Name $val -Value $(encrypt $((Get-Variable $val).Value)) -Force | Out-Null
		}
	}
}