
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

$userpass = $user+":"+$Password
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($userpass)
    $encoded = [system.convert]::ToBase64String($bytes)

    ## Defines the header section of the API call
    $headers = @{
        Authorization = "Basic $encoded"
        }
        $encoded
Invoke-RestMethod -Method get -Uri "https://tms.com:5443/smserver-testing/auth" -Headers $headers