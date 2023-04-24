$userDate = Get-ComputerInfo | Select-object CsUserName, OsLocalDateTime
$logPath = "C:\log\userLog.csv"
$userCSVnew = @()
$userDelete = @()
$userObject = New-Object psobject
$date = (Get-Date).AddDays(-30)

<#Here you can specify accounts that do not need to be deleted.#>
$excludedUsers = "admin", "All Users", "Default", "Default User", "Все пользователи", "Public", "Общие"
if (!(test-Path $logPath)) {
    New-Item -ItemType directory -path 'c:\log'-erroraction 'silentlycontinue'
    $fileHidden = Get-Item 'c:\log'-Force
    $fileHidden.Attributes = 'Hidden'
    $users = Get-ChildItem "C:\users" | select Name
    foreach ($usersFolder in $users.name) {
        if (($excludedUsers -like $usersFolder)) {
            continue
        }
        else {
            <#Here you need to specify your domain#>
            $userCSVnew += $userObject | Select-Object @{name = "CsUserName"; expression = { "<#your domain#>\$usersFolder" } }, @{n = "OsLocalDateTime"; e = { Get-Date } }      
        }    
    }       
    $userCSVnew | Export-csv -path $logPath -NoTypeInformation 
}
else {
    $userCSVnew += $userDate
    $userCSV = import-csv -path $logPath
    foreach ($user in $userCSV) {
        if (($user.CsUserName.Length -gt 0)-and($userDate.CsUserName -ne $user.CsUserName) -and ((Get-date -date $user.OsLocalDateTime) -gt $date)) {
            $userCSVnew += $user
        }
        elseif (($user.CsUserName.Length -gt 0) -and ($userDate.CsUserName -ne $user.CsUserName) -and ((Get-date -date $user.OsLocalDateTime) -lt $date -and (test-path -Path ("C:\Users\" + ($user.CsUserName -split "\\")[1])))) {
            $userCSVnew += $user
            $userDelete += $user
        }
    }
    $userCSVnew | export-csv -path $logPath -NoTypeInformation

    if ($userDelete.Length -gt 0) {
        foreach ($profile in $userDelete) {
            $profileDel = ($profile.CsUserName -split "\\")[1]
            $path = "C:\Users\" + $profileDel
            cmd /c "rd /s /q $path"
        }
        cd hklm:\
        Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' | Where-Object Name -Like '*.bak' | ForEach-Object { Remove-Item -LiteralPath $_.Name -Recurse }

        $profileList = dir 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
        ForEach ($profile in $profileList) {
            if (!(Test-Path ($profile | gp | select -expand ProfileImagePath))) {       
                Remove-Item -LiteralPath $profile.Name -Recurse 
            }
        }
        cd c:\
    }    
}
