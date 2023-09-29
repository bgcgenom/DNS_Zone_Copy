<#
File:
    DNS_Zone_Copy.ps1

Version: 1.1

Born on: 09/28/23

Last update: 09/29/23

Author: Patrick Benoit

Description:
    This is a synchronization script that allows a primary Windows Active
    Directory connected DNS's zones to be copied to a workgroup secondary
    DNS server.

    User defined variables:
        Enter the IP address for your DNS servers
            $primaryDnsServer
            $secondaryDnsServer

    Run this from a Domain joined workstation as Administrator,your
    administrative elevation acocunt should, at least, be a member of the
    domain DnsAdmins group.
    
    You will be prompted for the credentials of the
    secondary DNS server.  Use a local account that belongs to the Administrators
    group.
    
    Provide the credentials in the following format: servername\username
    Example: dnssec1\dnszsync

    For each zone you will be presented with the added or skipped message as well
    as a Zone Creation Totals count

    Note: This script will only copy primary zones.

Version History:
    09/28/23 0.1 -  Created initial script
    09/28/23 0.2 -  Added filter for Primary zones only
    09/29/23 1.0 -  Added condition to test if zone already exists on secondary
    09/29/23 1.1 -  Added color conditions for zones added (green text)
                    as well as skipped zones (yellow text with red background)
                    Added Zone Creation Totals report at the end to count added and
                    skipped zones.
#>

# Create counters for added and skipped zones
$countAdd = 0
$countSkipped = 0

# Define primary and secondary DNS server addresses
$primaryDnsServer = "Your primary DNS server IP here"
$secondaryDnsServer = "Your secondary DNS server IP here"

# Set crednetials for secondaryDnsServer
$credentials = Get-Credential -Message "Enter your credentials for the local secondary DNS server`nFormat: (computername\username)"

# Import the DNS module
Import-Module DnsServer

# Get all DNS zones from the primary server
$primanryzones = Get-DnsServerZone -ComputerName $primaryDnsServer

# Create remote session for $secondaryDnsServer
$session = New-PSSession -ComputerName $secondaryDnsServer -Credential $credentials

# Get all DNS zones from the secondary server
$secondaryzones = Invoke-Command -Session $session -ScriptBlock {
    param($secondaryDnsServer)
    Import-Module DnsServer
    # Add if statement to check if zone -ne existing secondary
    Get-DnsServerZone -ComputerName $secondaryDnsServer
} -ArgumentList $secondaryDnsServer

# Loop through each zone and add it to the secondary server
foreach ($zone in $primaryzones) {
    if ($zone.ZoneType -eq "Primary" -or $zone.ZoneName -ccontains "in-addr") {
        $zoneName = $zone.ZoneName
        $zoneType = $zone.ZoneType
    }

    # Check if the zone already exists on secondary
    if ($secondaryzones.ZoneName -contains $zoneName) {
        $countSkipped = $countSkipped + 1
        Write-Host "Skipping" $ZoneName", zone already exists on secondary." -BackgroundColor DarkRed -ForegroundColor yellow
    } else {
        # Add the zone to the secondary server
        Invoke-Command -Session $session -ScriptBlock {
            param($zoneName, $zoneType, $primaryDnsServer, $secondaryDnsServer)
            Import-Module DnsServer
            # Add if statement to check if zone -ne existing secondary
            Add-DnsServerSecondaryZone -Name $zoneName -ZoneFile "$zoneName.dns" -MasterServers $primaryDnsServer -ComputerName $secondaryDnsServer
        } -ArgumentList $zoneName, $zoneType, $primaryDnsServer, $secondaryDnsServer
        $countAdd = $countAdd + 1
        Write-Host "Added zone '$zoneName' ($zoneType) to secondary DNS server." -ForegroundColor Green
    }
}

# Create object with properties to contain the count results
$countResults = [PSCustomObject]@{
    Added = $countAdd
    Skipped = $countSkipped
}

# Display the count results
Write-Host "Zone creation totals"
$countResults | Format-Table -Property Added, Skipped -AutoSize
