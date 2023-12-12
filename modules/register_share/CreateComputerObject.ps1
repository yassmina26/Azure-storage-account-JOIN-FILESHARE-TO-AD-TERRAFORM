param (
    [ValidateNotNullOrEmpty()] [string]$adUser,
    [ValidateNotNullOrEmpty()] [string]$adPwd,
    [ValidateNotNullOrEmpty()] [string]$computerName,
    [ValidateNotNullOrEmpty()] [string]$computerDscr,
    [ValidateNotNullOrEmpty()] [string]$server_ip_AD
)

#Import the Active Directory module and connect to the domain
Install-WindowsFeature -Name 'RSAT-AD-PowerShell' | Out-Null
Import-Module ActiveDirectory 3>$null
$WarningPreference = 'SilentlyContinue'
$ouPath = ""

# Create credentials for AD connection
$securePwd = ConvertTo-SecureString -String $adPwd -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($adUser, $securePwd)

try {
    $existingComputer = Get-ADComputer -Server $server_ip_AD -Credential $cred -Filter { Name -eq $computerName }
    if ($existingComputer) {
        # Computer object exists, get its SID
        $sid = $existingComputer.SID
    }
    else {
        # Computer object doesn't exist, create it
        New-ADComputer -Server $server_ip_AD -Name $computerName -Path $ouPath -Credential $cred -Description $computerDscr
        # Get SID of the newly created computer object
        $GetComputer = Get-ADComputer -Server $server_ip_AD -Credential $cred -Filter { Name -eq $computerName }
        $sid = $GetComputer.SID
    }

}
catch {
    throw "######## Failed to create the computer '$computerName'. Error: $($_)"
}
#Output the sid value
$output = @()
$output = @{
    sid = $sid.Value
} | ConvertTo-Json

Write-Output $output
