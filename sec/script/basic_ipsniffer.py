from scapy.all import*

interface = raw_input("Your active network interface")

def display_pack(packet):
	ip_part = packet.getlayer(IP)

	print("[!] New Packet: {src} -> {dst}".format(src=ip_part.src,dst=ip_part.dst))
# basic function ends

print("[*]Started Sniffing")
sniff(iface = interface , filter="ip" , prn = display_pack) # passing function to prn parameter

print("[*] Stop Sniffing")
