# Get Credentials for connecting to exchange online
$Creds = Get-Credential

# Connects to Microsoft service / Azure AD to get all tenants
Connect-MsolService
$customers = Get-MsolPartnerContract -All
Write-Host "Found $($customers.Count) customers for this partner."

Import-Module ExchangeOnlineManagement
# Array used for keeping track of tenants we do not have access to or subscription lapsed
$ErrorMessageLogArray = @()
# Array used for audit status of tenant
$AuditEnabled = @()
# Loops through tenants and connects to Exchange Online with Modern Auth
foreach ($customer in $customers) {
    try{
        $InitalizeDomain = (Get-MsolDomain -TenantId $customer.TenantID | Where-Object {$_.isInitial}).name
        Write-Host "$($InitalizeDomain)"
        Write-Host "Checking Auditing for $($Customer.Name)"
    
        Connect-ExchangeOnline -UserPrincipalName $Creds.UserName -ShowProgress $true -DelegatedOrganization $InitalizeDomain -ShowBanner:$false
        $CheckAuditStatus = Get-AdminAuditLogConfig
        if ($CheckAuditStatus.UnifiedAuditLogIngestionEnabled -eq 'true') {
            $AuditMessage = "Auditing enabled for $($Customer.Name)"
            $AuditEnabled = $AuditEnabled + $AuditMessage
        }
        else {
            $AuditMessage = "Auditing disabled for $($Customer.Name)"
            $AuditEnabled = $AuditEnabled + $AuditMessage
        }
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    }
    catch {
        # Add to array for logging if we do not have permission for tenant or subscription has lapsed
        $message = $_
        Write-Warning "$message"
        $ErrorMessageLogArray = $ErrorMessageLogArray + $message

    }
}

# Used for displaying folder browser to choose file path for logging
# https://powershellone.wordpress.com/2016/05/06/powershell-tricks-open-a-dialog-as-topmost-window/
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$FolderBrowser.Description = 'Select the folder to save logging'
$result = $FolderBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
if ($result -eq [Windows.Forms.DialogResult]::OK){
    $SelectedFilePathErrorLogging = $FolderBrowser.SelectedPath + "\AuditStatusErrors.txt"
    $SelectedFilePathAuditStatus = $FolderBrowser.SelectedPath + "\AuditStatus.txt"
}

# Writes to file a list of the errors that were thrown
for ($i = 0; $i -lt $ErrorMessageLogArray.Length; $i++) {
    $ErrorMessageLogArray[$i] | Out-File -Append -FilePath $SelectedFilePathErrorLogging
}
# Writes to file tenants audit status
for ($i = 0; $i -lt $AuditEnabled.Length; $i++) {
    $AuditEnabled[$i] | Out-File -Append -FilePath $SelectedFilePathAuditStatus
}