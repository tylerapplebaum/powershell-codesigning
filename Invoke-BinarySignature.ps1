#Requires -RunAsAdministrator
[CmdletBinding()]
Param(
	[Parameter(HelpMessage="Specify the path to the file to be signed")]
	[ValidateScript({Test-Path $_ -PathType 'Leaf'})]$BinPath
)

Import-Module "C:\Users\Dad\Documents\GitHub\Utilities\New-BinarySignature.psm1"
Get-TimeStampServer
New-CodeSigningCert -Subject "Tyler Applebaum Code Signing Cert" -EMail "tylerapplebaum@gmail.com" -PFXPassword "1234" -FriendlyName "PSCodeSigningTest" -CertValidYears 5
$CodeSigningCert = Get-ChildItem Cert:\CurrentUser\My | Where-Object FriendlyName -like $FriendlyName

Set-AuthenticodeSignature -FilePath $BinPath -Certificate $CodeSigningCert -TimestampServer $TimeStampServer -HashAlgorithm SHA256
#Set-AuthenticodeSignature -FilePath $BinPath -Certificate $CodeSigningCert[0] -TimestampServer $TimeStampServer -HashAlgorithm SHA256

Get-AuthenticodeSignature -FilePath $BinPath