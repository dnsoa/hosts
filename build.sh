#!/usr/bin/env bash

set -e

url_list=(
"https://gcore.jsdelivr.net/gh/AdAway/adaway.github.io@master/hosts.txt" "adaway.txt"
"https://gcore.jsdelivr.net/gh/jdlingyu/ad-wars@master/hosts" "jdlingyu.txt"
"https://gcore.jsdelivr.net/gh/privacy-protection-tools/anti-AD@master/anti-ad-domains.txt" "privacy-protection-tools.txt"
)

for i in ${!url_list[@]}
do
    if [ `expr $i % 2` = "1" ]
    then
        url=${url_list[$i - 1]}
        name=${url_list[$i]}
        http_code=`curl --connect-timeout 7 $url -o host.tmp -s -w %{http_code}`
        if [ $http_code -eq 0 ];then
            echo "$url -> timeout"
        elif [ $http_code -eq 200 ];then
            \cp host.tmp $name
        else
            echo "$url -> $http_code"
        fi
        unlink host.tmp
    fi
done

if [[ -f "privacy-protection-tools.txt" ]]; then
    sed -i '5,$s/^/0.0.0.0 \0/g' privacy-protection-tools.txt
fi
cat *.txt|egrep -v '^#|^*#'|sed 's/[ ][ ]*/ /g'|sort|uniq > hosts

cat whitelist | while read line
do
    sed -i "/$line/d" hosts
done

# cat > hosts <<EOF
# 127.0.0.1 localhost
# 127.0.0.1 localhost.localdomain
# 127.0.0.1 local
# 255.255.255.255 broadcasthost
# ::1 localhost
# ::1 ip6-localhost
# ::1 ip6-loopback
# fe80::1%lo0 localhost
# ff00::0 ip6-localnet
# ff00::0 ip6-mcastprefix
# ff02::1 ip6-allnodes
# ff02::2 ip6-allrouters
# ff02::3 ip6-allhosts
# 0.0.0.0 0.0.0.0 
# EOF
