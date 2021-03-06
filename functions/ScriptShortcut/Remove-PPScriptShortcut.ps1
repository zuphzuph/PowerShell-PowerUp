<#
$Metadata = @{
	Title = "Remove PowerShell PowerUp Script Shortcut"
	Filename = "Remove-PPScriptShortcut.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-09"
	LastEditDate = "2014-01-09"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Remove-PPScriptShortcut{

<#
.SYNOPSIS
    Remove a new PowerShell PowerUp script shortcut.

.DESCRIPTION
	Remove a new PowerShell PowerUp script shortcut. Script shortcuts can be used to run a script from script folder where ever it is stored.

.PARAMETER Name
	Name of the script which a script shortcut referes to.

.EXAMPLE
	PS C:\> Remove-PPScriptShortcut -Name Script1.ps1

.EXAMPLE
	PS C:\> Remove-PPScriptShortcut -Name s1
#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true)]
		[String]
		$Name
	)
  
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    $ShortcutToRemove = Get-PPScript -Name $Name -Shortcut
    
    if($ShortcutToRemove){
    
        Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.ScriptShortcut.DataFile -Recurse | %{
        
            Write-Host "Remove script shorcut: $($ShortcutToRemove.Name)"
        
            $Xml = [xml](get-content $_.Fullname)
            $RemoveNode = Select-Xml $xml -XPath "//Content/ScriptShortcut[@Name=`"$($ShortcutToRemove.Name)`"]"
            $null = $RemoveNode.Node.ParentNode.RemoveChild($RemoveNode.Node)
            $Xml.Save($_.Fullname)
        }
    }
}