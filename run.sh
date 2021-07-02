#!/bin/sh
hosts_dir=/etc/dnsmasq.hosts
unifi_hosts=$hosts_dir/unifi.hosts

[ -d $hosts_dir ] || mkdir $hosts_dir
rm /etc/dnsmasq.conf
ln -s /etc/dns/dnsmasq.conf /etc/dnsmasq.conf
webproc --config /etc/dnsmasq.conf -- dnsmasq --no-daemon & 

while true; do
    ./get_unifi_reservations.py > /tmp/current_unifi.hosts
    if [ $? = 0 ] && ! diff -N $unifi_hosts /tmp/current_unifi.hosts; then
        mv /tmp/current_unifi.hosts $unifi_hosts
        pkill -9 $(pidof webproc) && pkill -9 $(pidof dnsmasq) && webproc --config /etc/dnsmasq.conf -- dnsmasq --no-daemon &
    fi
    sleep ${UNIFI_POLL_INTERVAL:-60}
done

