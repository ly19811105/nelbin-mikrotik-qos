# apr/28/2017 09:09:03 by RouterOS 6.38.5
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
add kind=pfifo name=streaming-video-in pfifo-limit=500
add kind=pcq name=games-in-pcq pcq-classifier=dst-address \
    pcq-dst-address6-mask=64 pcq-rate=100k pcq-src-address6-mask=64 \
    pcq-total-limit=750000KiB
add kind=pcq name=PCQ-OUT pcq-classifier=src-address pcq-dst-address6-mask=64 \
    pcq-src-address6-mask=64 pcq-total-limit=750000KiB
add kind=pcq name=PCQ-IN pcq-classifier=dst-address pcq-dst-address6-mask=64 \
    pcq-src-address6-mask=64 pcq-total-limit=750000KiB
add kind=pcq name=ping_pkts_i_32K pcq-classifier=dst-address \
    pcq-dst-address6-mask=64 pcq-rate=32k pcq-src-address6-mask=64
add kind=pcq name=ping_pkts_o_32K pcq-classifier=src-address \
    pcq-dst-address6-mask=64 pcq-rate=32k pcq-src-address6-mask=64
/queue tree
add max-limit=9500k name=IN parent=global priority=1 queue=default
add max-limit=750k name=OUT parent=global priority=1 queue=default
add limit-at=500k max-limit=9500k name=5.Browsing packet-mark=browsing-in \
    parent=IN priority=5 queue=default
add limit-at=500k max-limit=9500k name=6.Video packet-mark=video-in parent=IN \
    priority=6 queue=default
add limit-at=500k max-limit=9500k name=3.Games packet-mark=games-in parent=IN \
    priority=3 queue=default
add limit-at=100k max-limit=9500k name=7.Downloads packet-mark=downloads-in \
    parent=IN priority=7 queue=default
add limit-at=50k max-limit=750k name=7.Uploads-U packet-mark=uploads-out \
    parent=OUT priority=7 queue=default
add limit-at=50k max-limit=750k name=3.Games-U packet-mark=games-out parent=\
    OUT priority=3 queue=default
add limit-at=50k max-limit=750k name=5.Browsing-U packet-mark=http-out \
    parent=OUT priority=5 queue=default
add limit-at=50k max-limit=750k name=6.Video-U packet-mark=video-out parent=\
    OUT priority=6 queue=default
add limit-at=100k max-limit=9500k name=8.Bulk packet-mark=bulk-in parent=IN \
    queue=default
add limit-at=50k max-limit=750k name=8.Bulk-U packet-mark=bulk-out parent=OUT \
    queue=default
add limit-at=500k max-limit=9500k name=4.VOIP packet-mark=voip-in parent=IN \
    priority=4 queue=default
add limit-at=50k max-limit=750k name=4.VOIP-U packet-mark=voip-out parent=OUT \
    priority=4 queue=default
add limit-at=100k max-limit=9500k name=2.Service packet-mark=service-in \
    parent=IN priority=2 queue=default
add limit-at=50k max-limit=750k name=2.Service-U packet-mark=service-out \
    parent=OUT priority=2 queue=default
add limit-at=50k max-limit=9500k name=1.Ping packet-mark=ping_pkts_i parent=\
    global priority=1 queue=ping_pkts_i_32K
add limit-at=50k max-limit=750k name=1.Ping-U packet-mark=ping_pkts_o parent=\
    global priority=1 queue=ping_pkts_o_32K
/ip address
add address=192.168.1.1/24 comment=defconf interface=lan network=192.168.1.0
/ip dhcp-client
add comment=defconf dhcp-options=hostname,clientid disabled=no interface=wan
/ip dhcp-server network
add address=192.168.1.0/24 comment=defconf gateway=192.168.1.1 netmask=24
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4
/ip dns static
add address=192.168.1.1 name=router
/ip firewall filter
add action=accept chain=input comment="defconf: accept ICMP" disabled=yes \
    protocol=icmp
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
add action=mark-connection chain=forward comment="#####  PING" \
    new-connection-mark=icmp passthrough=yes protocol=icmp
add action=mark-packet chain=forward comment="Mark ICMP I / zaib" \
    connection-mark=icmp new-packet-mark=ping_pkts_i passthrough=no \
    src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="Mark ICMP O / zaib" \
    connection-mark=icmp new-packet-mark=ping_pkts_o passthrough=no \
    src-address=192.168.1.0/24
add action=mark-connection chain=forward comment="##### DNS" dst-port="" \
    new-connection-mark=dns passthrough=yes port=53 protocol=udp
add action=mark-packet chain=forward comment="dns in" connection-mark=dns \
    new-packet-mark=service-in passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="dns out" connection-mark=dns \
    new-packet-mark=service-out passthrough=no src-address=192.168.1.0/24
add action=mark-connection chain=forward comment="##### WOW" \
    new-connection-mark=games passthrough=yes port=\
    1119,3724,6112-6114,4000,6881-6999,8198 protocol=tcp
add action=mark-packet chain=forward comment="wow in" connection-mark=games \
    new-packet-mark=games-in passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="wow out" connection-mark=games \
    new-packet-mark=games-out passthrough=no src-address=192.168.1.0/24
add action=mark-connection chain=forward comment="#####  VIDEO" \
    layer7-protocol=youtube new-connection-mark=video passthrough=yes
add action=mark-packet chain=forward comment="video in" connection-mark=video \
    new-packet-mark=video-in passthrough=no src-address=!192.168.1.0/24 \
    src-address-list=""
add action=mark-packet chain=forward comment="video out" connection-mark=\
    video new-packet-mark=video-out passthrough=no src-address=192.168.1.0/24
add action=mark-connection chain=forward comment="##### BROWSING" \
    new-connection-mark=http passthrough=yes port=80,443 protocol=tcp
add action=mark-packet chain=forward comment="http in" connection-bytes=\
    0-500000 connection-mark=http new-packet-mark=browsing-in passthrough=no \
    src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="http+ in" connection-bytes=\
    500000-0 connection-mark=http new-packet-mark=downloads-in passthrough=no \
    src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="http out" connection-bytes=\
    0-200000 connection-mark=http new-packet-mark=http-out passthrough=no \
    src-address=192.168.1.0/24
add action=mark-packet chain=forward comment="http+ out" connection-bytes=\
    200000-0 connection-mark=http new-packet-mark=uploads-out passthrough=no \
    src-address=192.168.1.0/24
add action=mark-connection chain=forward comment="##### QUIC" \
    new-connection-mark=quic passthrough=yes port=80,443 protocol=udp
add action=mark-packet chain=forward comment="quic in" connection-bytes=\
    0-500000 connection-mark=quic new-packet-mark=browsing-in passthrough=no \
    src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="quic+ in" connection-bytes=\
    500000-0 connection-mark=quic new-packet-mark=downloads-in passthrough=no \
    src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="quic out" connection-bytes=\
    0-200000 connection-mark=quic new-packet-mark=http-out passthrough=no \
    src-address=192.168.1.0/24
add action=mark-packet chain=forward comment="quic+ out" connection-bytes=\
    200000-0 connection-mark=quic new-packet-mark=uploads-out passthrough=no \
    src-address=192.168.1.0/24
add action=mark-connection chain=forward comment="##### GOOGLE PLAYSTORE" \
    new-connection-mark=downloads passthrough=yes port=5228 protocol=tcp
add action=mark-packet chain=forward comment="playstore in" connection-mark=\
    downloads new-packet-mark=downloads-in passthrough=no src-address=\
    !192.168.1.0/24
add action=mark-packet chain=forward comment="playstore out" connection-mark=\
    downloads new-packet-mark=uploads-out passthrough=no src-address=\
    192.168.1.0/24
add action=mark-connection chain=forward comment="##### ALL" \
    new-connection-mark=bulk passthrough=yes
add action=mark-packet chain=forward comment="all in" connection-mark=bulk \
    new-packet-mark=bulk-in passthrough=no src-address=!192.168.1.0/24
add action=mark-packet chain=forward comment="all out" connection-mark=bulk \
    new-packet-mark=bulk-out passthrough=no src-address=192.168.1.0/24
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
