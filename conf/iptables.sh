#!/usr/bin/env bash

iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 53 -j REDIRECT --to-port 1053
iptables -t nat -A PREROUTING -i ens19 -p udp --dport 53 -j REDIRECT --to-port 1053

ip6tables -t nat -A PREROUTING -i ens19 -p tcp --dport 53 -j REDIRECT --to-port 1053
ip6tables -t nat -A PREROUTING -i ens19 -p udp --dport 53 -j REDIRECT --to-port 1053
