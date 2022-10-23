#!/usr/bin/env bash
wget -O misakaio_chnroutes4.txt https://cdn.jsdelivr.net/gh/misakaio/chnroutes2@master/chnroutes.txt
wget -O gaoyifan_chnroutes4.txt https://cdn.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china.txt
wget -O 17mon_chnroutes4.txt    https://cdn.jsdelivr.net/gh/17mon/china_ip_list@master/china_ip_list.txt

rm -f ipv4.txt
cat misakaio_chnroutes4.txt >> ipv4.txt
cat gaoyifan_chnroutes4.txt >> ipv4.txt
cat 17mon_chnroutes4.txt    >> ipv4.txt
./pfxaggr < ipv4.txt > chnroutes4
rm -f *.txt

wget -O gaoyifan_chnroutes6.txt https://cdn.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china6.txt

rm -f ipv6.txt
cat gaoyifan_chnroutes6.txt >> ipv6.txt
./pfxaggr < ipv6.txt > chnroutes6
rm -f *.txt
exit 0
