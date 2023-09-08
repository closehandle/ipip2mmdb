#!/usr/bin/env bash
go get -u ./... || exit $?
go mod tidy || exit $?

git clone https://github.com/FvDxxx/pfxaggr aggr && cd aggr && make -j$(nproc) && mv -f pfxaggr .. && cd .. && rm -fr aggr
rm -f ipv4.txt ipv6.txt

wget -O misakaio_chnroutes4.txt https://cdn.jsdelivr.net/gh/misakaio/chnroutes2@master/chnroutes.txt
wget -O 17mon_chnroutes4.txt    https://cdn.jsdelivr.net/gh/17mon/china_ip_list@master/china_ip_list.txt
cat misakaio_chnroutes4.txt >> ipv4.txt
cat 17mon_chnroutes4.txt    >> ipv4.txt
./pfxaggr < ipv4.txt > chnroutes4

curl -fsSL http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest | grep CN | grep ipv6 | awk -F'|' '{printf("%s/%d\n", $4, $5)}' > apnic_chnroutes6.txt
wget -O clang_chnroutes6.txt    https://ispip.clang.cn/all_cn_ipv6.txt
cat apnic_chnroutes6.txt    >> ipv6.txt
cat clang_chnroutes6.txt    >> ipv6.txt
./pfxaggr < ipv6.txt > chnroutes6

echo 'create chnroutes4 hash:net family inet' > chnroutes4.ipset
cat chnroutes4 | awk '{printf("add chnroutes4 %s\n", $1)}' >> chnroutes4.ipset
echo "create chnroutes6 hash:net family inet6" > chnroutes6.ipset
cat chnroutes6 | awk '{printf("add chnroutes6 %s\n", $1)}' >> chnroutes6.ipset

echo 'ip firewall address-list remove [find list=China]' > chnroutes4.rsc
while read -r i; do
    echo "ip firewall address-list add list=China address=$i" >> chnroutes4.rsc
done < chnroutes4
echo 'ipv6 firewall address-list remove [find list=China]' > chnroutes6.rsc
while read -r i; do
    echo "ipv6 firewall address-list add list=China address=$i" >> chnroutes6.rsc
done < chnroutes6

gfwlist=$(curl -fsSL https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt)
[[ $? -ne 0 ]] && exit 1

gfwlist=$(echo "${gfwlist}" | base64 -d | grep -vE '^\!|\[|^@@|(https?://){0,1}[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sed -r 's#^(\|\|?)?(https?://)?##g' | sed -r 's#/.*$|%2F.*$##g' | grep -E '([a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z0-9][-a-zA-Z0-9]*)+)' | sed -r 's#^(([a-zA-Z0-9]*\*[-a-zA-Z0-9]*)?(\.))?([a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z0-9][-a-zA-Z0-9]*)+)(\*[a-zA-Z0-9]*)?#\4#g')
for i in $gfwlist; do
    echo "ip dns static add address-list=gfwlist match-subdomain=yes name=\"${i}\" type=FWD" >> gfwlist.rsc
done
exit 0
