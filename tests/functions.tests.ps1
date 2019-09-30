[CmdletBinding()]
PARAM($modulePath,$moduleName,$srcPath)
begin{
    # Find the Manifest file
    $ManifestFile = "$modulePath\$ModuleName.psd1"

    # Unload any module with same name
    Get-Module -Name $ModuleName -All | Remove-Module -Force -ErrorAction Ignore

    # Import Module
    $ModuleInformation = Import-Module -Name $ManifestFile -Force -ErrorAction Stop -PassThru

    # Get the functions present in the Manifest
    $ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.name

    # Public functions
    $publicFiles = @(Get-ChildItem -Path $srcPath\public\*.ps1 -ErrorAction SilentlyContinue)
}
end{
    $ModuleInformation | Remove-Module -ErrorAction SilentlyContinue
}
process{
    Describe "$ModuleName Module - Function Tests" -Tag 'build' {
        Context "Get-FileSystem"{
            It "Without -Path"{ Get-FileSystem | Should -not -BeNullOrEmpty}
            #It "Fake parameter"{ Get-FileSystem -FakeParam | Should -Throw}
            #It "With -Path"{ Get-FileSystem | Should -Not -Throw }
            #It "Invalid Path" {<#Should -Throw#>}
        }
    }
}