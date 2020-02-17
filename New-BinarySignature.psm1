Function script:Get-TimeStampServer {
[CmdletBinding()]
Param(
	[Parameter(HelpMessage="List of known good timestamp servers")]
	$TimeStampServers = @("http://ca.signfiles.com/tsa/get.aspx","http://timestamp.globalsign.com/scripts/timstamp.dll")
)
	$TimeStampHostnames = $TimeStampServers -Replace("^http:\/\/","") -Replace ("\/.*","") #Isolate hostnames for Test-Connetion
	
	For ($i = 0; $i -le 2; $i++) {
		Try {
			If ([bool](Test-NetConnection $TimeStampHostnames[$i] -Port 80 | Select-Object -ExpandProperty TcpTestSucceeded)) {
				Write-Verbose "$($TimeStampHostnames[$i]) selected"
				$TimeStampServer = $TimeStampServers[$i]
				Break #Once we find a valid server, stop looking.
			}
		}
		Catch {
			Write-Verbose "Could not connect to $($TimeStampHostnames[$i])"
		}
	}
	Return $TimeStampServer
} #End Get-TimeStampServer

Function script:New-CodeSigningCert {
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,HelpMessage="Certificate subject name")]
	[String]$Subject,
	
	[Parameter(Mandatory=$True,HelpMessage="Certificate e-mail address")]
	[string]$EMail,
	
	[Parameter(Mandatory=$True,HelpMessage="Certificate friendly name")]
	[string]$FriendlyName,
	
	[Parameter(Mandatory=$True,HelpMessage="Certificate PFX password for export")]
	[string]$PFXPassword,
	
	[Parameter(HelpMessage="Certificate export path")]
	$CertFilePath = $([Environment]::GetFolderPath("Desktop")),
	
	[Parameter(HelpMessage="Certificate e-mail address")]
	$SubjectFull = "CN=$Subject,E=$EMail",
	
	[Parameter(HelpMessage="Certificate validity in years")]
	[int]$CertValidYears = 5
)
$SecurePassword = ConvertTo-SecureString -String $PFXPassword -AsPlainText -Force

$CodeSigningCert = New-SelfSignedCertificate -Type CodeSigningCert -KeyUsage DigitalSignature -KeyAlgorithm RSA -CertStoreLocation "Cert:\CurrentUser\My" -Subject $SubjectFull -NotAfter $(Get-Date).AddYears($CertValidYears) -FriendlyName $FriendlyName
Export-PfxCertificate -Cert $CodeSigningCert -FilePath $CertFilePath\$FriendlyName.pfx -Password $SecurePassword

#Install cert in root store so it is trusted
Import-PfxCertificate -FilePath $CertFilePath\$FriendlyName.pfx -CertStoreLocation "Cert:\LocalMachine\Root\" -Password $SecurePassword
} #End New-CodeSigningCert
