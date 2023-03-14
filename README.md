
# HelloID-Task-SA-Target-AzureActiveDirectory-AccountPasswordReset

## Prerequisites
Before using this snippet, verify you've met with the following requirements:

- [ ] AzureAD app registration
- [ ] The correct app permissions for the app registration.
      Note that in addition to the app permissions in de app registration itself (User.ReadWrite.all), the app must also be added tot the PasswordAdministrator role in Azure AD to be allowed to change the password.
- [ ] User defined variables: `AADTenantID`, `AADAppID` and `AADAppSecret` created in your HelloID portal.

## Description

This code snippet executes the following tasks:

1. Define a hash table `$formObject`. The keys of the hash table represent the properties of the `` cmdlet, while the values represent the values entered in the form.

> To view an example of the form output, please refer to the JSON code pasted below.

```json
{
   "UserPrincipalName": "testuser@mydomain.local",
   "password" : "mySecretpassword191287436235^",
   "ChangePasswordAtNextLogon" : true
}
```

> :exclamation: It is important to note that the names of your form fields might differ. Ensure that the `$formObject` hashtable is appropriately adjusted to match your form fields.

2. Receive a bearer token by making a POST request to: `https://login.microsoftonline.com/$AADTenantID/oauth2/token`, where `$AADTenantID` is the ID of your Azure Active Directory tenant.

3. Looks up the user in Azure by its UPN, by making a GET request to  `https://graph.microsoft.com/v1.0/users/$($formObject.userPrincipalName)`.  This is done to get the Objectid of the user in Azure.

4. Resets the password of the user.
