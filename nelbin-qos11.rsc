# apr/28/2017 22:03:37 by RouterOS 6.38.5
# software id = 9G9Z-JV5L
#
/interface ethernet
set [ find default-name=ether2 ] name=lan
set [ find default-name=ether1 ] name=wan
/ip neighbor discovery
set wan discover=no
/interface ethernet
set [ find default-name=ether3 ] master-port=lan
set [ find default-name=ether4 ] master-port=lan
set [ find default-name=ether5 ] master-port=lan
/ip firewall layer7-protocol
add name=youtube regexp=videoplayback|video
/ip hotspot profile
set [ find default=yes ] html-directory=flash/hotspot
/ip pool
add name=dhcp ranges=192.168.1.100-192.168.1.254
/ip dhcp-server
add address-pool=dhcp disabled=no interface=lan name=defconf
/queue type
add kind=pcq name=Download pcq-classifier=dst-address pcq-dst-address6-mask=\
    64 pcq-src-address6-mask=64
add kind=pcq name=Upload pcq-classifier=src-address pcq-dst-address6-mask=64 \
    pcq-src-address6-mask=64
/queue simple
add comment="Managment Traffic" name=Managment packet-marks=Managment \
    priority=1/1 queue=default/default
/queue tree
add max-limit=10M name=IN parent=lan queue=pcq-download-default
add max-limit=750k name=OUT parent=wan queue=pcq-upload-default
add limit-at=500k max-limit=10M name=4.Browsing packet-mark=browsing parent=\
    IN priority=4 queue=pcq-download-default
add limit-at=500k max-limit=10M name=5.Video packet-mark=video parent=IN \
    priority=5 queue=pcq-download-default
add limit-at=500k max-limit=10M name=2.Games packet-mark=games parent=IN \
    priority=2 queue=pcq-download-default
add limit-at=500k max-limit=10M name=6.Downloads packet-mark=transfer parent=\
    IN priority=6 queue=pcq-download-default
add limit-at=40k max-limit=750k name=6.Uploads-o packet-mark=transfer parent=\
    OUT priority=6 queue=pcq-upload-default
add limit-at=40k max-limit=750k name=2.Games-o packet-mark=games parent=OUT \
    priority=2 queue=pcq-upload-default
add limit-at=40k max-limit=750k name=4.Browsing-o packet-mark=browsing \
    parent=OUT priority=4 queue=pcq-upload-default
add limit-at=40k max-limit=750k name=5.Video-o packet-mark=video parent=OUT \
    priority=5 queue=pcq-upload-default
add limit-at=500k max-limit=10M name=8.Bulk packet-mark=bulk parent=IN queue=\
    pcq-download-default
add limit-at=40k max-limit=750k name=8.Bulk-o packet-mark=bulk parent=OUT \
    queue=pcq-upload-default
add limit-at=500k max-limit=10M name=3.VOIP packet-mark=voip parent=IN \
    priority=3 queue=pcq-download-default
add limit-at=40k max-limit=750k name=3.VOIP-o packet-mark=voip parent=OUT \
    priority=3 queue=pcq-upload-default
add limit-at=500k max-limit=10M name=1.Service packet-mark=service parent=IN \
    priority=1 queue=pcq-download-default
add limit-at=40k max-limit=750k name=1.Service-o packet-mark=service parent=\
    OUT priority=1 queue=pcq-upload-default
add name=Ping packet-mark=ping parent=lan priority=1 queue=\
    pcq-download-default
add name=Ping-o packet-mark=ping parent=wan priority=1 queue=\
    pcq-upload-default
/ip address
add address=192.168.1.1/24 comment=defconf interface=lan network=192.168.1.0
/ip dhcp-client
add comment=defconf dhcp-options=hostname,clientid disabled=no interface=wan
/ip dhcp-server network
add address=192.168.1.0/24 comment=defconf gateway=192.168.1.1 netmask=24
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=192.168.1.1 name=router
/ip firewall filter
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept established,related" \
    connection-state=established,related
add action=drop chain=input comment="defconf: drop all from WAN" \
    in-interface=wan
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related disabled=yes
add action=accept chain=forward comment="defconf: accept established,related" \
    connection-state=established,related
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface=wan
/ip firewall mangle
add action=mark-connection chain=prerouting comment=ping new-connection-mark=\
    ping-conn passthrough=yes protocol=icmp
add action=mark-packet chain=prerouting connection-mark=ping-conn \
    new-packet-mark=ping passthrough=no
add action=mark-connection chain=prerouting comment=dns dst-port=53 \
    new-connection-mark=service-conn passthrough=yes protocol=tcp
add action=mark-connection chain=prerouting dst-port=53 new-connection-mark=\
    service-conn passthrough=yes protocol=udp
add action=mark-packet chain=prerouting connection-mark=service-conn \
    new-packet-mark=service passthrough=no
add action=mark-connection chain=prerouting comment="world of warcraft" \
    dst-port=1119,3724,6112-6114,4000,6881-6999,8198 new-connection-mark=\
    games-conn passthrough=yes protocol=tcp
add action=mark-connection chain=prerouting comment="cs go" dst-port=\
    27014-27050 new-connection-mark=games-conn passthrough=yes protocol=tcp
add action=mark-connection chain=prerouting dst-port=\
    3478,4379-4380,27000-27030 new-connection-mark=games-conn passthrough=yes \
    protocol=udp
add action=mark-packet chain=prerouting connection-mark=games-conn \
    new-packet-mark=games passthrough=no
add action=mark-connection chain=prerouting comment=video layer7-protocol=\
    youtube new-connection-mark=video-conn passthrough=yes
add action=mark-packet chain=prerouting connection-mark=video-conn \
    new-packet-mark=video passthrough=no src-address-list=""
add action=mark-connection chain=prerouting comment=browsing dst-port=\
    80,443,8080 new-connection-mark=http-conn passthrough=yes protocol=tcp
add action=mark-connection chain=prerouting dst-port=80,443,8080 \
    new-connection-mark=http-conn passthrough=yes port="" protocol=udp
add action=mark-packet chain=prerouting connection-bytes=0-200000 \
    connection-mark=http-conn new-packet-mark=browsing passthrough=no
add action=mark-packet chain=prerouting connection-bytes=200000-0 \
    connection-mark=http-conn new-packet-mark=transfer passthrough=no
add action=mark-connection chain=prerouting comment="google playstore" \
    dst-port=5228 new-connection-mark=transfer-conn passthrough=yes protocol=\
    tcp
add action=mark-packet chain=prerouting connection-mark=transfer-conn \
    new-packet-mark=transfer passthrough=no
add action=mark-connection chain=prerouting comment=all new-connection-mark=\
    bulk-conn passthrough=yes
add action=mark-packet chain=prerouting connection-mark=bulk-conn \
    new-packet-mark=bulk passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    out-interface=wan
/ip upnp
set enabled=yes show-dummy-rule=no
/ip upnp interfaces
add interface=lan type=internal
add interface=wan type=external
add interface=ether3 type=internal
add interface=ether4 type=internal
add interface=ether5 type=internal
/system clock
set time-zone-name=Asia/Manila
/system routerboard settings
# Warning: memory not running at default frequency
set memory-frequency=1200DDR
/tool mac-server
set [ find default=yes ] disabled=yes
add interface=lan
/tool mac-server mac-winbox
set [ find default=yes ] disabled=yes
add interface=lan
