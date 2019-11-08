
function Show-Menu
{
    param (
        [string]$Title = 'SFTP Account Management System'
    )
    Clear-Host
    Write-Host "================ $Title ================"
   
    Write-Host "1: Press '1' to Create New SFTP Account.***NON KC ACCOUNT**"
    Write-Host "2: Press '2' to Create New SFTP Account (KC Owned Account)"
    Write-Host "3: Press '3' to Find SFTP accounts for a particular Client."
    Write-Host "3: Press '4' to Delete exisiting SFTP Account."
    Write-Host "Q: Press 'Q' to quit."
}
function get_ticket_no{
    do{          
			$global:CaseNo = Read-Host -Prompt "`nEnter the Case No (RITM/ Incident No.)"
            $global:CaseNo = $global:CaseNo.ToUpper()
      }
            
    while(!$CaseNo)
}

function get_owner_id{

    do{
			$global:email = Read-Host -Prompt "`nEnter the Account Owner email"
	  }
            
   while(!$global:email)
}

function set_newaccount{
                    
                try{if($Ev -eq 0)
                    {
                        $global:FirstName = "SFTP"
                        $global:LastName = $Client
                        $count++
                        switch($selection){
                        1 {
                                $global:Name = $global:FirstName + " " +$global:Lastname + $count
                                $global:endname = $Client + $count
                          }

                        2 {
                                $global:Name = $global:FirstName + " " +$global:Lastname + "KC" + $count
                                $global:endname = $Client + "KC" + $count
                          }
                        }
                       
                        $global:displayname = $global:Name
                       
					    $global:useraccount =$global:FirstName.ToLower() + "-"+$global:endname
					    $global:useraccount

                    if($global:location -eq 1)

					        {$global:desc = $global:CaseNo + " | UK "}

                    else
                            {Write-Host $global:location
                            $global:desc = $global:CaseNo + " | CA "}
					$global:desc
                    
					$global:groupname = $global:useraccount + "-group"
					

                    $global:Fullusername= "$global:useraccount@tms.com"
                    
                    }
            }
            catch{}
}

function generate_password{
        try
            {
                if($Ev -eq 0)
                    {
                        Add-Type -AssemblyName System.Web
					    $global:PW = [System.Web.Security.Membership]::GeneratePassword(12,5)
					    $PW
					    $SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
     
                    }
             }

        catch
                {
                    $Ev++
                    $_ | Out-File C:\Password_generation_error.txt -Append
                }
}

function create_user
{ 
                        $password = $global:PW
                        $password
					    $SecurePass = $password | ConvertTo-SecureString -AsPlainText -Force
                        
					    

        try{if($Ev -eq 0)
            {

                switch($selection)
                    {
                        1 {$Na
                            New-ADUser -Name $global:Name -GivenName $global:FirstName -SurName $global:LastName -SamAccountName $global:useraccount -Initials " " -UserPrincipalName $global:useraccount"@tms.com" -Description $global:Desc -DisplayName $global:displayname -Path "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -EmailAddress $global:email -AccountPassword $SecurePass -Enabled $true

                          }
                    
                        2 {
                        New-ADUser -Name $global:Name -GivenName $global:FirstName -SurName $global:LastName -SamAccountName  $global:useraccount -Initials "KC" -UserPrincipalName $global:useraccount"@tms.com" -Description $global:Desc -DisplayName $global:displayname -Path "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -EmailAddress $global:email -AccountPassword $SecurePass -Enabled $true
                          }
                     }
                                     
                    clear
                    Write-Host " You have successfully create the SFTP Account, below are the Details:"
                    Write-Host "User Account Details:"
                    Get-ADUser $global:useraccount -Properties UserPrincipalName, Initials, SurName, EmailAddress, Description |Select-Object UserPrincipalName, Initials, SurName, EmailAddress, Description
                    Write-Host " Created Password" $global:PW
                    }}
					
					catch{
                    $Ev++
                    Write-Host "*****************ERROR FOUND - Delete the Account (Refer C:\Adding_User_errors.txt for Error)***************"
					Write-Host "There is some error while creating a Account"
                    $_ | Out-File C:\Adding_User_errors.txt -Append

					}

}

function create_group{
            try{if($Ev -eq 0){
                    New-ADGroup -Path "OU=SFTP-GROUPS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -DisplayName $global:groupname -Name  $global:groupname  -SamAccountName $global:groupname -Description $global:desc -GroupScope Global
                    
                    switch($Selection){
                        1 {
                                Add-ADGroupMember $global:groupname $global:useraccount
                          }

                        2 {
                                Add-ADGroupMember $global:groupname $global:useraccount, KC_SFTP_Access
                          }
                    }
                    Write-Host ""
                    Write-Host "Group Details:"
                    Get-ADGroup $global:groupname -Properties Name, SamAccountName | Format-Table Name, SamAccountName
                    }
                    
               }


           catch{
                    $Ev++
                     
                    Write-Host "`n*****************ERROR FOUND - Delete the Account (Refer C:\Adding_Group_errors.txt for Error)***************"
					Write-Host "`nThere is some error while creating a Account"
                    $_ | Out-File C:\Adding_Group_errors.txt -Append

			    }
}


function create_folder{

 try{if($Ev -eq 0){
                    
                    $foldername = $global:endname+"Data"
                    New-Item -Path K:\$foldername -ItemType Directory
                    $Acl = Get-Acl "K:\$foldername"
                    $Ar = New-Object  System.Security.AccessControl.FileSystemAccessRule($global:groupname,'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
                    $Acl.SetAccessRule($Ar)
                    Set-Acl "K:\$foldername" $Acl
                    Remove-PSDrive K                                      #Remove the Mapped Drive from the System.
                    Write-Host "User Account Created"
                    Write-Host "User Folder Created"
                    Write-Host "Modify Access Granted to the group"
                    

                    }

      }

      catch{}
                    
}

function send_email{
                try{if($Ev -eq 0)
                    {
                    Write-Host "Hit enter to send the credentials to the account owner"
                    pause
                    $EmailFrom = "vibdon123456789@gmail.com"
                    $EmailTo = "vibhor.rc@gmail.com" 
                    $Subject = "$global:username Credentials" 
                    $Body = @"
                            Hi $global:email,

                            Please find below the newly created SFTP Account from $Client :
                            Hostname: ftp-corp.rms.com
                            Username: $global:Fullusername
                            Password: $global:PW
                            Port : 22

                            In case of any concern, please reach out to us @ rmsnoc@rms.com or call us at 7030.
"@
                    $SMTPServer = "smtp.gmail.com" 
                    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
                    $SMTPClient.EnableSsl = $true 
                    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("vibdon123456789", "bgsinternational"); 
                    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
                     Write-Host "Credentials have been successfully sent to the user"
                     Write-Host "Press q to quit." 
                     pause
                }

              }
              catch{
                    $Ev++
                    Write-Host "`n*****************ERROR while sending email (Refer C:\error-sending-email.txt for Error)***************"
					Write-Host " `nThere is some error while creating a Folder"
                    $_ | Out-File C:\error-sending-email.txt -Append

					}
}

function get_location {
        
            do{
			$global:location = Read-Host -Prompt "`nEnter the SFTP Account Location (CA / UK). Press 1 for UK. Press 2 for CA"
            $locerror = 0
            switch($selection)
            {
                    1 {$UKshare = "E:\ftpuk-corp"
                       $CAshare = "E:\ftp-corp"
                      }

                    2 {$UKshare = "E:\ftpuk-corp\KC"
                       $CAshare = "E:\ftp-corp\KC"
                      }
            }
              
              #################### Connecting to the Network Share ########################################           
            
            try{if($Ev -eq 0){
                    

                switch($global:location){
		                1 {
                                If (!(Test-Path K:))
                                    {New-PSDrive -Name "K" -PSProvider FileSystem -Root $UKshare -Scope global
                                    "You have selected UK Location. We are connecting to the UK File Server"
                                    }                                                                                     ## To Attach the network share as a map drive.
                           }

		                2 {
		                        If (!(Test-Path K:))
                                    {New-PSDrive -Name "K" -PSProvider FileSystem -Root $CAshare -Scope global
                                    "You have selected CA Location. We are connecting to the CA File Server"
                                    }                                                                                      ## To Attach the network share as a map drive.
                            }

                        q {exit
                                
                             } 
                       Default {
                                    $locerror=1
                                    "No match found.This might be a typing error. Please press 1 or 2 (Or press'q' to exit)"
                                    
                                }
                               
                            
                                }
               
                }}
                
                catch{$Ev++
                Write-Host " `nIssue connecting to the file server. Please create the Folder Manually and assign the required permissions"
                $_ | Out-File C:\File_server_connectivity_error.txt -Append
                }	       
              }
            while((!$global:location) -or ($locerror -eq 1))
}


function getad_accounts{
    
    if ((($count -ge 1) -or ($count -eq 0)) -AND ($Newac -eq 1) )
			{  if($count -ge 1)

				        {  $Clients = $global:all_clients
                           Write-Host $count 'SFTP Accounts already exists for the' $Client
                           
                           
                                switch($Selection){
                                    1 {

                                     Get-ADUser -Filter {SurName -Like $Clients -and initials -NotLike "KC"}  -SearchBase "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -Properties Name, EmailAddress, SamAccountName, Description | Format-Table Name, EmailAddress, Name, SamAccountName, Description
                                       }

                                    2 {
                                         Get-ADUser -Filter {SurName -Like $Clients -and initials -Like "KC"}  -SearchBase "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -Properties Name, EmailAddress, SamAccountName, Description | Format-Table Name, EmailAddress, Name, SamAccountName, Description
                                      }
                                }

                                
                            $Newac = Read-Host "`nDo you want to create another SFTP Account for $Client ? (Press 1 to continue or Press any key to exit)"

                        if($Newac -ne 1)
                                {break}

                        else{Write-Host "`nCreate a another SFTP Account for $Client"}
                        }
                else
                    {
                        Write-Host "`nNo SFTP Account Exists for the Client. You can create a new account."}
            }

            
}


function read_client

{  $select = $Selection
    $clt = $client

    Write-Host "`nSearching Results for" $clt " .... `n"
    $Clients = '*'+ $clt+'*'
    $global:all_clients =$Clients

      switch($select){
        '1' {
                $Initials = " "
                $client_accounts =get-aduser -f {Initials -NotLike "KC" -and Surname -Like $Clients} -SearchBase "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" | measure
                $count=$client_accounts.Count
                Write-Host $count "Results Found - For Non KC Accounts"
                $Newac = 1
                getad_accounts
                get_location
                get_ticket_no
                get_owner_id
                set_newaccount
                generate_password
                create_user
                create_group
                create_folder
                send_email
        
               
            }

        '2' {
                
                $client_accounts =get-aduser -f {SurName -Like $Clients -and initials -Like "KC"} -SearchBase "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" | measure                             ##To find the number of accounts which have Surname and Initials as KC
		        $count=$client_accounts.Count                                                                                              ## Find the count.
                Write-Host $count "Results Found - For KC Accounts"
                $Newac = 1
                getad_accounts
                get_location
                get_ticket_no
                get_owner_id
                set_newaccount
                generate_password
                create_user
                create_group
                create_folder
                send_email
                pause
                

            }
            }

}


function search_client($client)
{
$client
}



do
    {
       Show-Menu
       $Selection = Read-Host "`nPlease make a selection"
       
       switch ($Selection)
       {
        
            1 {
                    "`nYou chose option #1 - To Add New SFTP Account (NON KC Account)"
                    $Ev = 0                                                             ##Error Code
                   
                                
                                $Client = Read-Host "Input the client Name"
                                $TextInfo = (Get-Culture).TextInfo
                                $Client = $TextInfo.ToTitleCase($Client).Replace(" ","")               
                                read_client

                                
                                
                                
                 }
                    
                 

            2 {
                    
                    "`nYou chose option #2 - To Add New SFTP Account (KC Account)"
                    $Ev = 0                                                             ##Error Code
                    
                                
                                    $Client = Read-Host "Input the client Name"
                                    $TextInfo = (Get-Culture).TextInfo
                                    $Client = $TextInfo.ToTitleCase($Client).Replace(" ","")
                                    read_client
                                   
                                   
                                    
              }
       }     
    
    }



until ($selection -eq 'q')