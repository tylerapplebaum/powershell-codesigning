<#
.SYNOPSIS
    Creates a new self-signed code signing certificate
.DESCRIPTION
    Creates a new self-signed code signing certificate, exports the certificate as a PFX, and imports it into the root trust store.
.NOTES
    Author  :   Tyler Applebaum
    Created :   Feb 2020
#>

#Requires -RunAsAdministrator

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
	
	[Parameter(HelpMessage="Certificate validity in years")]
	[int]$CertValidYears
)

$MajorVersion = [System.Environment]::OSVersion.Version | Select-Object -ExpandProperty Major
If ($MajorVersion -lt 10) {
	Write-Error "Windows 10 / Server 2016 or better is required to use the New-SelfSignedCertificate cmdlet"
	Break
}

$SubjectFull = "CN=$Subject,E=$EMail"
$SecurePassword = ConvertTo-SecureString -String $PFXPassword -AsPlainText -Force

$DuplicateName = Get-ChildItem Cert:\CurrentUser\My | Where-Object FriendlyName -like $FriendlyName
If ($null -notlike $DuplicateName) {
	Write-Warning "An existing certificate exists with this friendly name." -WarningAction Inquire
}

#Generate certificate
$CodeSigningCert = New-SelfSignedCertificate -Type CodeSigningCert -KeyUsage DigitalSignature -KeyAlgorithm RSA -CertStoreLocation "Cert:\CurrentUser\My" -Subject $SubjectFull -NotAfter $(Get-Date).AddYears($CertValidYears) -FriendlyName $FriendlyName

#Export certificate
Export-PfxCertificate -Cert $CodeSigningCert -FilePath $CertFilePath\$FriendlyName.pfx -Password $SecurePassword

#Install cert in root store so it is trusted - Requires RunAsAdministrator in script usage
Import-PfxCertificate -FilePath $CertFilePath\$FriendlyName.pfx -CertStoreLocation "Cert:\LocalMachine\Root\" -Password $SecurePassword
} #End New-CodeSigningCert
