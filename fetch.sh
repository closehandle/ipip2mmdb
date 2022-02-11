#!/usr/bin/env bash
{
    wget -q -O ipv4.txt https://cdn.jsdelivr.net/gh/17mon/china_ip_list@master/china_ip_list.txt
}

{
    data=$(curl -fsSL http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest)

    {
        echo "$data" | grep CN | grep ipv6 | awk -F'|' '{printf("%s/%d\n", $4, $5)}'
    } > ipv6.txt
}

exit 0
