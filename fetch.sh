#!/usr/bin/env bash
go get -u || exit $?
go mod tidy || exit $?

git clone https://github.com/FvDxxx/pfxaggr aggr && cd aggr && make -j$(nproc) && mv -f pfxaggr .. && cd .. && rm -fr aggr
rm -f ipv4.txt ipv6.txt

wget -O misakaio_chnroutes4.txt https://cdn.jsdelivr.net/gh/misakaio/chnroutes2@master/chnroutes.txt
wget -O gaoyifan_chnroutes4.txt https://cdn.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china.txt
wget -O 17mon_chnroutes4.txt    https://cdn.jsdelivr.net/gh/17mon/china_ip_list@master/china_ip_list.txt
cat misakaio_chnroutes4.txt >> ipv4.txt
cat gaoyifan_chnroutes4.txt >> ipv4.txt
cat 17mon_chnroutes4.txt    >> ipv4.txt
./pfxaggr < ipv4.txt > chnroutes4

curl -fsSL http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest | grep CN | grep ipv6 | awk -F'|' '{printf("%s/%d\n", $4, $5)}' > apnic_chnroutes6.txt
wget -O clang_chnroutes6.txt    https://ispip.clang.cn/all_cn_ipv6.txt
wget -O gaoyifan_chnroutes6.txt https://cdn.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china6.txt
cat apnic_chnroutes6.txt    >> ipv6.txt
cat clang_chnroutes6.txt    >> ipv6.txt
cat gaoyifan_chnroutes6.txt >> ipv6.txt
./pfxaggr < ipv6.txt > chnroutes6

echo 'ip firewall address-list remove [find list=China]' > chnroutes4.rsc
while read -r i; do
    echo "ip firewall address-list add list=China address=$i" >> chnroutes4.rsc
done < chnroutes4

echo 'ipv6 firewall address-list remove [find list=China]' > chnroutes6.rsc
while read -r i; do
    echo "ipv6 firewall address-list add list=China address=$i" >> chnroutes6.rsc
done < chnroutes6
exit 0
