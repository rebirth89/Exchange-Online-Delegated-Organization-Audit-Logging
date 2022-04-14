# Exchange-Online-Delegated-Organization-Audit-Logging
PowerShell script to enable audit logging on all delegated organizatons.


The first script, "Check Organization Customization" will check the status of Organization Customization within the current delegated organization in the array of all delegated organization. Organization Customization is a pre-requisite of enabling audit logging. If Organization Customization is disabled within the tenant, it will be enabled. If it is already enabled, it will be ignored via an error prompt.

The second script, "Check Audit Logging" will loop through all delegated organizations again and check if audit logging is already enabled. If a tenant already has audit logging enabled the tenant name will be added to an array. If not, they will be ignored. Once the script has finished an output text file will be generated showing all tenants that have audit logging enabled.

The last script, "Enable Audit Logging" will again loop through all delegated organizations and attempt to enable audit logging if it is not enabled. If it fails it will output the error into an error logging text file at the end of the script. If it is successful the script will display so during run-time. Ensure you have full access to the all delegated organizations and tenants or errors may be thrown for said tenant.
