##Provided by Greg Sowell at Greg Sowell Consulting.
###Email: Greg@GregSowell.com HTTP: http://GregSowell.com
#
##The queues are based off of a theoretical 10Mb connection.  In this way you can
###use the values as percentages of the whole.  The easiest thing to do is to 
###apply the script, then in winbox adjust the values for queue size.
#
##1.1.1.0/29 is your external WAN subnet, replace this.
##2.2.2.0/24 is an additional subnet routed to you on the WAN side, replace or remove any lines containing this.
##172.22.0.0/16 is listed as your internal subnet and should be modified to fit your environment.
##172.22.0.5 is listed as "customer servers".  This is a special queue listed at 10 percent
###of the overall bandwidth.  This gives elevated service to any internal customers.  To disable
###this functionality, issue the following commands once everything has been put into place:
###/ip firewall mangle dis 2,3
###/queue tree dis 8,9
###You can then appropriate the queue bandwidth as you see fit.
#
##You will also want to change the ether1 interface to whatever your WAN interface happens to be.
#
##As always, thank you for your business and thank you for helping to feed my kids :)
 
#Here's our l7 regex statements:
/ip firewall layer7-protocol
add comment="" name=speedtest-servers regexp="^.*(get|GET).+speedtest.*\$"
add comment="" name=torrent-wwws regexp="^.*(get|GET).+(torrent|thepiratebay|i\
    sohunt|entertane|demonoid|btjunkie|mininova|flixflux|vertor|h33t|zoozle|bi\
    tnova|bitsoup|meganova|fulldls|btbot|fenopy|gpirate|commonbits).*\$"
add comment="" name=torrent-dns regexp="^.+(torrent|thepiratebay|isohunt|enter\
    tane|demonoid|btjunkie|mininova|flixflux|vertor|h33t|zoozle|bitnova|bitsou\
    p|meganova|fulldls|btbot|fenopy|gpirate|commonbits).*\$"
add comment="" name=netflix regexp="^.*(get|GET).+(netflix).*\$"
add comment="" name=mp4 regexp="^.*(get|GET).+\\.mp4.*\$"
add comment="" name=swf regexp="^.*(get|GET).+\\.swf.*\$"
add comment="" name=flv regexp="^.*(get|GET).+\\.flv.*\$"
add name=video regexp="^.*(get|GET).+(\\.flv|\\.mp4|netflix|\\.swf).*\$"
 
#Setting up our address lists
/ip firewall address-list
add address=192.168.1.0/24 comment="" disabled=no list=internal-nets
add address=112.208.1.0/16 comment="" disabled=no list=external-nets
#add address=2.2.2.0/24 comment="" disabled=no list=external-nets
#add address=172.22.0.5 comment="customer 1" disabled=no list=customer-servers
 
#Mangle identifies our various portions of traffic
/ip firewall mangle
add action=mark-packet chain=prerouting comment="internal-traffic packet mark" dst-address-list=\
    internal-nets new-packet-mark=internal-traffic passthrough=no src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="customer-servers-out packet mark" new-packet-mark=\
    customer-servers-out passthrough=no src-address-list=customer-servers
add action=mark-packet chain=prerouting comment="customer-servers-in packet mark" dst-address-list=\
    customer-servers new-packet-mark=customer-servers-in passthrough=no
add action=mark-packet chain=prerouting comment="admin-in packet mark DNS" in-interface=ether1 \
    new-packet-mark=admin-in passthrough=no protocol=udp src-port=53
add action=mark-packet chain=prerouting comment="admin-in packet mark snmp" dst-port=161 \
    in-interface=ether1 new-packet-mark=admin-in passthrough=no protocol=udp
add action=mark-connection chain=prerouting comment="Remote Protocols admin connection mark" \
    new-connection-mark=admin port=20,21,22,23,3389,8291 protocol=tcp
add action=mark-connection chain=prerouting comment="icmp connection mark as admin" \
    new-connection-mark=admin protocol=icmp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="admin-in packet mark" connection-mark=admin \
    in-interface=ether1 new-packet-mark=admin-in passthrough=no
add action=mark-packet chain=prerouting comment="admin-out packet mark" connection-mark=admin \
    new-packet-mark=admin-out passthrough=no
add action=mark-connection chain=prerouting comment="streaming video connection mark" dst-port=80 \
    layer7-protocol=video new-connection-mark=streaming-video protocol=tcp src-address-list=\
    internal-nets
add action=mark-packet chain=prerouting comment="streaming video in packet mark" connection-mark=\
    streaming-video in-interface=ether1 new-packet-mark=streaming-video-in passthrough=no
add action=mark-packet chain=prerouting comment="streaming video out packet mark" connection-mark=\
    streaming-video new-packet-mark=streaming-video-out passthrough=no
add action=mark-connection chain=prerouting comment="http traffic connection mark" dst-port=80,443 \
    new-connection-mark=http protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="http traffic connection mark" \
    connection-bytes=5000000-4294967295 dst-port=80,443 new-connection-mark=http-download protocol=\
    tcp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="http in packet mark" connection-mark=http \
    in-interface=ether1 new-packet-mark=http-in passthrough=no
add action=mark-packet chain=prerouting comment="http out packet mark" connection-mark=http \
    new-packet-mark=http-out passthrough=no
add action=mark-connection chain=prerouting comment="wow connetion mark as gaming" dst-port=\
    1119,3724,6112-6114,4000,6881-6999 new-connection-mark=games protocol=tcp src-address-list=\
    internal-nets
add action=mark-connection chain=prerouting comment="eve online connetion mark as gaming" \
    dst-address=87.237.38.200 new-connection-mark=games src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="starcraft 2 connetion mark as gaming" \
    dst-port=1119 new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="heros of newerth connetion mark as gaming" \
    dst-port=11031,11235-11335 new-connection-mark=games protocol=tcp src-address-list=\
    internal-nets
add action=mark-connection chain=prerouting comment="steam connetion mark as gaming" dst-port=\
    27014-27050 new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="xbox live connetion mark as gaming" dst-port=\
    3074 new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="ps3 online connetion mark as gaming" dst-port=\
    5223 new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-connection chain=prerouting comment="wii online connetion mark as gaming" dst-port=\
    28910,29900,29901,29920 new-connection-mark=games protocol=tcp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="games packet mark forever-saken-game" \
    dst-address-list=external-nets new-packet-mark=games-in passthrough=no src-address-list=\
    forever-saken-game
add action=mark-packet chain=prerouting comment="games packet mark wow" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=53,3724
add action=mark-packet chain=prerouting comment="games packet mark starcraft2" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=1119,6113
add action=mark-packet chain=prerouting comment="games packet mark HoN" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=11031,11235-11335
add action=mark-packet chain=prerouting comment="games packet mark steam in" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no port=4380,28960,27000-27030 protocol=udp
add action=mark-packet chain=prerouting comment="games packet mark steam out" dst-port=\
    53,1500,3005,3101,3478,4379-4380,4380,28960,27000-27030,28960 new-packet-mark=games-out \
    passthrough=no protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="games packet mark xbox live" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=88,3074,3544,4500
add action=mark-packet chain=prerouting comment="games packet mark ps3 online" dst-address-list=\
    external-nets new-packet-mark=games-in passthrough=no protocol=udp src-port=3478,3479,3658
add action=mark-packet chain=prerouting comment="games packet mark in" connection-mark=games \
    dst-address-list=external-nets new-packet-mark=games-in passthrough=no
add action=mark-packet chain=prerouting comment="games packet mark out" connection-mark=games \
    new-packet-mark=games-out passthrough=no
add action=mark-packet chain=prerouting comment="voip-in packet mark teamspeak" dst-address-list=\
    external-nets new-packet-mark=voip-in passthrough=no protocol=udp src-port=9987
add action=mark-packet chain=prerouting comment="voip-out packet mark teamspeak" dst-port=9987 \
    new-packet-mark=voip-out passthrough=no protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-out packet mark teamspeak" dst-address-list=\
    external-nets new-packet-mark=voip-in passthrough=no protocol=udp src-port=9987
add action=mark-packet chain=prerouting comment="voip-in packet mark ventrilo" dst-address-list=\
    external-nets new-packet-mark=voip-in passthrough=no protocol=udp src-port=3784
add action=mark-packet chain=prerouting comment="voip-out packet mark ventrilo" dst-port=3784 \
    new-packet-mark=voip-out passthrough=no protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark ventrilo" dst-address-list=\
    external-nets new-packet-mark=voip-in passthrough=no protocol=tcp src-port=3784
add action=mark-packet chain=prerouting comment="voip-out packet mark ventrilo" dst-port=3784 \
    new-packet-mark=voip-out passthrough=no protocol=tcp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark SIP" dst-address-list=\
    internal-nets new-packet-mark=voip-in passthrough=no port=5060 protocol=tcp
add action=mark-packet chain=prerouting comment="voip-out packet mark SIP" new-packet-mark=voip-out \
    passthrough=no port=5060 protocol=tcp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark udp SIP" dst-address-list=\
    internal-nets new-packet-mark=voip-in passthrough=no port=5004,5060 protocol=udp
add action=mark-packet chain=prerouting comment="voip-out packet mark udp SIP" new-packet-mark=\
    voip-out passthrough=no port=5004,5060 protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="voip-in packet mark RTP" dst-address-list=\
    internal-nets new-packet-mark=voip-in packet-size=100-400 passthrough=no port=16348-32768 \
    protocol=udp
add action=mark-packet chain=prerouting comment="voip-out packet mark RTP" new-packet-mark=voip-in \
    packet-size=100-400 passthrough=no port=16348-32768 protocol=udp src-address-list=internal-nets
add action=mark-packet chain=prerouting comment="vpn-in packet mark GRE" in-interface=ether1 \
    new-packet-mark=vpn-in passthrough=no protocol=gre
add action=mark-packet chain=prerouting comment="vpn-out packet mark GRE" new-packet-mark=vpn-out \
    passthrough=no protocol=gre
add action=mark-packet chain=prerouting comment="vpn-in packet mark ESP" in-interface=ether1 \
    new-packet-mark=vpn-in passthrough=no protocol=ipsec-esp
add action=mark-packet chain=prerouting comment="vpn-out packet mark ESP" new-packet-mark=vpn-out \
    passthrough=no protocol=ipsec-esp
add action=mark-packet chain=prerouting comment="vpn-in packet mark VPN UDP ports" in-interface=\
    ether1 new-packet-mark=vpn-in passthrough=no protocol=udp src-port=500,1701,4500
add action=mark-packet chain=prerouting comment="vpn-out packet mark VPN UDP ports" \
    new-packet-mark=vpn-out passthrough=no protocol=udp src-port=500,1701,4500
add action=mark-packet chain=prerouting comment="vpn-in packet mark PPTP" in-interface=ether1 \
    new-packet-mark=vpn-in passthrough=no protocol=tcp src-port=1723
add action=mark-packet chain=prerouting comment="vpn-out packet mark PPTP" new-packet-mark=vpn-out \
    passthrough=no protocol=tcp src-port=1723
add action=mark-packet chain=prerouting comment="all in" in-interface=ether1 new-packet-mark=in \
    passthrough=no
add action=mark-packet chain=prerouting comment="all out" new-packet-mark=out passthrough=no
 
#We now start setting up our queues
/queue type
add kind=pfifo name=streaming-video-in pfifo-limit=500
add kind=pcq name=games-in-pcq pcq-burst-rate=0 pcq-burst-threshold=0 pcq-burst-time=10s pcq-classifier=dst-address pcq-dst-address-mask=32 pcq-dst-address6-mask=64 \
    pcq-limit=50 pcq-rate=100k pcq-src-address-mask=32 pcq-src-address6-mask=64 pcq-total-limit=750000
/queue tree
add burst-limit=0 burst-threshold=0 burst-time=0s disabled=no limit-at=0 \
    max-limit=10M name=in parent=global priority=8
add burst-limit=0 burst-threshold=0 burst-time=0s disabled=no limit-at=0 \
    max-limit=10M name=out parent=global priority=8
/queue tree
add max-limit=10M name=in parent=global queue=default
add max-limit=10M name=out parent=global queue=default
add limit-at=3M max-limit=10M name=http-in packet-mark=http-in parent=in priority=4 queue=default
add limit-at=4M max-limit=10M name=streaming-video-in packet-mark=streaming-video-in parent=in \
    priority=3 queue=streaming-video-in
add limit-at=500k max-limit=10M name=gaming-in packet-mark=games-in parent=in priority=2 queue=\
    games-in-pcq
add max-limit=10M name=download-in packet-mark=in parent=in queue=default
add max-limit=10M name=upload-out packet-mark=out parent=out queue=default
add limit-at=500k max-limit=10M name=gaming-out packet-mark=games-out parent=out priority=2 queue=\
    default
add limit-at=3M max-limit=10M name=http-out packet-mark=http-out parent=out priority=4 queue=default
add limit-at=4M max-limit=10M name=streaming-video-out packet-mark=streaming-video-out parent=out \
    priority=3 queue=default
add limit-at=1M max-limit=10M name=customer-servers-in packet-mark=customer-servers-in parent=in \
    priority=1 queue=default
add limit-at=1M max-limit=10M name=customer-servers-out packet-mark=customer-servers-out parent=out \
    priority=1 queue=default
add limit-at=500k max-limit=10M name=voip-in packet-mark=voip-in parent=in priority=1 queue=default
add limit-at=500k max-limit=10M name=vpn-in packet-mark=vpn-in parent=in priority=2 queue=default
add limit-at=500k max-limit=10M name=voip-out packet-mark=voip-out parent=out priority=1 queue=\
    default
add limit-at=500k max-limit=10M name=vpn-out packet-mark=vpn-out parent=out priority=2 queue=default
add limit-at=500k max-limit=10M name=admin-in packet-mark=admin-in parent=in priority=1 queue=default
add limit-at=500k max-limit=10M name=admin-out packet-mark=admin-out parent=out priority=1 queue=\
    default