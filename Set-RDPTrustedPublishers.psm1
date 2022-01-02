Function Set-RDPTrustedPublishers {
[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(HelpMessage="Group policy path for RDP trusted publishers cert thumbprint")]
	[ValidateNotNull()]
	[String]$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services',

	[Parameter(HelpMessage="Specify the registry key name for the MakeMKV registration key")]
	[ValidateNotNull()]
	[String]$KeyName = 'TrustedCertThumbprints',

	[Parameter(HelpMessage="Specify the SHA1 certificate thumbprint of the RDP signer")]
	[ValidateNotNull()]
	[String]$SHA1Thumb
)
$FunctionName = $MyInvocation.InvocationName
$RegistryKeyValue = Get-Item -LiteralPath $RegistryPath | Select-Object -ExpandProperty Property
	If ($KeyName -in $RegistryKeyValue) { # GPO enabled 
		$ExistingData = Get-ItemProperty -Path $RegistryPath -Name $KeyName | Select-Object -ExpandProperty $KeyName
		If ($ExistingData.Length -eq 0) { # Without existing thumbprint
			Write-Verbose "${FunctionName}: Existing policy configured, but empty; adding $SHA1Thumb"
			Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $SHA1Thumb | Out-Null
		}
		Else { # With existing thumbprint
			Write-Verbose "${FunctionName}: Existing policy configured, appending $SHA1Thumb"
			$NewData = -join($ExistingData,",",$SHA1Thumb)
			Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $NewData | Out-Null
		}
	}
	Else { # GPO not yet configured
		Write-Verbose "${FunctionName}: Existing policy not configured, creating key $KeyName with value: $SHA1Thumb"
		New-ItemProperty -Path $RegistryPath -Name $KeyName -Value $SHA1Thumb | Out-Null
	}
}

Export-ModuleMember Set-RDPTrustedPublishers