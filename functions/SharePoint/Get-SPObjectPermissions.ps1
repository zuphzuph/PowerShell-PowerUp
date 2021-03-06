<#
$Metadata = @{
    Title = "Get SharePoint Object Permissions"
	Filename = "Get-SPObjectPermissions.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-11"
	LastEditDate = "2013-12-18"
	Version = "4.2.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPObjectPermissions{

<#

.SYNOPSIS
    Get permissions on SharePoint objects.

.DESCRIPTION
	Get permissions on SharePoint objects.
    
.PARAMETER Identity
	Url of the SharePoint website.
    
.PARAMETER IncludeChildItems
	Requires Identity, includes the child items of the specified website.
    
.PARAMETER Recursive
	Requires Identity, includes the every sub item of the specified website.
    
.PARAMETER OnlyLists
	Only report list items.
    
.PARAMETER OnlyWebsites
	Only report website items.

.PARAMETER ByUsers
	Report permissions by user rights.

.EXAMPLE
	PS C:\> Get-SPObjectPermissions -Identity "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -IncludeChildItems -Recursive -OnlyLists -OnlyWebsites -ByUsers

#>

	param(
		[Parameter(Mandatory=$false)]
		[string]$Identity,
		
		[switch]$IncludeChildItems,

		[switch]$Recursive,
        
        [switch]$OnlyLists,
        
        [switch]$OnlyWebsites,
        
        [switch]$ByUsers
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if(-not (Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)){Add-PSSnapin "Microsoft.SharePoint.PowerShell"}
    Import-Module ActiveDirectory

    #--------------------------------------------------#
    # functions
    #--------------------------------------------------#
    function Get-SPObjectPermissionMemberType{
    
        param(
            [Parameter(Mandatory=$true)]
            $RoleAssignment
        )
        
        #check if type of member ADGroup, SPGroup, ADUser, User
        if($RoleAssignment.Member.IsDomainGroup){
            $MemberType = "ADGroup"                        
        }elseif(($RoleAssignment.Member.LoginName).StartsWith("SHAREPOINT\")){
            $MemberType = "SPUser"  
        }elseif($RoleAssignment.Member.UserToken -ne $null){
            $MemberType = "ADUser"                                          
        }else{
            $MemberType = "SPGroup"
        }
        
        $MemberType
    }


    function Get-SPObjectPermissionMember{
    
        param(
            [Parameter(Mandatory=$true)]
            $RoleAssignment
        )
        
        $Member =  $RoleAssignment.Member.UserLogin -replace ".*\\",""
        if($Member -eq ""){
            $Member =  $RoleAssignment.Member.LoginName
        }
        
        $Member
    }
    
    
    function Get-SPReportItemByUsers{
    
        param(
            [Parameter(Mandatory=$true)]
            $SPReportItem
        )
        
        if($SPReportItem.MemberType -eq "ADGroup"){
            $ADUsers = Get-ADGroupMember -Identity $SPReportItem.Member -Recursive | Get-ADUser -Properties DisplayName | where{$_.Enabled}
                
        }elseif($SPPermission.MemberType -eq "ADUser"){
            $ADUsers = Get-ADUser -Identity $SPReportItem.Member | where{$_.Enabled}
            
        }else{
            $ADUsers = $Null
        }
            
        if($ADUsers){
            foreach($ADUser in $ADUsers){
                
                # reset item         
                $SPReportItemByUsers = $SPReportItem.PsObject.Copy()
            
                $SPReportItemByUsers | Add-Member -MemberType NoteProperty -Name "UserName" -Value $ADUser.Name -Force
                $SPReportItemByUsers | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $ADUser.DisplayName -Force
                $SPReportItemByUsers | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $ADUser.UserPrincipalName -Force
                
                $SPReportItemByUsers
            }
        }
        
    }
    
    function New-ObjectSPReportItem{
        param(
            $Name,
            $Url,
            $Member,
            $MemberType,
            $Permission,
            $Type
        )
        New-Object PSObject -Property @{
            Name = $Name
            Url = $Url
            Member = $Member
            MemberType = $MemberType
            Permission = $Permission
            Type = $Type
        }
    }

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    # resets
    $SPWebs = @()
    
    # check if url has been passed
    if($Identity){
    
        # get url
        $SPUrl = (Get-SPUrl $Identity).Url
        
        $SPWeb = Get-SPWeb $SPUrl
        
        if($IncludeChildItems -and -not $Recursive){
        
            $SPWebs += $SPWeb
            $SPWebs += $SPWeb.webs            
        
        }elseif($Recursive -and -not $IncludeChildItems){
        
            $SPWebs += $SPWeb.Site.AllWebs | where{$_.Url.Startswith($SPWeb.Url)}
            
        }else{
        
            $SPWebs += $SPWeb
        }  
              
     }else{
    
        $SPWebs += Get-SPsite -Limit All | Get-SPWeb -Limit All -ErrorAction SilentlyContinue

    }
           
    #Loop through each website and write permissions
    foreach ($SPWeb in $SPWebs){

        Write-Progress -Activity "Read permissions" -status $SPWeb -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
            
        if(($SPWeb.permissions -ne $null) -and  ($SPWeb.HasUniqueRoleAssignments) -and -not $OnlyLists){  
                
            foreach ($RoleAssignment in $SPWeb.RoleAssignments){
            
                # get member
                $Member = Get-SPObjectPermissionMember -RoleAssignment $RoleAssignment
                $MemberType = Get-SPObjectPermissionMemberType -RoleAssignment $RoleAssignment

                # get permission definition
                $Permission = $RoleAssignment.roledefinitionbindings[0].Name
                
                # new item in array
                $SPReportItem = New-ObjectSPReportItem -Name $SPWeb.Title -Url $SPWeb.url -Member $Member -MemberType $MemberType -Permission $Permission -Type "Website" 
                
                # extend with user
                if($ByUsers){Get-SPReportItemByUsers -SPReportItem $SPReportItem}else{$SPReportItem}            
            }        
        }
        
        # output list permissions
        if(-not $OnlyWebsites){  
                      
            foreach ($SPlist in $SPWeb.lists){
                
                if (($SPlist.permissions -ne $null) -and ($SPlist.HasUniqueRoleAssignments)){  
                      
                    foreach ($RoleAssignment in $SPlist.RoleAssignments){
                    
                        # set list url
                        [Uri]$SPWebUrl = $SPWeb.url
                        $SPListUrl = $SPWebUrl.Scheme + "://" + $SPWebUrl.Host + $SPlist.DefaultViewUrl -replace "/([^/]*)\.(aspx)",""
                                                    
                        # get member
                        $Member = Get-SPObjectPermissionMember -RoleAssignment $RoleAssignment
                        $MemberType = Get-SPObjectPermissionMemberType -RoleAssignment $RoleAssignment
                                               
                        # get permission definition
                        $Permission = $RoleAssignment.roledefinitionbindings[0].Name   
                                                 
                        # new item in array
                        $SPReportItem = New-ObjectSPReportItem -Name ($SPWeb.Title + " - " + $SPlist.Title) -Url $SPListUrl -Member $Member -MemberType $MemberType -Permission $Permission -Type "List"
                        
                        # extend with user
                        if($ByUsers){Get-SPReportItemByUsers -SPReportItem $SPReportItem}else{$SPReportItem}  
                    }
                }
            }
        }                
    }
}