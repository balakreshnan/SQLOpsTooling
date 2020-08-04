# SQL Ops - Azure DevOps SQL Database CI/CD 

## Azure SQL Database - Visual Studio 2019 Database project CI/CD

## Prerequistie

- Visual Studio 2019
- SQL Data Tools installed
- Azure DevOps Project
- Github Repo to Store Code
- Azure sql database

# Architecture

![alt text](https://github.com/balakreshnan/WorkplaceSafety/blob/master/WorkplaceSafetyarch.jpg "Architecture")

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
- Select SQL Server Database project
- Give project name as sqlopsdemo
- Right click Project name and click Import
- Expand Azure
- Log into Azure account
- Select the database to connect
- Import the schema
- Wait for import to complete
- Push changes to github

