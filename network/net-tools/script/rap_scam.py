#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import threading
from scapy.all import *

class RapScanner:
    def __init__(self):
        self.target_ip = None
        self.interface = None
        self.timeout = 2
        self.results = {}
        
    def parse_args(self):
        """解析命令行参数"""
        parser = argparse.ArgumentParser(description='RAP(Reverse Address Protocol)扫描工具')
        parser.add_argument('-i', '--interface', required=True, help='指定网络接口')
        parser.add_argument('-t', '--target', required=True, help='目标IP地址')
        parser.add_argument('--timeout', type=int, default=2, help='超时时间(秒)')
        args = parser.parse_args()
        
        self.target_ip = args.target
        self.interface = args.interface
        self.timeout = args.timeout

    def send_rap_request(self):
        """发送RAP请求包"""
        # 构造RAP请求包
        eth = Ether(dst="ff:ff:ff:ff:ff:ff")
        arp = ARP(pdst=self.target_ip, op=1)  # op=1表示ARP请求
        pkt = eth/arp
        
        # 发送请求并等待响应
        try:
            ans, unans = srp(pkt, iface=self.interface, timeout=self.timeout, verbose=False)
            if len(ans) > 0:
                for snd, rcv in ans:
                    self.results[rcv.psrc] = rcv.hwsrc
        except Exception as e:
            print(f"发送RAP请求时出错: {str(e)}")

    def scan(self):
        """执行扫描"""
        print(f"开始扫描目标: {self.target_ip}")
        print(f"使用接口: {self.interface}")
        print(f"超时时间: {self.timeout}秒")
        
        scan_thread = threading.Thread(target=self.send_rap_request)
        scan_thread.start()
        scan_thread.join()
        
        if self.results:
            print("\n扫描结果:")
            for ip, mac in self.results.items():
                print(f"IP: {ip} -> MAC: {mac}")
        else:
            print("\n未收到任何响应")

def main():
    scanner = RapScanner()
    scanner.parse_args()
    scanner.scan()

if __name__ == "__main__":
    main()
