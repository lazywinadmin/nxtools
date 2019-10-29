# nxTools

[![Build Status](https://dev.azure.com/lazywinadmin/nxtools/_apis/build/status/lazywinadmin.nxtools?branchName=master)](https://dev.azure.com/lazywinadmin/nxtools/_build/latest?definitionId=23&branchName=master)

PowerShell module for Linux platform. Collection of commands wrapped around linux commands to parse the output into PowerShell custom objects.

## Getting Started

```powershell
# Install the module from the PowerShell Gallery
Install-Module -Name nxtools -Scope CurrentUser
```

## Usage

### Retrieve File Systems

```powershell
Get-FileSystem -Path '/d/d5/'
```

## Contributions

Please read the [CONTRIBUTING markdown file](CONTRIBUTING.md).