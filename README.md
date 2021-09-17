# powershell-codesigning

## New-CodeSigningCert.ps1

Note: This script uses the `New-SelfSignedCertificate` cmdlet, which is only available in Windows 10 / Server 2016 and newer. The cmdlet itself is present in older versions, but it does not have the same functionality.

[2012R2 Docs](http://web.archive.org/web/20180220083248/https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=winserver2012r2-ps) 

[2016 Docs](http://web.archive.org/web/20200215095145/https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps)

Usage:

```powershell
New-CodeSigningCert -Subject "Your Own Code Signing Cert" -EMail "e@mail.com" -PFXPassword "1234" -FriendlyName "PSCodeSigningTest" -CertValidYears 5
 ```
 
## Invoke-BinarySignature.psm1

Usage:

Tab complete the `-CertFriendlyName` parameter to list all code signing certificates in your user store.

```powershell
Import-Module Invoke-BinarySignature.psm1
New-BinarySignature -CertFriendlyName "PSCodeSigningTest" -BinPath "C:\Temp\Test-Signed.ps1"
```
