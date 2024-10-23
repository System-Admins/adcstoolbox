# SystemAdmins.AdcsToolbox

PowerShell module "SystemAdmins.AdcsToolbox" for Active Directory Certificate Services (ADCS).

## Table of Contents
- [Introduction](#introduction)
- [Pre-requisuites](#pre-requisuites)
- [Installation](#installation)
- [Usage](#usage)
- [Cmdlets](#cmdlets)
  - [Backup-CA](#Backup-CA)
  - [Export-CACertificate](#Export-CACertificate)
  - [Get-CACertificate](#Get-CACertificate)
  - [Get-CACommonName](#Get-CACommonName)
  - [Get-CACrlConfig](#Get-CACrlConfig)
  - [Get-CADatabasePath](#Get-CADatabasePath)
  - [Get-CADatabaseSize](#Get-CADatabaseSize)
  - [Get-CAService](#Get-CAService)
  - [Invoke-CADatabaseDefragmentation](#Invoke-CADatabaseDefragmentation)
  - [Invoke-CADatabaseMaintenance](#Invoke-CADatabaseMaintenance)
  - [Publish-CACrl](#Publish-CACrl)
  - [Remove-CACertificate](#Remove-CACertificate)
  - [Set-CACrlConfig](#Set-CACrlConfig)
  - [Start-CAService](#Start-CAService)
  - [Stop-CAService](#Stop-CAService)
- [FAQ](#faq)
- [Contributing](#contributing)



## Introduction
SystemAdmins.AdcsToolbox is a PowerShell module designed to simplify the management and automation of Active Directory Certificate Services (ADCS). This module provides a set of cmdlets to perform common tasks related to ADCS such as database maintenance.



## Pre-requisuites
This module is only able to run on a Windows Server with the AD CS role installed.



## Installation
### Online mode

If the AD CS server have access to the internet.

1. Open a PowerShell session

2. Install and import the module

   ```powershell
   Install-Module -Name SystemAdmins.AdcsToolbox -Scope CurrentUser;
   ```



### Offline mode

Most AD CS servers don't have access to the internet, therefore it's required to manually download the module and copy it to the server.

1. Open a PowerShell session from a computer with internet access

2. Download the PowerShell module

   ```powershell
   Save-Module -Name SystemAdmins.AdcsToolbox -Path ([Environment]::GetFolderPath("Desktop")) -Force;
   ```

3. Copy the folder "SystemAdmins.AdcsToolbox" from your desktop on to the AD CS server to the following path "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules".



## Usage

1. Open a elevated PowerShell session (run as administrator) on the AD CS server.

2. Import the module

   ```powershell
   Import-Module SystemAdmins.AdcsToolbox;
   ```



## Cmdlets

### Backup-CA

#### Synopsis

Backup certificate authority with or without the private key.

#### Parameter(s)

| Type   | Parameter  | Description                       | Optional | Accepted Values      |
| ------ | ---------- | --------------------------------- | -------- | -------------------- |
| String | Path       | Backup folder path                | False    | C:\Path\To\My\Folder |
| Switch | PrivateKey | Include private key in the backup | True     |                      |

#### Example(s)

Create a backup without a private key to the folder "C:\Backup".

```powershell
Backup-CA -Path 'C:\Backup'
```

Create a backup with the private key to the folder "C:\Backup".

```powershell
Backup-CA -Path 'C:\Backup' -PrivateKey
```

### Output

Hashtable



### Export-CACertificate

#### Synopsis

Export certificate authority certificate (public key).

#### Parameter(s)

| Type   | Parameter  | Description        | Optional | Accepted Values      |
| ------ | ---------- | ------------------ | -------- | -------------------- |
| String | FolderPath | Backup folder path | False    | C:\Path\To\My\Folder |

#### Example(s)

Export the CA certificate (public key) the folder "C:\Backup".

```powershell
Export-CACertificate -FolderPath 'C:\Backup'
```

### Output

String



### Get-CACertificate

#### Synopsis

Get revoked, expired, failed or denied certificates from the AD CS database.

#### Parameter(s)

| Type     | Parameter | Description                                    | Optional | Accepted Values                  |
| -------- | --------- | ---------------------------------------------- | -------- | -------------------------------- |
| String   | State     | State of certificate/request                   | True     | Revoked, Expired, Denied, Failed |
| DateTime | Date      | Date limit (up-to) for the certificate/request | True     |                                  |

#### Example(s)

Get all evoked certificates from the AD CS database.

```powershell
Get-CACertificate -State 'Revoked'
```

Get all expired certificates up to 30 days ago.

```powershell
Get-CACertificate -State 'Expired' -Date (Get-Date).AddDays(-30)
```

### Output

System.Collections.ArrayList



### Get-CACommonName

#### Synopsis

Get certificate authority common name.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Get CommonName from Certificate Authority.

```powershell
Get-CACommonName
```

### Output

String



### Get-CACrlConfig

#### Synopsis

Get certificate authority revocation configuration.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Get revocation configuration.

```powershell
Get-CACrlConfig
```

### Output

PSCustomObject



### Get-CADatabasePath

#### Synopsis

Get AD CS database path.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Get database path.

```powershell
Get-CADatabasePath
```

### Output

PSCustomObject



### Get-CADatabaseSize

#### Synopsis

Get the AD CS database size.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Get database path.

```powershell
Get-CADatabaseSize
```

### Output

PSCustomObject




### Invoke-CADatabaseDefragmentation

#### Synopsis

Defragment the Active Directory Certificate Services database. The CertSvc service must be stopped ([Stop-CAService](#Stop-CAService)), prior running this cmdlet.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Get database path.

```powershell
Invoke-CADatabaseDefragmentation
```

### Output

Void



### Get-CAService

#### Synopsis

Get the status of the AD CS (CertSvc) service.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Get the service if "running" or "stopped".

```powershell
Get-CAService
```

### Output

String



### Invoke-CADatabaseMaintenance

#### Synopsis

Invoke AD CS database cleanu. It will perform the following:

1. Take a backup of the AD CS database.
2. If the AD CS service is running.
   - Take a backup of the original CRL configuration.
   - Stop the service
   - Extend the CRL expiration to two weeks
   - Start the service
   - Publish the CRL
3. Remove failed, denied, expired and revoked certificates up to a given date (default is older than three months)
4. Stop the service
5. Do a AD CS database defragmentation
6. Restore original CRL configuration
7. If the server was is a running state before starting the maintenance job
   - Start the service
   - Publish the CRL

#### Parameter(s)

| Type     | Parameter              | Description                                          | Optional | Accepted Values             |
| -------- | ---------------------- | ---------------------------------------------------- | -------- | --------------------------- |
| DateTime | CertificateRemovalDate | Date to remove expired and revoked certificates from | True     |                             |
| String   | BackupFolderPath       | Path to the backup folder                            | True     | C:\Path\To\My\Backup\Folder |
| Switch   | Confirm                | Confirmation prior to starting the maintenance       | True     |                             |

#### Example(s)

Run the maintenance on the AD CS database by taking a backup and removing old certificates and request.

```powershell
Invoke-CADatabaseMaintenance -CertificateRemovalDate (Get-Date).AddMonths(-3) -BackupFolderPath 'C:\ADCSBackup' -Confirm
```

### Output

Void



### Publish-CACrl

#### Synopsis

Publish the certificate revocation list.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Publish the CRL file(s)

```powershell
Publish-CACrl
```

### Output

Void



### Remove-CACertificate

#### Synopsis

Remove certificate/request from certificate authority.

#### Parameter(s)

| Type     | Parameter | Description                                    | Optional | Accepted Values                  |
| -------- | --------- | ---------------------------------------------- | -------- | -------------------------------- |
| String   | State     | State of certificate/request                   | True     | Revoked, Expired, Denied, Failed |
| DateTime | Date      | Date limit (up-to) for the certificate/request | True     |                                  |
| Switch   | Confirm   | Confirmation prior to removing certificates    | True     |                                  |

#### Example(s)

Remove revoked certificate older than 30 days.

```powershell
Remove-CACertificate -State 'Revoked' -Date (Get-Date).AddDays(-30)
```

### Output

System.Collections.ArrayList



### Set-CACrlConfig

#### Synopsis

Set certificate authority revocation configuration.

#### Parameter(s)

| Type   | Parameter               | Description                                   | Optional | Accepted Values            |
| ------ | ----------------------- | --------------------------------------------- | -------- | -------------------------- |
| Int    | PeriodUnits             | Period units                                  | True     | 0-2147483647               |
| String | Period                  | Period                                        | True     | Days, Weeks, Months, Years |
| Int    | DeltaPeriodUnits        | Delta period units                            | True     | 0-2147483647               |
| String | DeltaPeriod             | Delta period                                  | True     | Days, Weeks, Months, Years |
| Int    | OverlapUnits            | Overlap units                                 | True     | 0-2147483647               |
| String | OverlapPeriod           | Overlap period                                | True     | Days, Weeks, Months, Years |
| Int    | DeltaOverlapPeriodUnits | Delta overlap period units                    | True     | 0-2147483647               |
| String | DeltaOverlapPeriod      | Delta overlap period                          | True     | Days, Weeks, Months, Years |
| Bool   | RevocationCheck         | Disable or enable revocation check on startup | True     | True, False                |

#### Example(s)

Set CRL to only update every second week and disable revocation check at service startup.

```powershell
Set-CACrlConfig -PeriodUnits 2 -Period Weeks -DeltaPeriodUnits 0 -DeltaPeriod Days -OverlapUnits 0 -OverlapPeriod Weeks -DeltaOverlapUnits 0 -DeltaOverlapPeriod Days -RevocationCheck $true
```

### Output

Void



### Start-CAService

#### Synopsis

Start the AD CS (CertSvc) service.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Start the AD CS service.

```powershell
Start-CAService
```

### Output

Void



### Stop-CAService

#### Synopsis

Stop the AD CS (CertSvc) service.

#### Parameter(s)

| Type | Parameter | Description | Optional | Accepted Values |
| ---- | --------- | ----------- | -------- | --------------- |
|      |           |             |          |                 |

#### Example(s)

Stop the AD CS service.

```powershell
Stop-CAService
```

### Output

Void



## FAQ
- **Why was this PowerShell module created?**

  During a project at a customer we needed to automate the AD CS database maintenance job. The customer did not want to use the PSPKI module due to compiled DLL files.

- **I'm missing vital cmdlet for my work**

  Please create an issue on the GitHub repository




## Contributing
Contributions are welcome! Please fork the repository and submit a pull request.
