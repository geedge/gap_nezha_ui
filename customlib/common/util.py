import socket
import fcntl
import struct
import string

def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

#get_ip_address('eth0')  # '192.168.0.110'

def	source_str_is_cotain_destion_str(sourcestr,destionstr):
	return string.find(sourcestr,destionstr)!=-1