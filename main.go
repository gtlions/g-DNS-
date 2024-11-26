package main

import (
	"context"
	"fmt"
	"net"
	"os"
	"time"
)

func main() {
	domain := os.Args[1]
	// domain := "qyapi.weixin.qq.com"
	ipv4s := []string{}
	ipv6s := []string{}
	// 定义不同运营商的 DNS 服务器
	dnsServers := []map[string]string{
		{"name": "CNNIC", "ip": "1.2.4.8"},
		{"name": "114", "ip": "114.114.114.114"},
		{"name": "DNSPod", "ip": "119.29.29.29"},
		{"name": "阿里云", "ip": "223.5.5.5"},
		{"name": "腾讯云", "ip": "183.60.83.19"},
		{"name": "百度云", "ip": "180.76.76.76"},
		{"name": "华为云", "ip": "122.112.208.1"},
		{"name": "电信", "ip": "202.96.209.5"},
		{"name": "联通", "ip": "202.106.0.20"},
		{"name": "移动", "ip": "202.108.22.5"},

		{"name": "香港宽频", "ip": "203.80.96.10"},
		{"name": "中華電信", "ip": "168.95.192.1"},

		{"name": "Google", "ip": "8.8.8.8"},
		{"name": "Cloudflare", "ip": "1.1.1.1"},
		{"name": "OpenDNS", "ip": "208.67.222.222"},
	}

	for _, dnsServer := range dnsServers {
		// 设置 DNS 服务器
		resolver := &net.Resolver{
			PreferGo: true,
			Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
				d := net.Dialer{Timeout: time.Second * 5}
				return d.DialContext(ctx, network, dnsServer["ip"]+":53")
			},
		}

		// 查询域名的 A 记录
		ip, err := resolver.LookupHost(context.Background(), domain)
		if err != nil {
			fmt.Printf("Error querying DNS server %s(%s): %v\n", dnsServer["name"], dnsServer["ip"], err)
			continue
		}

		fmt.Printf("DNS Server: %s(%s), Domain: %s, IPs: %v\n", dnsServer["name"], dnsServer["ip"], domain, ip)

		for _, v := range ip {
			found := false
			if vip := net.ParseIP(v); ip != nil && vip.To4() != nil {
				for _, ip := range ipv4s {
					if ip == v {
						found = true
						break
					}
				}
				if !found {
					ipv4s = append(ipv4s, v)
				}
			} else {
				for _, ip := range ipv6s {
					if ip == v {
						found = true
						break
					}
				}
				if !found {
					ipv6s = append(ipv6s, v)
				}
			}
		}
	}
	fmt.Println()
	fmt.Printf("IPs(v4 / %d): %v\n", len(ipv4s), ipv4s)
	fmt.Printf("IPs(v6 / %d): %v\n", len(ipv6s), ipv6s)
}
