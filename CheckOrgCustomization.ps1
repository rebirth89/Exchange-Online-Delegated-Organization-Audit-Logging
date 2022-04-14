# Connects to Microsoft service / Azure AD to get all tenants
Connect-MsolService
$customers = Get-MsolPartnerContract -All
Write-Host "Found $($customers.Count) customers for this partner."

Import-Module ExchangeOnlineManagement
# Array used for keeping track of tenants we do not have access to or subscription lapsed
$NoTenantAccess = @()
# Loops through tenants and connects to Exchange Online with Modern Auth
foreach ($customer in $customers) {
    try{
        $InitalizeDomain = (Get-MsolDomain -TenantId $customer.TenantID | Where-Object {$_.isInitial}).name
        Write-Host "$($InitalizeDomain)"
        Write-Host "Checking Auditing for $($Customer.Name)"
    
        Connect-ExchangeOnline -UserPrincipalName jleeman@macatawatechnologies.com -ShowProgress $true -DelegatedOrganization $InitalizeDomain
        Enable-OrganizationCustomization
    }
    catch [system.exception]{
        $ErrorMessage = "No Permission for tenant or subscription lapsed $($Customer.Name)"
        # Add to array if we do not have permission for tenant or subscription has lapsed
        $NoTenantAccess = $NoTenantAccess + $ErrorMessage
        Write-Host $ErrorMessage
    }
}
# Writes to file the tenants that we do not have access to or subscription lapsed
for ($i = 0; $i -lt $NoTenantAccess.Length; $i++) {
    $NoTenantAccess[$i] | Out-File -Append -FilePath C:\Users\jleeman\Downloads\Test.txt
}
