# HelloID-Task-SA-Target-AzureActiveDirectory-AccountPasswordReset
########################################################################
# Form mapping
$formObject = @{
    userPrincipalName             = $form.UserPrincipalName
    password                      = $form.password
    forceChangePasswordNextSignIn = [bool] $form.ChangePasswordAtNextLogon
}
try {
    Write-Information "Executing AzureActiveDirectory action: [AccountPasswordReset] for: [$($formObject.userPrincipalName)]"

    # Action logic here
    Write-Information "Retrieving Microsoft Graph AccessToken for tenant: [$AADTenantID]"
    $splatTokenParams = @{
        Uri         = "https://login.microsoftonline.com/$AADTenantID/oauth2/token"
        ContentType = 'application/x-www-form-urlencoded'
        Method      = 'POST'
        Verbose     = $false
        Body        = @{
            grant_type    = 'client_credentials'
            client_id     = $AADAppID
            client_secret = $AADAppSecret
            resource      = 'https://graph.microsoft.com'
        }
    }

    $accessToken = (Invoke-RestMethod @splatTokenParams).access_token
    $splatGetUserParams = @{
        Uri     = "https://graph.microsoft.com/v1.0/users/$($formObject.userPrincipalName)"
        Method  = 'GET'
        Verbose = $false
        Headers = @{
            Authorization  = "Bearer $accessToken"
            Accept         = 'application/json'
            'Content-Type' = 'application/json'
        }
    }
    $azureADUser = Invoke-RestMethod @splatGetUserParams
}
catch {
    Write-Error "Could not execute AzureActiveDirectory action [AccountPasswordReset] for: [$($formObject.userPrincipalName)]. User not found in the directory. Error: [$($_.Exception.Message)], Details : [$($_.Exception.ErrorDetails)]"
    return
}

try {
    Write-Information "Executing AzureActiveDirectory action: [AccountPasswordReset] for: [$($formObject.userPrincipalName)]"


    $splatResetPasswordParams = @{
        Uri     = "https://graph.microsoft.com/v1.0/users/$($azureADUser.id)"
        Method  = 'PATCH'
        Body    = [PSCustomObject]@{
            id              = $azureADUser.id
            passwordProfile = @{
                password                      = $formObject.password
                forceChangePasswordNextSignIn = $formObject.forceChangePasswordNextSignIn
            }
        } | ConvertTo-Json -Depth 10
        Verbose = $false
        Headers = @{
            Authorization  = "Bearer $accessToken"
            Accept         = 'application/json'
            'Content-Type' = 'application/json'
        }
    }

    $null = Invoke-RestMethod @splatResetPasswordParams


    $auditLog = @{
        Action            = 'SetPassword'
        System            = 'AzureActiveDirectory'
        TargetIdentifier  = "$($azureADUser.id)"
        TargetDisplayName = "$($formObject.userPrincipalName)"
        Message           = "AzureActiveDirectory action: [AccountPasswordReset] for: [$($formObject.userPrincipalName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags 'Audit' -MessageData $auditLog
    Write-Information "AzureActiveDirectory action: [AccountPasswordReset] for: [$($formObject.userPrincipalName)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = 'SetPassword'
        System            = 'AzureActiveDirectory'
        TargetIdentifier  = "$($azureADUser.id)"
        TargetDisplayName = "$($formObject.userPrincipalName)"
        Message           = "Could not execute AzureActiveDirectory action: [AccountPasswordReset] for: [$($formObject.userPrincipalName)], error: $($ex.Exception.Message) details : [$($ex.ErrorDetails.message)]"
        IsError           = $true
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute AzureActiveDirectory action: [AccountPasswordReset] for: [$($formObject.userPrincipalName)], error: $($ex.Exception.Message) details : [$($ex.ErrorDetails.message)])"
}
########################################################################
