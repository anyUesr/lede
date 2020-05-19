#! /bin/sh

uci set fstab.@global[0].anon_mount=0
uci set fstab.@global[0].auto_mount=0
uci commit fstab
chmod 0755 /etc/openclash/core/clash*
echo 0xDEADBEEF > /etc/config/google_fu_mode

uci set dhcp.lan.ra='server'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra_management='1'
uci add dhcp domain
uci set dhcp.@domain[-1].name="router.uyna2580.top"
uci set dhcp.@domain[-1].ip="192.168.2.1"
uci add dhcp domain
uci set dhcp.@domain[-1].name="poe.uyna2580.top"
uci set dhcp.@domain[-1].ip="192.168.2.2"
uci add dhcp domain
uci set dhcp.@domain[-1].name="nas.uyna2580.top"
uci set dhcp.@domain[-1].ip="192.168.2.11"
uci commit dhcp
/etc/init.d/dnsmasq restart
uci set network.wan.proto='pppoe'
uci set network.wan.username='CD02885641718'
uci set network.wan.password='85641718'
uci set network.wan.ipv6='1'
uci set network.wan.ifname='eth0'
uci set network.lan.ipaddr='192.168.2.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.proto='static'
uci set network.lan.type='bridge'
uci set network.lan.ifname='eth1 eth2 eth3 eth4 eth5'
uci commit network
/etc/init.d/network restart

for i in `seq 20`; do
[ $(ip addr s | grep '/32 scope global pppoe-wan' |wc -l) = '1' ] && break || (sleep 1; echo 'waiting wan')
done

ip addr s pppoe-wan

cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.old
cat << EOF >/etc/opkg/distfeeds.conf
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/lede/releases/19.07.2/targets/x86/64/packages
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/lede/releases/19.07.2/packages/x86_64/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/lede/releases/19.07.2/packages/x86_64/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/lede/releases/19.07.2/packages/x86_64/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/lede/releases/19.07.2/packages/x86_64/routing
EOF

exit 0
