#!/bin/sh

uci set fstab.@global[0].anon_mount=0
uci commit fstab

echo 0xDEADBEEF > /etc/config/google_fu_mode

uci set dhcp.lan.ra='server'
uci set dhcp.lan.dhcpv6='disabled'
uci set dhcp.lan.ra_management='1'
uci add dhcp domain
uci set dhcp.@domain[-1].name="router.uyna2580.top"
uci set dhcp.@domain[-1].ip="192.168.2.1"
uci add dhcp domain
uci set dhcp.@domain[-1].name="ap1.uyna2580.top"
uci set dhcp.@domain[-1].ip="192.168.2.3"
uci add dhcp domain
uci set dhcp.@domain[-1].name="nas.uyna2580.top"
uci set dhcp.@domain[-1].ip="192.168.2.11"
uci commit dhcp
/etc/init.d/dnsmasq restart
uci set network.wan.proto='pppoe'
uci set network.wan.username='057145652406'
uci set network.wan.password='707334'
uci set network.wan.ipv6='0'
uci set network.wan.ifname='eth0'
uci set network.lan.ipaddr='192.168.2.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.proto='static'
uci set network.lan.type='bridge'
uci set network.lan.ifname='eth1'
uci delete network.wan6
uci commit network
/etc/init.d/network restart

while; do
[ $(ip addr s | grep '/32 scope global pppoe-wan' |wc -l) = '1' ] && break || (sleep 1; echo 'waiting wan')
done

ip addr s pppoe-wan

cp /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.old
cat << EOF >/etc/opkg/distfeeds.conf 
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/lede/releases/18.06.4/targets/x86/64/packages
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/lede/releases/18.06.4/packages/x86_64/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/lede/releases/18.06.4/packages/x86_64/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/lede/releases/18.06.4/packages/x86_64/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/lede/releases/18.06.4/packages/x86_64/routing
EOF

opkg update && opkg install shadow openssh-server openssh-sftp-server zsh git git-http vim-fuller lsof

mkdir /home
mkdir /buckup
groupadd -g 9997 everyone
usermod -a -G everyone root
chown -R root:everyone /buckup
groupadd -g 1024 anyu
useradd --shell /usr/bin/zsh -m -g anyu -u 1024 anyu
usermod -p '*' anyu
usermod -U anyu

cat << EOF >/root/.vimrc
set number
set nocompatible
filetype on
set history=1000
syntax on
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set vb t_vb=
set ruler
set incsearch
set showmatch
set mouse=
EOF

cat /root/.vimrc > /home/anyu/.vimrc

cat << EOF > /etc/rc.local
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
EOF

cat << EOF >/etc/ssh/sshd_config
# 1. Basic
Port 32200
Protocol 2
AddressFamily inet
# 2. Authentication
HostKey /etc/ssh/ssh_host_rsa_key
KeyRegenerationInterval 3600
ServerKeyBits 768
UsePrivilegeSeparation yes
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
# 3. Features
UseDNS no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
TCPKeepAlive yes
AcceptEnv LANG LC_*
# 4. Logging
SyslogFacility AUTH
LogLevel INFO
# 5. x509
Subsystem sftp /usr/lib/sftp-server
# 6. PAM
EOF

mkdir /home/anyu/.ssh
cat << EOF > /home/anyu/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3lZXMRDd1Cx6tiQ3nBn/dJQTkXYGe0IB1JhBPYC0I68WtN5psr1+qcfMk+t0z4zM/56BqN/P4u6ibx2lHBfCy2n6FqrtAxQvXCCWjWr6WIZcUcOW8crsSXPEIkvKpANTG0QwswKfqbD+m6pGZVjaYtjC76mLZ/Ml1dlNQ7dQp+ewuRFRXpZzyfREXG9D+p5mcbBbbcHkULmaQNDw/xih4A2xyCC8UDlor1hRI3j7E6w/r/02RiXZrBOE80M1NlrhP6GnPnPSvlHOYoHP1hw3gsm9XwY+IssZRqtq/OF93PwIt7qRDpzVnMIuhJ4KJ5XiVSRrFTOV9o7FxLFuYZMUZ
EOF

chown -R anyu:anyu /home/anyu
chmod 755 /home/anyu/.ssh
chmod 644 /home/anyu/.ssh/authorized_keys

/etc/init.d/sshd restart
/etc/init.d/sshd enable

usermod -p '$1$kILcINSE$5BTorITbpIARBcudCBJY01' root

echo sh -c \"\$\(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh\)\"

exit 0