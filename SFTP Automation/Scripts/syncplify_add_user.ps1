﻿param
(
    [hashtable]$users,
    [string]$root,
    [int]$hardquota
    

)

Write-Host "Hello" $users.username 
pause

function Connect-Syncplify {

    <#
    .SYNOPSIS
        Used to establish an initial connection to the Syncplify REST API
    .EXAMPLE
    PS>>Connect-Syncplify -Server SyncplifyServer01.MyDomain.Com -Port 4443
    .PARAMETER Server
        Name of server to connect to
    .PARAMETER Username
        Username with access to API
    .PARAMETER Password
        Password for specified username
    #>

    [CmdletBinding()]
    param(
    
    [ValidateScript({
        if (-not (test-Connection $_ -quiet -count 1))
        {
            throw "The server [$_] is offline. Try again."
        }
        else
        {
            $true
        }
    })]
    
    [string]$Port ='5443',
    [string]$server = 'tms.com',
    [string]$VirtualServer = 'testing',
    [string]$User,
    [string]$Password
    )

    ## Declares the global variable to store the url of the server to be authenticated with
    $global:url = "https://$($server):$($port)/smserver-$($VirtualServer)/"
    $global:url

    ## Checks if the username or password is not present and prompt for secure credentials
    if ([string]::IsNullOrEmpty($User) -or [string]::IsNullOrEmpty($Password)){
        $credentials = (get-credential)
        $user = $credentials.UserName
        $password = $credentials.GetNetworkCredential().Password 
    }

    ## Concatenates the username and password into a base64 encoded string
    $userpass = $user+":"+$Password
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($userpass)
    $encoded = [system.convert]::ToBase64String($bytes)

    ## Defines the header section of the API call
    $headers = @{
        Authorization = "Basic $encoded"
        }
        $encoded

    ## Begins the main call to the server with supplied information
    try {

    ## Sends auth request to the server and stores the result in the variable $SyncplifyAuthResult for use by other functions
    Write-Verbose -Message "Invoke-RestMethod -Method get -Uri $($url)/auth -ContentType application/json -Headers $($headers)"
    $global:SyncplifyAuthResult = Invoke-RestMethod -Method get -Uri $url"auth" -ContentType "application/json" -Headers $headers

        } ## End try

  catch {

             ## Checks to see if the authentication failed due to incorrect connection details
             if ( $($_.Exception.Message) -match "400") { Write-Error -Message "Failed to authenticate with $server. Please verify connection details and try again." } else { $_.Exception.Message }

             ## If authentication fails the function stops processing
             return

        } ## End Catch

        ## Upon successful connection, the following is written to the host
        Write-Host -BackgroundColor DarkGreen "Connected to Syncplify Server: $url"
        pause

} ## End function Connect-Syncplify

Connect-Syncplify

function Set-SyncplifyVFS {

    <#
    .SYNOPSIS
        Used to retrieve a user or all users from the Syncplify Server
    .EXAMPLE
    PS>>Get-SyncplifyUser -User 'User@domain.com'
    .EXAMPLE
    PS>>Get-SyncplifyUser -All
    .PARAMETER User
        Username of user to retrieve
    .PARAMETER All
        Switch used to retrieve all users. Cannot be used in conjunction with the 'User' parameter
    #>

  <#  [CmdletBinding()]
    param(
    [Parameter(ParameterSetName='SingleUser')]
    [string]$User,
    [Parameter(ParameterSetName='AllUsers')]
    [switch]$All
    )
    #>

    ## Declares the header section
    $headers = @{
    Authorization = "Bearer $($SyncplifyAuthResult.access_token)"
    Accept = "*/*"
    }
    $vfsid = [guid]::NewGuid()
    $vfsid = [string]$vfsid
    $vfsid = $vfsid.Replace("-", "")

    #try {   
             [String]$VFS =$users.VFSName
                       
           
            $body = ,@{
                        _id = $vfsid
                        VFSName = $VFS
                        TargetType = "Disk"
                        Target = $root
                        HardQuota = $hardquota
                        
                        }


            $VFS_result={}
            $VFS_result= ConvertTo-Json -InputObject @($body) -Compress

                        


            $body = ConvertTo-Json -InputObject @($body) -Compress
            
            $body
            $Result = Invoke-RestMethod -Method POST -uri $url"sms.SaveVFS" -ContentType "application/json" -body $body -Headers $headers
            
            
            return $Result = New-Object PSObject -Verbose $Result[0].Result


            
     #   } catch {

            ## Checks for errors
            if ($_.Exception.MEssage -match "403") {Write-Error "ACCESS DENIED: You must authenticate with the Syncplify server before proceeding."}

            ## Stops processing
            return
      #  }

        ## Returns the result of the request
        
        pause
}

 Set-SyncplifyVFS

function Set-SyncplifyUser {

    <#
    .SYNOPSIS
        Used to retrieve a user or all users from the Syncplify Server
    .EXAMPLE
    PS>>Get-SyncplifyUser -User 'User@domain.com'
    .EXAMPLE
    PS>>Get-SyncplifyUser -All
    .PARAMETER User
        Username of user to retrieve
    .PARAMETER All
        Switch used to retrieve all users. Cannot be used in conjunction with the 'User' parameter
    #>

  <#  [CmdletBinding()]
    param(
    [Parameter(ParameterSetName='SingleUser')]
    [string]$User,
    [Parameter(ParameterSetName='AllUsers')]
    [switch]$All
    )
    #>

    ## Declares the header section
    $headers = @{
    Authorization = "Bearer $($SyncplifyAuthResult.access_token)"
    Accept = "*/*"
    }

    try {


        
$body = @{

     _id = $userid
     UserType = "ADGroup"
     Username = $user
     PHType   = "V4Plus"
        
     Home = [psobject]@{
            MountPoint = "/"
            VFSItemID = $vfsid
            Visible = "true"
            ImpType = "ByHandle"
            ImpUser = ""
            ImpPass = ""
            Permissions = [psobject]@{
                
                canGetFile = "true"
                canPutFile = "true"
                canDelFile = "true"
                canModFile = "true"
                canRenFile = "true"
                canListDir = "true"
                canMakeDir = "true"
                canDelDir  = "true"
                canRenDir  = "true"
                }
                
            
        
    }

    VirtualFolders = @()
    AuthType = @(
    "Password")
    AuthAll           = "false"
    AllowPlainFTP     = "false"
    AllowExplicitFTPS = "true"
    AllowImplicitFTPS = "true"
    AllowSSH          = "false"
    AllowSFTP         = "true"
    AllowForward      = "false"
    AllowWebDAV       = "false"
    AccountStatus     = "Enabled"
    AutoEnable        = "false"
    AutoDisable       = "false"
    AllowedIPs        = @()
    AllowedFwd        = @()
    SpeedLimits       = @()
    EventHandlers     = @() 


} 



                       



            $body = ConvertTo-Json -InputObject @($body) -Depth 4
            
            pause
            $Result = Invoke-RestMethod -Method POST -uri $url"sms.SaveUser" -ContentType "application/json" -body $body -Headers $headers
            if($Result -like "Result : 1")
            {Write-Host " New user has been successfully created"}
            else
            {Write-Host "Some issue"}
            
            
           

        } catch {

            ## Checks for errors
            if ($_.Exception.MEssage -match "403") {Write-Error "ACCESS DENIED: You must authenticate with the Syncplify server before proceeding."}

            ## Stops processing
            return
        }

        ## Returns the result of the request
        return $Result = New-Object PSObject -Verbose $Result[0].Result

}

Set-SyncplifyUser