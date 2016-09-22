$APIRoot = "http://api.webhookinbox.com"

function Set-WebHookInboxID {
    param (
        $WebHookInboxID
    )
    $WebHookInboxID | Export-Clixml -Path $env:USERPROFILE\WebHookInboxID.txt
}

Function Get-WebHookInboxID {
    $WebHookInboxID = Import-Clixml $env:USERPROFILE\WebHookInboxID.txt
    
    if ($WebHookInboxID) { 
        $WebHookInboxID 
    } else { 
        Throw "No WebHookInboxID file was found at $env:USERPROFILE\WebHookInboxID.txt" 
    }
}

Function New-WebHookInbox {
    param (
        [ValidateSet("auto","wait-verify","wait")]$Response_Mode
    )
    $URI = "$APIRoot/create/"
    Invoke-RestMethod -Uri $URI -Method Post -Body $($PSBoundParameters | ConvertTo-URLEncodedQueryStringParameterString -MakeParameterNamesLowerCase)
}

Function Get-WebHookInboxContent {
    param (
        $InboxID = $(Get-WebHookInboxID),
        [ValidateSet("created","-created")]$Order,
        $Max,
        $Since
    )
    $URI = "$APIRoot/i/$InboxID/items"
    $Parameters = $PSBoundParameters
    $Parameters.Remove("InboxID") | Out-Null
    if ($Parameters.Count -gt 0) {
        $URI += "?" + $($Parameters | ConvertTo-URLEncodedQueryStringParameterString -MakeParameterNamesLowerCase)
    }
    
    Invoke-RestMethod -Method Get -Uri $URI
}

Function New-WebHookInboxContent {
    param (
        $InboxID = $(Get-WebHookInboxID),
        $Body,
        $QueryStringParamterString
    )
    $URI = "$APIRoot/i/$InboxID/in/?" + $QueryStringParamterString

    Invoke-RestMethod -Method Post -Uri $URI -Body $Body
}

Function New-WebHookInboxResponse {
    [CMDletBinding()]
    param (
        $InboxID = $(Get-WebHookInboxID),
        [Parameter(Mandatory)]$ItemID,
        $code,
        $reason,
        $headers,
        $body
    )
    $URI = "$APIRoot/i/$InboxID/respond/$ItemID/"
    $Parameters = $PSBoundParameters
    $Parameters.Remove("InboxID") | Out-Null
    $Parameters.Remove("ItemID") | Out-Null

    $WebHookAPIBody = $Parameters | ConvertTo-Json
    Write-Verbose $WebHookAPIBody
    Invoke-RestMethod -Method Post -Uri $URI -Body $WebHookAPIBody -ContentType "application/json"
}

#Function Get-WebHookInboxAPIURL {
#    param (
#        $InboxID = $(Get-WebHookInboxID),
#        [ValidateSet("refresh","respond","in","items","stream","Create")]$Subpart,
#        $QueryStringParamterString
#    )
#    "$APIRoot/i/$InboxID/in" + $QueryStringParamterString
#}

Function New-WebHookInboxAPIInputURL {
    param (
        $InboxID = $(Get-WebHookInboxID),        
        $QueryStringParamterString
    )
    "$APIRoot/i/$InboxID/in/?" + $QueryStringParamterString
}

Function Invoke-WebHookInboxView {
    param (
        $InboxID = $(Get-WebHookInboxID)
    )

    start "http://webhookinbox.com/view/$InboxID/"
}