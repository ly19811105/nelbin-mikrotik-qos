# apr/27/2017 20:25:28 by RouterOS 6.38.5
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
add name=youtube regexp=videoplayback|video
/ip hotspot profile
set [ find default=yes ] html-directory=flash/hotspot
/ip pool
add name=dhcp ranges=192.168.1.100-192.168.1.254
/ip dhcp-server
add address-pool=dhcp disabled=no interface=ether2-master name=defconf
/queue tree
add max-limit=9500k name=IN parent=global
add max-limit=750k name=OUT parent=global
/queue type
add kind=pfifo name=streaming-video-in pfifo-limit=500
add kind=pcq name=games-in-pcq pcq-classifier=dst-address pcq-dst-address6-mask=64 pcq-rate=100k pcq-src-address6-mask=64 pcq-total-limit=\
    750000KiB
/queue tree
add limit-at=500k max-limit=9500k name=4.Browsing packet-mark=browsing-in parent=IN priority=4 queue=pcq-download-default
add limit-at=500k max-limit=9500k name=5.Video packet-mark=video-in parent=IN priority=5 queue=default
add limit-at=500k max-limit=9500k name=2.Games packet-mark=games-in parent=IN priority=2 queue=games-in-pcq
add limit-at=100k max-limit=9500k name=7.Downloads packet-mark=downloads-in parent=IN priority=7 queue=pcq-download-default
add limit-at=50k max-limit=750k name=7.Uploads-U packet-mark=uploads-out parent=OUT priority=7 queue=pcq-upload-default
add limit-at=50k max-limit=750k name=2.Games-U packet-mark=games-out parent=OUT priority=2 queue=games-in-pcq
add limit-at=50k max-limit=750k name=4.Browsing-U packet-mark=http-out parent=OUT priority=4 queue=pcq-upload-default
add limit-at=50k max-limit=750k name=5.Video-U packet-mark=video-out parent=OUT priority=5 queue=default
add limit-at=100k max-limit=9500k name=8.Bulk packet-mark=bulk-in parent=IN queue=pcq-download-default
add limit-at=50k max-limit=750k name=8.Bulk-U packet-mark=bulk-out parent=OUT queue=pcq-upload-default
add limit-at=500k max-limit=9500k name=3.VOIP packet-mark=voip-in parent=IN priority=3 queue=pcq-download-default
add limit-at=50k max-limit=750k name=3.VOIP-U packet-mark=voip-out parent=OUT priority=3 queue=pcq-upload-default
add limit-at=100k max-limit=9500k name=1.Service packet-mark=service-in parent=IN priority=1 queue=pcq-download-default
add limit-at=50k max-limit=750k name=1.Service-U packet-mark=service-out parent=OUT priority=1 queue=pcq-upload-default
add max-limit=750k name=1.ICMP packet-mark=ping-out parent=OUT priority=1 queue=games-in-pcq
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
/ip firewall filter
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept established,related" connection-state=established,related
add action=drop chain=input comment="defconf: drop all from WAN" in-interface=ether1
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related disabled=yes
add action=accept chain=forward comment="defconf: accept established,related" connection-state=established,related
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new \
    in-interface=ether1
/ip firewall mangle
add action=mark-connection chain=postrouting comment="#####  ICMP" new-connection-mark=icmp passthrough=yes protocol=icmp
add action=mark-packet chain=postrouting comment=ping connection-mark=icmp new-packet-mark=ping-out passthrough=yes src-address=\
    192.168.1.0/24
add action=mark-connection chain=prerouting comment="##### DNS" dst-port="" new-connection-mark=dns passthrough=yes port=53 protocol=udp
add action=mark-packet chain=prerouting comment="dns in" connection-mark=dns new-packet-mark=service-in passthrough=no src-address=\
    !192.168.1.0/24
add action=mark-packet chain=prerouting comment="dns out" connection-mark=dns new-packet-mark=service-out passthrough=no src-address=\
    192.168.1.0/24
add action=mark-connection chain=prerouting comment="##### WOW" new-connection-mark=games passthrough=yes port=\
    1119,3724,6112-6114,4000,6881-6999,8198 protocol=tcp
add action=mark-packet chain=prerouting comment="wow in" connection-mark=games new-packet-mark=games-in passthrough=no src-address=\
    !192.168.1.0/24
add action=mark-packet chain=prerouting comment="wow out" connection-mark=games new-packet-mark=games-out passthrough=no src-address=\
    192.168.1.0/24
add action=mark-connection chain=prerouting comment="#####  VIDEO" layer7-protocol=youtube new-connection-mark=video passthrough=yes
add action=mark-packet chain=prerouting comment="video in" connection-mark=video new-packet-mark=video-in passthrough=no src-address=\
    !192.168.1.0/24 src-address-list=""
add action=mark-packet chain=prerouting comment="video out" connection-mark=video new-packet-mark=video-out passthrough=no src-address=\
    192.168.1.0/24
add action=mark-connection chain=prerouting comment="##### BROWSING" new-connection-mark=http passthrough=yes port=80,443 protocol=tcp
add action=mark-packet chain=prerouting comment="http in" connection-bytes=0-500000 connection-mark=http new-packet-mark=browsing-in \
    passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=prerouting comment="http+ in" connection-bytes=500000-0 connection-mark=http new-packet-mark=downloads-in \
    passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=prerouting comment="http out" connection-bytes=0-200000 connection-mark=http new-packet-mark=http-out \
    passthrough=no src-address=192.168.1.0/24
add action=mark-packet chain=prerouting comment="http+ out" connection-bytes=200000-0 connection-mark=http new-packet-mark=uploads-out \
    passthrough=no src-address=192.168.1.0/24
add action=mark-connection chain=prerouting comment="##### QUIC" new-connection-mark=quic passthrough=yes port=80,443 protocol=udp
add action=mark-packet chain=prerouting comment="quic in" connection-bytes=0-500000 connection-mark=quic new-packet-mark=browsing-in \
    passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=prerouting comment="quic+ in" connection-bytes=500000-0 connection-mark=quic new-packet-mark=downloads-in \
    passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=prerouting comment="quic out" connection-bytes=0-200000 connection-mark=quic new-packet-mark=http-out \
    passthrough=no src-address=192.168.1.0/24
add action=mark-packet chain=prerouting comment="quic+ out" connection-bytes=200000-0 connection-mark=quic new-packet-mark=uploads-out \
    passthrough=no src-address=192.168.1.0/24
add action=mark-connection chain=prerouting comment="##### GOOGLE PLAYSTORE" dst-port=5228 new-connection-mark=downloads passthrough=yes \
    protocol=tcp
add action=mark-packet chain=prerouting comment="playstore in" connection-mark=downloads new-packet-mark=downloads-in passthrough=no \
    src-address=!192.168.1.0/24
add action=mark-packet chain=prerouting comment="playstore out" connection-mark=downloads new-packet-mark=uploads-out passthrough=no \
    src-address=192.168.1.0/24
add action=mark-connection chain=prerouting comment="##### ALL" new-connection-mark=bulk passthrough=yes
add action=mark-packet chain=prerouting comment="all in" connection-mark=bulk new-packet-mark=bulk-in passthrough=no src-address=\
    !192.168.1.0/24
add action=mark-packet chain=prerouting comment="all out" connection-mark=bulk new-packet-mark=bulk-out passthrough=no src-address=\
    192.168.1.0/24
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
