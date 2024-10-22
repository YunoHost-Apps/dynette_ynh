#!/usr/bin/env bash

iptables -t nat -A PREROUTING -i __IFACE__ -p tcp --dport 53 -j REDIRECT --to-port __PORT_NAMED__
iptables -t nat -A PREROUTING -i __IFACE__ -p udp --dport 53 -j REDIRECT --to-port __PORT_NAMED__

ip6tables -t nat -A PREROUTING -i __IFACE__ -p tcp --dport 53 -j REDIRECT --to-port __PORT_NAMED__
ip6tables -t nat -A PREROUTING -i __IFACE__ -p udp --dport 53 -j REDIRECT --to-port __PORT_NAMED__
