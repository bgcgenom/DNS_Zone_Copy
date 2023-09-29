# DNS_Zone_Copy
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
