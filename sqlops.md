# SQL Ops - Azure DevOps SQL Database CI/CD 

## Azure SQL Database - Visual Studio 2019 Database project CI/CD

## Prerequistie

- Visual Studio 2019
- SQL Data Tools installed
- Azure DevOps Project
- Github Repo to Store Code
- Azure sql database

## Architecture

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/devopsarch.jpg "Architecture")

## Create Github Repo

- Log into Github.com
- Create a repo called SQLOpsTooling
- I created as public

## Create Azure SQL Database

- Go to Azure portal
- Create a new Azure SQL database with new server
- Set SA login and password
- Add firewall rule to get access
- Create tables and stored procedure in sqlopsdemo\sqlopsdemo\dbo folder
- manualy create for first time.

## Create Database project using Visual Studio 2019

- Open Visual Studio
- Create a new project/solution

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/vsprj1.jpg "Project")

```
If you don't see the project type, then install SQL server tools for visual studio 2019
```

- Select SQL Server Database project
- Give project name as sqlopsdemo
- Right click Project name and click Import
- Expand Azure
- Log into Azure account
- Select the database to connect
- Import the schema
- Wait for import to complete
- Push changes to github
- Sample SQL project - SQLOpsTooling/sqlopsdemo

## Azure Devops Build and Release

## Build Process

- Log into Dev.azure.com
- Create a New project called sqlopsdemo
- Connect to above repo
- Create a Build Pipeline
- Name the build as: sqlopsdemo-Build
- First set the agent specification to windows-2019

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build1.jpg "Build")

- Click Get Source and connect to above github repo and select master branch
- Add New task as Nuget Command Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build2.jpg "Build")

- Add Nuget Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build3.jpg "Build")

- Add Visual Studio Build Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build4.jpg "Build")

- Add CMD task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build5.jpg "Build")

- Copy Files Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build6.jpg "Build")

- Add Azure SQL Database Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build7.jpg "Build")

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build7-1.jpg "Build")

- Copy Files Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build8.jpg "Build")

- Publish Pipeline Artifacts Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/build9.jpg "Build")

- Click Save and Queue
- Click run logs
- Wait for Build to complete.

## Release Process - QA and Prduction

- Create a New Release and name it New Release Pipeline

## QA

- Create Stage called: ReleaseQA
- Configure Agent details

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseqa1.JPG "Release QA")

- Download Publish Artifacts - Connect to above build

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseqa2.JPG "Release QA")

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseqa2-1.JPG "Release QA")

```
$(System.DefaultWorkingDirectory)\DBDeployment\sqlopsdemo\sqlopsdemo\bin\Release\sqlopsdemo.dacpac
```

```
/p:GenerateSmartDefaults=True /p:BlockOnPossibleDataLoss=True /p:BlockWhenDriftDetected=True
```

- CMD tasks

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseqa3.JPG "Release QA")

- Azure SQL Database Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseqa4.JPG "Release QA")

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseqa4-1.JPG "Release QA")

## Production

- Create stage called: Production
- Configure Agent details

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseprod1.JPG "Release PROD")

- Download Publish Artifacts - Connect to above build

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseprod2.JPG "Release PROD")

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseprod2-1.JPG "Release PROD")

```
$(System.DefaultWorkingDirectory)\DBDeployment\sqlopsdemo\sqlopsdemo\bin\Release\sqlopsdemo.dacpac
```

```
/p:GenerateSmartDefaults=True /p:BlockOnPossibleDataLoss=True /p:BlockWhenDriftDetected=True
```

- CMD tasks

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseprod3.JPG "Release PROD")

- Azure SQL Database Task

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseprod4.JPG "Release PROD")

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseprod4-1.JPG "Release PROD")

Final Release Pipeline should look like below

![alt text](https://github.com/balakreshnan/SQLOpsTooling/blob/master/images/releaseall1.jpg "Release ALL")

- Now Save
- Create New Release
- Wait for Release to complete without errors. If errors please troubleshoot the errors