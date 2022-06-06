# powershell-codesigning

## New-CodeSigningCert.ps1

Note: This script uses the `New-SelfSignedCertificate` cmdlet, which is only available in Windows 10 / Server 2016 and newer. The cmdlet itself is present in older versions, but it does not have the same functionality.

[2012R2 Docs](http://web.archive.org/web/20180220083248/https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=winserver2012r2-ps) 

[2016 Docs](http://web.archive.org/web/20200215095145/https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps)

Usage:

```powershell
Import-Module .\New-CodeSigningCert.psm1
New-CodeSigningCert -Subject "Your Own Code Signing Cert" -EMail "e@mail.com" -PFXPassword "1234" -FriendlyName "PSCodeSigningTest" -CertValidYears 5
 ```

`New-CodeSigningCert` requires an Adminstrator shell in order to import the certificate into the LocalMachine root store.

## Invoke-BinarySignature.psm1

Usage:

Tab complete the `-CertFriendlyName` parameter to list all code signing certificates in your user store.

```powershell
Import-Module Invoke-BinarySignature.psm1
New-BinarySignature -CertFriendlyName "PSCodeSigningTest" -BinPath "C:\Temp\Test-Signed.ps1"
```

## Potential use cases

### RDP File Signing
Use the code signing certificate generated with `New-CodeSigningCert.ps1` to sign .rdp files in order to avoid the certificate warning. 
- Create the .rdp file with all of the settings you'll need
- Generate a certificate using `New-CodeSigningCert`
- Get the thumbprint of the certificate you'll use to sign the .rdp file with `Get-ChildItem -Path Cert:CurrentUser\My`
- Run `rdpsign.exe /sha1 <thumbprint> C:\Path\To\workstation.rdp`
- Configure group policy to trust the certificate
	- `Import-Module .\Set-RDPTrustedPublishers.psm1`
	- `Set-RDPTrustedPublishers -SHA1Thumb <thumbprint> -Verbose`
	- As an alternative, you can manually configure the GPO if desired. Reference: https://blog.superautomation.co.uk/2020/10/rdp-file-signing.html
