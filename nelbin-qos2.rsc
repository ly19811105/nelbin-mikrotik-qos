# apr/26/2017 20:34:10 by RouterOS 6.38.5
# software id = 9G9Z-JV5L
#
/interface ethernet
set [ find default-name=ether2 ] name=ether2-master
set [ find default-name=ether3 ] master-port=ether2-master
set [ find default-name=ether4 ] master-port=ether2-master
set [ find default-name=ether5 ] master-port=ether2-master
/ip neighbor discovery
set ether1 discover=no
/ip firewall layer7-protocol
add name=speedtest-servers regexp="^.*(get|GET).+speedtest.*\$"
add name=torrent-wwws regexp="^.*(get|GET).+(torrent|thepiratebay|isohunt|entertane|demonoid|b\
    tjunkie|mininova|flixflux|vertor|h33t|zoozle|bitnova|bitsoup|meganova|fulldls|btbot|fenopy\
    |gpirate|commonbits).*\$"
add name=torrent-dns regexp="^.+(torrent|thepiratebay|isohunt|entertane|demonoid|btjunkie|mini\
    nova|flixflux|vertor|h33t|zoozle|bitnova|bitsoup|meganova|fulldls|btbot|fenopy|gpirate|com\
    monbits).*\$"
add name=netflix regexp="^.*(get|GET).+(netflix).*\$"
add name=mp4 regexp="^.*(get|GET).+\\.mp4.*\$"
add name=swf regexp="^.*(get|GET).+\\.swf.*\$"
add name=flv regexp="^.*(get|GET).+\\.flv.*\$"
add name=video regexp="^.*(get|GET).+(\\.flv|\\.mp4|netflix|\\.swf).*\$"
/ip pool
add name=dhcp ranges=192.168.1.100-192.168.1.254
/ip dhcp-server
add address-pool=dhcp disabled=no interface=ether2-master name=defconf
/queue tree
add max-limit=9500k name=IN parent=global
add max-limit=750k name=OUT parent=global
/queue type
add kind=pfifo name=streaming-video-in pfifo-limit=500
add kind=pcq name=games-in-pcq pcq-classifier=dst-address pcq-dst-address6-mask=64 pcq-rate=\
    100k pcq-src-address6-mask=64 pcq-total-limit=750000KiB
/queue tree
add limit-at=1M max-limit=9500k name=5.HTTP packet-mark=http-in parent=IN priority=5 queue=\
    default
add limit-at=2M max-limit=9500k name=4.Video packet-mark=streaming-video-in parent=IN \
    priority=4 queue=streaming-video-in
add limit-at=500k max-limit=9500k name=2.Games packet-mark=games-in parent=IN priority=2 \
    queue=games-in-pcq
add limit-at=100k max-limit=9500k name=7.Downloads packet-mark=in parent=IN priority=7 queue=\
    default
add limit-at=50k max-limit=750k name=7.Uploads-U packet-mark=out parent=OUT priority=7 queue=\
    default
add limit-at=50k max-limit=750k name=2.Games-U packet-mark=games-out parent=OUT priority=2 \
    queue=default
add limit-at=50k max-limit=750k name=5.HTTP-U packet-mark=http-out parent=OUT priority=5 \
    queue=default
add limit-at=50k max-limit=750k name=4.Video-U packet-mark=streaming-video-out parent=OUT \
    priority=4 queue=default
add limit-at=100k max-limit=9500k name=8.Bulk packet-mark=bulk-in parent=IN queue=default
add limit-at=50k max-limit=750k name=8.Bulk-U packet-mark=bulk-out parent=OUT queue=default
add limit-at=500k max-limit=9500k name=3.VOIP packet-mark=voip-in parent=IN priority=3 queue=\
    default
add limit-at=50k max-limit=750k name=3.VOIP-U packet-mark=voip-out parent=OUT priority=3 \
    queue=default
add limit-at=100k max-limit=9500k name=1.Service packet-mark=admin-in parent=IN priority=1 \
    queue=default
add limit-at=50k max-limit=750k name=1.Service-U packet-mark=admin-out parent=OUT priority=1 \
    queue=default
/ip address
add address=192.168.1.1/24 comment=defconf interface=ether2-master network=192.168.1.0
/ip dhcp-client
add comment=defconf dhcp-options=hostname,clientid disabled=no interface=ether1
/ip dhcp-server network
add address=192.168.1.0/24 comment=defconf gateway=192.168.1.1 netmask=24
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4
/ip dns static
add address=192.168.1.1 name=router
/ip firewall address-list
add address=192.168.1.0/24 list=internal-nets
add address=112.208.0.0/16 list=external-nets
add address=192.168.1.4 list=bnrdc-server
/ip firewall filter
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept established,related" connection-state=\
    established,related
add action=drop chain=input comment="defconf: drop all from WAN" in-interface=ether1
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=\
    established,related disabled=yes
add action=accept chain=forward comment="defconf: accept established,related" \
    connection-state=established,related
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf:  drop all from WAN not DSTNATed" \
    connection-nat-state=!dstnat connection-state=new in-interface=ether1
/ip firewall mangle
add action=mark-packet chain=prerouting comment="internal-traffic packet mark" \
    dst-address-list=internal-nets new-packet-mark=internal-traffic passthrough=no \
    src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="admin-in packet mark DNS" in-interface=\
    ether1 new-packet-mark=admin-in passthrough=no protocol=udp src-port=53
add action=mark-packet chain=prerouting comment="admin-in packet mark snmp" dst-port=161 \
    in-interface=ether1 new-packet-mark=admin-in passthrough=no protocol=udp
add action=mark-connection chain=prerouting comment="Remote Protocols admin connection mark" \
    new-connection-mark=admin port=20,21,22,23,3389,8291 protocol=tcp
add action=mark-connection chain=prerouting comment="icmp connection mark as admin" \
    new-connection-mark=admin passthrough=yes protocol=icmp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="admin-in packet mark" connection-mark=admin \
    in-interface=ether1 new-packet-mark=admin-in passthrough=no
add action=mark-packet chain=prerouting comment="admin-out packet mark" connection-mark=admin \
    new-packet-mark=admin-out passthrough=no
add action=mark-connection chain=prerouting comment="streaming video connection mark" \
    dst-port=80 layer7-protocol=video new-connection-mark=streaming-video protocol=tcp \
    src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="streaming video in packet mark" \
    connection-mark=streaming-video in-interface=ether1 new-packet-mark=streaming-video-in \
    passthrough=no
add action=mark-packet chain=prerouting comment="streaming video out packet mark" \
    connection-mark=streaming-video new-packet-mark=streaming-video-out passthrough=no
add action=mark-connection chain=prerouting comment="http connection mark" dst-port=80,443 \
    new-connection-mark=http passthrough=yes protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="http+ connection mark" connection-bytes=\
    5000000-4294967295 dst-port=80,443 new-connection-mark=http-download passthrough=yes \
    protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="quic connection mark" dst-port=80,443 \
    new-connection-mark=quic passthrough=yes protocol=udp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="quic+ connection mark" connection-bytes=\
    5000000-4294967295 dst-port=80,443 new-connection-mark=quic-download passthrough=yes \
    protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="http in packet mark" connection-mark=http \
    in-interface=ether1 new-packet-mark=http-in passthrough=no
add action=mark-packet chain=prerouting comment="http out packet mark" connection-mark=http \
    new-packet-mark=http-out passthrough=no
add action=mark-packet chain=prerouting comment="quic in packet mark" connection-mark=quic \
    in-interface=ether1 new-packet-mark=http-in passthrough=no
add action=mark-packet chain=prerouting comment="quic out packet mark" connection-mark=\
    quic-download new-packet-mark=http-out passthrough=no
add action=mark-connection chain=prerouting comment="wow connetion mark as gaming" dst-port=\
    1119,3724,6112-6114,4000,6881-6999 new-connection-mark=games protocol=tcp \
    src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="starcraft 2 connetion mark as gaming" \
    dst-port=1119 new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment=\
    "heros of newerth connetion mark as gaming" dst-port=11031,11235-11335 \
    new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="steam connetion mark as gaming" \
    dst-port=27014-27050 new-connection-mark=games protocol=tcp src-address-list=\
    internal-nets
add action=mark-packet chain=prerouting comment="games packet mark wow" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=53,3724
add action=mark-packet chain=prerouting comment="games packet mark starcraft2" \
    dst-address-list=external-nets new-packet-mark=games-in passthrough=no protocol=udp \
    src-port=1119,6113
add action=mark-packet chain=prerouting comment="games packet mark HoN" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=\
    11031,11235-11335
add action=mark-packet chain=prerouting comment="games packet mark steam in" \
    dst-address-list=external-nets new-packet-mark=games-in passthrough=no port=\
    4380,28960,27000-27030 protocol=udp
add action=mark-packet chain=prerouting comment="games packet mark steam out" dst-port=\
    53,1500,3005,3101,3478,4379-4380,4380,28960,27000-27030,28960 new-packet-mark=games-out \
    passthrough=no protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="games packet mark in" connection-mark=games \
    dst-address-list=external-nets new-packet-mark=games-in passthrough=no
add action=mark-packet chain=prerouting comment="games packet mark out" connection-mark=games \
    new-packet-mark=games-out passthrough=no
add action=mark-packet chain=prerouting comment="voip-in packet mark teamspeak" \
    dst-address-list=external-nets new-packet-mark=voip-in passthrough=no protocol=udp \
    src-port=9987
add action=mark-packet chain=prerouting comment="voip-out packet mark teamspeak" dst-port=\
    9987 new-packet-mark=voip-out passthrough=no protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-out packet mark teamspeak" \
    dst-address-list=external-nets new-packet-mark=voip-in passthrough=no protocol=udp \
    src-port=9987
add action=mark-packet chain=prerouting comment="voip-in packet mark ventrilo" \
    dst-address-list=external-nets new-packet-mark=voip-in passthrough=no protocol=udp \
    src-port=3784
add action=mark-packet chain=prerouting comment="voip-out packet mark ventrilo" dst-port=3784 \
    new-packet-mark=voip-out passthrough=no protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark ventrilo" \
    dst-address-list=external-nets new-packet-mark=voip-in passthrough=no protocol=tcp \
    src-port=3784
add action=mark-packet chain=prerouting comment="voip-out packet mark ventrilo" dst-port=3784 \
    new-packet-mark=voip-out passthrough=no protocol=tcp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark SIP" dst-address-list=\
    internal-nets new-packet-mark=voip-in passthrough=no port=5060 protocol=tcp
add action=mark-packet chain=prerouting comment="voip-out packet mark SIP" new-packet-mark=\
    voip-out passthrough=no port=5060 protocol=tcp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark udp SIP" \
    dst-address-list=internal-nets new-packet-mark=voip-in passthrough=no port=5004,5060 \
    protocol=udp
add action=mark-packet chain=prerouting comment="voip-out packet mark udp SIP" \
    new-packet-mark=voip-out passthrough=no port=5004,5060 protocol=udp src-address-list=\
    internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark RTP" dst-address-list=\
    internal-nets new-packet-mark=voip-in packet-size=100-400 passthrough=no port=16348-32768 \
    protocol=udp
add action=mark-packet chain=prerouting comment="voip-out packet mark RTP" new-packet-mark=\
    voip-in packet-size=100-400 passthrough=no port=16348-32768 protocol=udp \
    src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="all in" in-interface=ether1 new-packet-mark=\
    in passthrough=no
add action=mark-packet chain=prerouting comment="all out" new-packet-mark=out passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" out-interface=ether1
/system clock
set time-zone-name=Asia/Manila
/system routerboard settings
# Warning: memory not running at default frequency
set memory-frequency=1200DDR
/tool mac-server
set [ find default=yes ] disabled=yes
add interface=ether2-master
/tool mac-server mac-winbox
set [ find default=yes ] disabled=yes
add interface=ether2-master