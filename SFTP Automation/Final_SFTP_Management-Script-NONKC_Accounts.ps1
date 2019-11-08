
function Show-Menu
{
    param (
        [string]$Title = 'SFTP Account Management System'
    )
    $av= 1
    Clear-Host
    Write-Host "================ $Title ================"
   
    Write-Host "1: Press '1' to Create New SFTP Account.***NON KC ACCOUNT**"
    Write-Host "2: Press '2' to Create New SFTP Account (KC Owned Account)"
    Write-Host "3: Press '3' to Find SFTP accounts for a particular Client."
    Write-Host "3: Press '4' to Delete exisiting SFTP Account."
    Write-Host "Q: Press 'Q' to quit."
}

do
 { 
    Show-Menu
    $av
    $selection = Read-Host "`nPlease make a selection"
    switch ($selection)
    {
    '1' {
    "`nYou chose option #1 - To Add New SFTP Account (NON KC Account)
    "
        
        $Client = Read-Host "Input the client Name"
        $Ev = 0                                              #

	try{if($Ev -eq 0){
        Write-Host "`nSearching Results for" $Client " .... `n"
		$Clients = $Client+'*'
		$client_accounts =get-aduser -f {SurName -Like $Clients} | measure
		$XX=$client_accounts.Count
        Write-Host $XX "Results Found"
        $Newac = 1
		if ((($XX -ge 1) -or ($XX -eq 0)) -AND ($Newac -eq 1) )
			{  if($XX -ge 1)

				{Write-Host $XX 'SFTP Accounts already exists for the' $Client
                Get-ADUser -f {SurName -Like $Clients} -Properties Name, EmailAddress, SamAccountName, Description | Format-Table Name, EmailAddress, Name, SamAccountName, Description
                
                $Newac = Read-Host "`nDo you want to create another SFTP Account for $Client ? (Press 1 to continue or Press any key to exit)"

                if($Newac -ne 1)
                {break}

                else{Write-Host "`nCreate a another SFTP Account for $Client"}
                }
            else
            {
            Write-Host "`nNo SFTP Account Exists for the Client. You can create a new account."}
        
            do{
			$location = Read-Host -Prompt "`nEnter the SFTP Account Location (CA / UK). Press 1 for UK. Press 2 for CA"
            $locerror = 0
              
              #################### Connecting to the Network Share ########################################           
            
            try{if($Ev -eq 0){
                    

                switch($location){
		                1 {
                                If (!(Test-Path K:))
                                    {New-PSDrive -Name "K" -PSProvider FileSystem -Root "E:\ftpuk-corp"
                                    "You have selected UK Location. We are connecting to the UK File Server"
                                    }                                                                                     ## To Attach the network share as a map drive.
                           }

		                2 {
		                        If (!(Test-Path K:))
                                    {New-PSDrive -Name "K" -PSProvider FileSystem -Root "E:\ftp-corp"
                                    "You have selected CA Location. We are connecting to the CA File Server"
                                    }                                                                                      ## To Attach the network share as a map drive.
                            }
                       Default {
                                    $locerror=1
                                    "No match found.This might be a typing error. Please enter"
                                }
                                
                            
                                }
               
                }}
                
                catch{$Ev++
                Write-Host " `nIssue connecting to the file server. Please create the Folder Manually and assign the required permissions"
                $_ | Out-File C:\File_server_connectivity_error.txt -Append
                }	

##############################################################################################
              
              
              
              }
            while((!$location) -or ($locerror -eq 1))



                
             do{          
			$CaseNo = Read-Host -Prompt "`nEnter the Case No (RITM/ Incident No.)"
               }
            while(!$CaseNo)

            
            do{
			$email = Read-Host -Prompt "`nEnter the Account Owner email"
	          }
            while(!$email)
            
 
					
					$FirstName = "SFTP"
					$LastName = $Client
                    $XX++
                    $Name = $FirstName + " " +$Lastname + $XX
                    $displayname = $Name
                    $endname = $Client + $XX
					$useraccount =$FirstName.ToLower() + "-"+$endname
					$useraccount
                    if($location -eq 1)
					{$desc = $CaseNo + " | UK "}
                    else
                    {$desc = $CaseNo + " | CA "}
					$desc
					$OwnerFirstName = $email.Split()
					$OwnerFirstName
                    
					$groupname = $useraccount + "-group"
					$groupname
					
                    try{if($Ev -eq 0){
                    Add-Type -AssemblyName System.Web
					$PW = [System.Web.Security.Membership]::GeneratePassword(12,5)
					$PW
					$SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
					$SecurePass
                    }}
                    catch{
                    $Ev++
                    $_ | Out-File C:\Password_generation_error.txt -Append
                    }

                    $Fullusername= "$useraccount@tms.com"
                    $Fullusername
					try{if($Ev -eq 0){
                    New-ADUser -Name $Name -GivenName $FirstName -SurName $LastName -SamAccountName $useraccount -UserPrincipalName $useraccount"@tms.com" -Description $Desc -DisplayName $displayname -Path "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -EmailAddress $email -AccountPassword $SecurePass -Enabled $true
                    
                    Write-Host " `nYou have successfully create the SFTP Account, below are the Details:"
                    Write-Host "`nUser Account Details:"
                    Get-ADUser $useraccount -Properties UserPrincipalName, SurName, EmailAddress, Description |Select-Object UserPrincipalName, SurName, EmailAddress, Description
                    }}
					
					catch{
                    $Ev++
                    Write-Host "`n*****************ERROR FOUND - Delete the Account (Refer C:\Adding_User_errors.txt for Error)***************"
					Write-Host "`nThere is some error while creating a Account"
                    $_ | Out-File C:\Adding_User_errors.txt -Append

					}
                    
                    try{if($Ev -eq 0){
                    New-ADGroup -Path "OU=SFTP-GROUPS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -DisplayName $groupname -Name  $groupname  -SamAccountName $groupname -Description $desc -GroupScope Global
                    Add-ADGroupMember $groupname $useraccount
                    Write-Host ""
                    Write-Host "Group Details:"
                    Get-ADGroup $groupname -Properties Name, SamAccountName | Format-Table Name, SamAccountName
                    }}
                    catch{
                    $Ev++
                     
                    Write-Host "`n*****************ERROR FOUND - Delete the Account (Refer C:\Adding_Group_errors.txt for Error)***************"
					Write-Host "`nThere is some error while creating a Account"
                    $_ | Out-File C:\Adding_Group_errors.txt -Append

					}
                


			
                
                

                try{if($Ev -eq 0){
                    
                    $foldername = $endname+"Data"
                    New-Item -Path K:\$foldername -ItemType Directory
                    $Acl = Get-Acl "K:\$foldername"
                    $Ar = New-Object  System.Security.AccessControl.FileSystemAccessRule($groupname,'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
                    $Acl.SetAccessRule($Ar)
                    Set-Acl "K:\$foldername" $Acl
                    Remove-PSDrive K
                    }

                    }
                    catch{
                    $Ev++
                    Write-Host "`n*****************ERROR FOUND - Delete the Account (Refer C:\Adding_folder_errors.txt for Error)***************"
					Write-Host " `nThere is some error while creating a Folder"
                    $_ | Out-File C:\Adding_folder_errors.txt -Append

					}
                    Write-Host "`nUser Account Created"
                    Write-Host "`nUser Folder Created"
                    Write-Host "`nModify Access Granted to the group"
                    Write-Host " Created Password" $PW

                    Write-Host "`n**************** Now Create a VFS & User in Syncplify*********************************"
                    Write-Host "`nClick Continue to get the Password and Add it to Secret Server"
                    $Body | Out-File C:\Password.txt 
                     try{if($Ev -eq 0){    

                    $EmailFrom = "vibdon123456789@gmail.com"
                    $EmailTo = "vibhor.rc@gmail.com" 
                    $Subject = "$username Credentials" 
                    $Body = @"
                            Hi $email,

                            Please find below the newly created SFTP Account from $Client :
                            Hostname: ftp-corp.rms.com
                            Username: $Fullusername
                            Password: $PW
                            Port : 22

                            In case of any concern, please reach out to us @ rmsnoc@rms.com or call us at 7030.
"@
                    $SMTPServer = "smtp.gmail.com" 
                    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
                    $SMTPClient.EnableSsl = $true 
                    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("vibdon123456789", "bgsinternational"); 
                     Write-Host "Credentials have been successfully sent to the user"
                     Write-Host "Press q to quit." 
                ##     $From = "vibhor.chhabra@rms.com"
                ##     $To = "vibhor.rc@gmail.com"
                 ##   $Subject = "$use"
                  ###  $Body = "This is password is $PW"
                  ##  $SMTPServer = "Eun-smtp.prd.rmsonecloud.net"
                 ##   $SMTPPort = "587"
                    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
                    
                    }}
                    catch{
                    $Ev++
                    Write-Host "`n*****************ERROR while sending email (Refer C:\error-sending-email.txt for Error)***************"
					Write-Host " `nThere is some error while creating a Folder"
                    $_ | Out-File C:\error-sending-email.txt -Append

					}
                    


	  }
else {break}
}}
	catch{
		Write-Host "`nNo account Found or there is some error validating the account"
        $_ | Out-File C:\Main_try_error.txt -Append
		}



    } 
    
    
    '2' {
    
"`nYou chose option #2 - To Add New SFTP Account ( KC Account)
    "
        
        $Client = Read-Host "`nInput the client Name"
        $Ev = 0

	try{if($Ev -eq 0){
        $Client
		$Clients = $Client+'*'
		$client_accounts =get-aduser -f {SurName -Like $Clients -and initials -Like "KC"} | measure                             ##To find the number of accounts which have Surname and Initials as KC
		$XX=$client_accounts.Count                                                                                              ## Find the count.
        $XX
        $Newac = 1
		if ((($XX -ge 1) -or ($XX -eq 0)) -AND ($Newac -eq 1) )                                                                  ## condition to check if the account already exists. If yes, does the user require another new account for same client.
			{  if($XX -ge 1)                                                                                                    ## Account Already Exist condition.

				{Write-Host $XX '`nSFTP Accounts already exists for the' $Client
                Get-ADUser -f {SurName -Like $Clients} -Properties Name, EmailAddress, SamAccountName, Description | Format-Table Name, EmailAddress, Name, SamAccountName, Description
                
                $Newac = Read-Host "Do you want to create another SFTP Account for $Client ? (Press 1 to continue or Press any key to exit)"      ##If user require new account, set value of $Newac = 1

                if($Newac -ne 1)                                                                                                 ##Account already exists, Send message to the user that they are requesting another new account for a particular client.
                {break}

                else{Write-Host "`nCreate a another SFTP Account for $Client"}
                }
            else
            {
            Write-Host "`nNo SFTP Account Exists for the Client. You can create a new account."}
        

			$location = Read-Host -Prompt "`nEnter the SFTP Account Location (CA / UK)"
                if(!$location)
                {Write-Host "You need to enter the location: Mandatory Field" 
                break}
			$CaseNo = Read-Host -Prompt "Enter the Case No (RITM/ Incident No.)"
			$email = Read-Host -Prompt "Enter the Account Owner email"
			
					
					$FirstName = "SFTP"
					$LastName = $Client
                    $XX++
                    $Name = $FirstName + " " +$Lastname +"KC"+ $XX
                    $displayname = $Name
                    $endname = $Client + "KC" + $XX
					$useraccount =$FirstName.ToLower() + "-"+$endname
					$useraccount
					$desc = $CaseNo + " | "+ $location
					$desc
					$OwnerFirstName = $email.Split()
					$OwnerFirstName
                    
					$groupname = $useraccount + "-group"
					$groupname
					
                    try{if($Ev -eq 0){
                    Add-Type -AssemblyName System.Web
					$PW = [System.Web.Security.Membership]::GeneratePassword(12,5)
					$PW
					$SecurePass = $PW | ConvertTo-SecureString -AsPlainText -Force
     
                    }}
                    catch{
                    $Ev++
                    $_ | Out-File C:\Password_generation_error.txt -Append
                    }

                    $Fullusername= "$useraccount@tms.com"
                    $Fullusername
					try{if($Ev -eq 0){
                    New-ADUser -Name $Name -GivenName $FirstName -SurName $LastName -SamAccountName  $useraccount -Initials "KC" -UserPrincipalName $useraccount"@tms.com" -Description $Desc -DisplayName $displayname -Path "OU=SFTP-USERS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -EmailAddress $email -AccountPassword $SecurePass -Enabled $true
                    clear
                    Write-Host " You have successfully create the SFTP Account, below are the Details:"
                    Write-Host "User Account Details:"
                    Get-ADUser $useraccount -Properties UserPrincipalName, Initials, SurName, EmailAddress, Description |Select-Object UserPrincipalName, Initials, SurName, EmailAddress, Description
                    Write-Host " Created Password" $SecurePass
                    }}
					
					catch{
                    $Ev++
                    Write-Host "*****************ERROR FOUND - Delete the Account (Refer C:\Adding_User_errors.txt for Error)***************"
					Write-Host "There is some error while creating a Account"
                    $_ | Out-File C:\Adding_User_errors.txt -Append

					}
                    
                    try{if($Ev -eq 0){
                    New-ADGroup -Path "OU=SFTP-GROUPS,OU=SFTP,OU=Security Groups,DC=tms,DC=com" -DisplayName $groupname -Name  $groupname  -SamAccountName $groupname -Description $desc -GroupScope Global
                    Add-ADGroupMember $groupname $useraccount, KC_SFTP_Access
                    Write-Host ""
                    Write-Host "Group Details:"
                    Get-ADGroup $groupname -Properties Name, SamAccountName | Format-Table Name, SamAccountName
                    }}
                    catch{
                    $Ev++
                    Write-Host "*****************ERROR FOUND - Delete the Account (Refer C:\Adding_Group_errors.txt for Error)***************"
					Write-Host "There is some error while creating a Account"
                    $_ | Out-File C:\Adding_Group_errors.txt -Append

					}


			
                try{if($Ev -eq 0){

                switch($location){
		UK {
                If (!(Test-Path K:))
                {New-PSDrive -Name "K" -PSProvider FileSystem -Root "E:\ftpuk-corp"}    ## To Attach the network share as a map drive.
                }
		CA {
		If (!(Test-Path K:))
                {New-PSDrive -Name "K" -PSProvider FileSystem -Root "E:\ftp-corp"}    ## To Attach the network share as a map drive.
                }
                }
                }}
                catch{$Ev++
                Write-Host "Issue connecting to the file server. Please create the Folder Manually and assign the required permissions"
                $_ | Out-File C:\File_server_connectivity_error.txt -Append
                }

                try{if($Ev -eq 0){
                    
                    $foldername = $endname+"Data"
                    New-Item -Path K:\$foldername -ItemType Directory
                    $Acl = Get-Acl "K:\$foldername"
                    $Ar = New-Object  System.Security.AccessControl.FileSystemAccessRule($groupname,'Modify','ContainerInherit,ObjectInherit', 'None', 'Allow')
                    $Acl.SetAccessRule($Ar)
                    Set-Acl "K:\$foldername" $Acl
                    Remove-PSDrive K                                      #Remove the Mapped Drive from the System.
                    Write-Host "User Account Created"
                    $SecurePass
                    Write-Host "User Folder Created"
                    Write-Host "Modify Access Granted to the group"

                    Write-Host "**************** Now Create a VFS & User in Syncplify*********************************"
                    Write-Host "Click Continue to get the Password and Add it to Secret Server"
                    



                    $EmailFrom = "vibdon123456789@gmail.com"
                    $EmailTo = "vibhor.rc@gmail.com" 
                    $Subject = "$username Credentials" 
                    $Body = @"
                            Hi $email,

                            Please find below the newly created SFTP Account from $Client :
                            Hostname: ftp-corp.rms.com
                            Username: $Fullusername
                            Password: $PW
                            Port : 22

                            In case of any concern, please reach out to us @ rmsnoc@rms.com or call us at 7030.
"@
                    $SMTPServer = "smtp.gmail.com" 
                    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
                    $SMTPClient.EnableSsl = $true 
                    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("vibdon123456789", "bgsinternational"); 
                    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

                   
                    
                 ##  $From = "vibdon123456789@gmail.com"
                 ##     $To = "vibhor.rc@gmail.com"
                 ##   $Subject = "$use"
                   ## $Body = "This is password is $PW"
                  ##  $SMTPServer = "smtp.gmail.com"
                  ##  $SMTPPort = "587"
                  ##  Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl $true -Credential (Get-Credential) -DeliveryNotificationOption OnSuccess

                    }}
                    catch{
                    $Ev++
                    Write-Host "*****************ERROR FOUND - Delete the Account (Refer C:\Adding_folder_errors.txt for Error)***************"
					Write-Host "There is some error while creating a Folder"
                    $_ | Out-File C:\Adding_folder_errors.txt -Append

					}


	  }
else {break}
}}
	catch{
		Write-Host "No account Found or there is some error validating the account"
        $_ | Out-File C:\Main_try_error.txt -Append
		}


    } '3' {
      'You chose option #3'
    }
    }
    pause
 }
 until ($selection -eq 'q')