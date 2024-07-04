

<#
.SYNOPSIS
    Gets the groups info related to a user
.DESCRIPTION
    This function checks if the user exists or not, and if exists returns the groups information he is part of.
.PARAMETER UserId
    The userId of the user for which groups need to be fetched
.EXAMPLE
    Get-GroupOfUser -UserId "userId"
#> 


function Get-GroupOfUser {
    param(
        [Parameter(Mandatory = $true)][string]$UserId
    )

    # Ensure the necessary module is loaded
    if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
        Write-Error "Microsoft.Graph module is not installed. Please install it using 'Install-Module Microsoft.Graph'."
        return
    }


    # Check the required scopes
    $requiredScopes = @("User.Read.All", "Group.Read.All")
    $tokenScopes = (Get-MgContext).Scopes
    $missingScopes = $requiredScopes | Where-Object { $_ -notin $tokenScopes }
    if ($missingScopes.Count -gt 0) {
        Write-Error "Missing required scopes: $($missingScopes -join ', '). Please ensure you have the necessary permissions."
        return
    }

    try {

        # Get the user
        $user = Get-MgUser -UserId $UserId -ErrorAction Stop

        if (-not $user) {
            Write-Error "User with ID $UserId does not exist."
            return
        }

        # Get the groups that the user is a member of
        $groupIds = Get-MgUserMemberOf -UserId $UserId -ErrorAction Stop | ForEach-Object {
            $_.Id
        }
        
        $groups = @()
        foreach ($groupId in $groupIds) {
            $group = Get-MgGroup -GroupId $groupId -ErrorAction SilentlyContinue
            if ($group) {
                $groups += $group
            }
        }

        return @{
            User = $user
            Groups = $groups
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}
