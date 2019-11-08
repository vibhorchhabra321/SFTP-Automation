
function Show-Menu
{
    param (
        [string]$Title = 'SFTP Account Management System'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to Create New SFTP Account."
    Write-Host "2: Press '2' to Find SFTP accounts for a particular Client."
    Write-Host "3: Press '3' to Delete exisiting SFTP Account."
    Write-Host "Q: Press 'Q' to quit."
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    'You chose option #1 - To Add New SFTP Account
    '
        
        $Client = Read-Host "Input the client Name"
        $Ev = 0

	try{if($Ev -eq 0){
        $Client
		$Clients = $Client+'*'
		$client_accounts =get-aduser -f {SurName -Like $Clients} | measure
		$XX=$client_accounts.Count
        $XX
        $Newac = 1
		if ((($XX -ge 1) -or ($XX -eq 0)) -AND ($Newac -eq 1) )
			{  if($XX -ge 1)

				{Write-Host $XX 'SFTP Accounts already exists for the' $Client
                Get-ADUser -f {SurName -Like $Clients} -Properties Name, EmailAddress, SamAccountName, Description | Format-Table Name, EmailAddress, Name, SamAccountName, Description
                
                $Newac = Read-Host "Do you want to create another SFTP Account for $Client ? (Press 1 to continue or Press any key to exit)"

                if($Newac -ne 1)
                {break}

                else{Write-Host "Create a another SFTP Account for $Client"}
                }
            else
            {
            Write-Host "No SFTP Account Exists for the Client. You can create a new account."}
        

			$location = Read-Host -Prompt "Enter the SFTP Account Location"
			$CaseNo = Read-Host -Prompt "Enter the Case No (RITM/ Incident No.)"
			$email = Read-Host -Prompt "Enter the Account Owner email"
			
					
					$FirstName = "SFTP"
					$LastName = $Client
                    $XX++
                    $Name = $FirstName + " " +$Lastname + $XX
                    $displayname = $Name
                    $endname = $Client + $XX
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
                    clear
                    Write-Host " You have successfully create the SFTP Account, below are the Details:"
                    Write-Host "User Account Details:"
                    Get-ADUser $useraccount -Properties UserPrincipalName, SurName, EmailAddress, Description |Select-Object UserPrincipalName, SurName, EmailAddress, Description
                    }}
					
					catch{
                    $Ev++
                    Write-Host "*****************ERROR FOUND - Delete the Account (Refer C:\Adding_User_errors.txt for Error)***************"
					Write-Host "There is some error while creating a Account"
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
                    Write-Host "User Account Created"
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



    } '2' {
    'You chose option #2'
    } '3' {
      'You chose option #3'
    }
    }
    pause
 }
 until ($selection -eq 'q')