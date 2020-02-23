# powershell-codesigning
 
## Invoke-BinarySignature.psm1

Usage:

Tab complete the `-CertFriendlyName` parameter to list all code signing certificates in your user store.

```powershell
Import-Module Invoke-BinarySignature.psm1
New-BinarySignature -CertFriendlyName "PSCodeSigningTest" -BinPath "C:\Temp\Test-Signed.ps1"
```
