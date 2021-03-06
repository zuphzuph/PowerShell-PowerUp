<#
$Metadata = @{
	Title = "Copy-SPOFolder"
	Filename = "Copy-SPOFolder.ps1"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = "https://sharepointpowershell.codeplex.com"
	Author = "Jeffrey Paarhuis"
	AuthorContact = "http://jeffreypaarhuis.com/"
	CreateDate = "2013-02-2"
	LastEditDate = "2014-02-2"
	Url = ""
	Version = "0.1.2"
	License = @'
The MIT License (MIT)
Copyright (c) 2014 Jeffrey Paarhuis
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'@
}
#>

function Copy-SPOFolder
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string]$folderPath, 
		
		[Parameter(Mandatory=$true, Position=2)]
		[string]$doclib, 
		
		[Parameter(Mandatory=$false, Position=3)]
		[bool]$checkoutNecessary = $false
	)

    # for each file in folder Copy-SPOFile()
    $files = Get-ChildItem -Path $folderPath -Recurse
    foreach ($file in $files)
    {
        $folder = $file.FullName.Replace($folderPath,'')
        $targetPath = $doclib + $folder
        $targetPath = $targetPath.Replace('\','/')
        Copy-SPOFile $file $targetPath $checkoutNecessary
    }
}
