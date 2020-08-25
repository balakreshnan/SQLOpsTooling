# Use service pirncipal authenticate using azure devops and powershell

## Use power shell to connect to sql using service principal and token based authentication

## Create a service principal account

- Go to Azure portal
- Go to Azure active directory
- Create a new Application
- Create a new secret with expiration 1 year
- I created application call bbsqldw

## Set permission to Azure AD accounts for Azure SQL DB

- Set access using powershell for basic Azure AD user
- Replace tenant ID
- Replace SQL database server name

```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass


# This script grants Azure “Directory Readers” permission to a Service Principal representing the Azure SQL logical server
# It can be executed only by a "Global Administrator" or “Privileged Roles Administrator” type of user.
# To check if the “Directory Readers" permission was granted, execute this script again

Import-Module AzureAd
connect-azuread -TenantId "xxxxxxx"     #Enter your actual TenantId
 $AssignIdentityName = "xxxxx.database.windows.net"     #Enter Azure SQL logical server name
 
# Get Azure AD role "Directory Users" and create if it doesn't exist
$roleName = "Directory Readers"
$role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $roleName}
if ($role -eq $null) {
    # Instantiate an instance of the role template
    $roleTemplate = Get-AzureADDirectoryRoleTemplate | Where-Object {$_.displayName -eq $roleName}
    Enable-AzureADDirectoryRole -RoleTemplateId $roleTemplate.ObjectId
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq $roleName}
}
 
# Get service principal for managed instance
$roleMember = Get-AzureADServicePrincipal -SearchString $AssignIdentityName
$roleMember.Count
if ($roleMember -eq $null)
{
    Write-Output "Error: No Service Principals with name '$    ($AssignIdentityName)', make sure that AssignIdentityName parameter was     entered correctly."
    exit
}
if (-not ($roleMember.Count -eq 1))
{
    Write-Output "Error: More than one service principal with name pattern '$    ($AssignIdentityName)'"
    Write-Output "Dumping selected service principals...."
    $roleMember
    exit
}
 
# Check if service principal is already member of readers role
$allDirReaders = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
$selDirReader = $allDirReaders | where{$_.ObjectId -match     $roleMember.ObjectId}
 
if ($selDirReader -eq $null)
{
    # Add principal to readers role
    Write-Output "Adding service principal '$($msName)' to     'Directory Readers' role'..."
    Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId     $roleMember.ObjectId
    Write-Output "'$($AssignIdentityName)' service principal added to     'Directory Readers' role'..."
 
    #Write-Output "Dumping service principal '$($AssignIdentityName)':"
    #$allDirReaders = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId
    #$allDirReaders | where{$_.ObjectId -match $roleMember.ObjectId}
}
else
{
    Write-Output "Service principal '$($AssignIdentityName)' is already member of 'Directory Readers' role'."
}
```

## Assign service principal user to Azure SQL DW

```
CREATE USER [bbsqldw] FROM EXTERNAL PROVIDER
GO

EXEC sp_addrolemember 'db_owner', [bbsqldw]
GO

GRANT ALTER ANY USER TO [bbsqldw]
GO
```

- the below is to validate and then apply grant statement to read the table

```

SELECT name, type, type_desc, CAST(CAST(sid as varbinary(16)) as uniqueidentifier) as appId from sys.database_principals WHERE name = 'bbsqldw'
GO

select * from dbo.tblconnstr;

GRANT SELECT ON dbo.tblconnstr TO [bbsqldw]
GO
```

## Powershell script to connect to sql with service principal

- set the variables

```
$tenantId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   #  tenantID (Azure Directory ID) were AppSP resides
$clientId = "xxxxxxxxxxxxxxxxxxxxxxxxx"   #  AppID also ClientID for bbsqldw     
$clientSecret = "xxxxxxxxxxxxxxxxxxxxxxxxx"   #  client secret for bbsqldw 
$Resource = "https://database.windows.net/"
```

- Authenticate and get token to use
- Check the path for AzureAD modules
- If not exist please install 

```
install-module AzureAD
install-module sqlserver
```

- Save the Token for using it for further processing
- Tenantid and application ID and secret are necessary

```
$adalPath  = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureAD\2.0.2.106"
# To install the latest AzureRM.profile version execute  -Install-Module -Name AzureRM.profile
$adal      = "$adalPath\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$adalforms = "$adalPath\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
[System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  $resourceAppIdURI = 'https://database.windows.net/'

  # Set Authority to Azure AD Tenant
  $authority = 'https://login.windows.net/' + $tenantId

  $ClientCred = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential]::new($clientId, $clientSecret)
  $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)
  $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI,$ClientCred)
  $Tok = $authResult.Result.CreateAuthorizationHeader()
  $Tok=$Tok.Replace("Bearer ","")
  Write-host "token"
  $Tok
  Write-host  " "
```

- now connect and run query
- Get sql server name
- Get database name
- i created the query as "select * from dbo.tblconnstr;"

```
$SQLServerName = "bbaccdbsvr"    # Azure SQL logical server name 
Write-Host "Create SQL connectionstring"
$conn = New-Object System.Data.SqlClient.SQLConnection 
$DatabaseName = "bbaccdb"     # Azure SQL database name
$conn.ConnectionString = "Data Source=$SQLServerName.database.windows.net;Initial Catalog=$DatabaseName;Connect Timeout=30"
$conn.AccessToken = $Tok

Write-host "Connect to database and execute SQL script"
$conn.Open() 
$ddlstmt = 'select * from dbo.tblconnstr;'
Write-host " "
Write-host "SQL Query command"
$ddlstmt
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($ddlstmt, $conn)       

Write-host "results"
$reader = $command.ExecuteReader()
Write-Host $results
Write-host "results done"
$conn.Close()
```