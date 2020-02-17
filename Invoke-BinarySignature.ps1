Function script:Get-TimeStampServer {
[CmdletBinding()]
Param(
	[Parameter(HelpMessage="List of known good timestamp servers")]
	$TimeStampServers = @("http://ca.signfiles.com/tsa/get.aspx","http://timestamp.globalsign.com/scripts/timstamp.dll")
)
	$TimeStampHostnames = $TimeStampServers -Replace("^http:\/\/","") -Replace ("\/.*","") #Isolate hostnames for Test-NetConnection
	$Count = ($TimeStampHostnames.Count - 1)
	For ($i = 0; $i -le $Count; $i++) {
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

Function New-BinarySignature {
[CmdletBinding()]
Param(
	[Parameter(HelpMessage="Specify the path to the file to be signed")]
	[ValidateScript({Test-Path $_ -PathType 'Leaf'})]$BinPath,
	
	[Parameter(HelpMessage="Specify the friendly name of the certificate to use for codesigning")]
	[string]$CertFriendlyName
)
$CodeSigningCert = Get-ChildItem Cert:\CurrentUser\My | Where-Object FriendlyName -like $CertFriendlyName
Set-AuthenticodeSignature -Certificate $CodeSigningCert -TimestampServer $TimeStampServer -HashAlgorithm SHA256 -FilePath $BinPath
}

Get-TimeStampServer
New-BinarySignature -BinPath "C:\Temp\Test-Signed.ps1" -CertFriendlyName "PSCodeSigningTest"
