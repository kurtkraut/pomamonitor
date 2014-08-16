pomamonitor
===========

pomamonitor (Poor's Man Monitor) is a shell script that rely's on notify-send command to send alerts to Gnome/KDE/XFCE desktop user when a host or several hosts that was previously set to be monitored are offline. Pretty useful for small system administrators that doesn't need Nagios/Zabbix for monitoring such a small enviroment. Obviously, it supports IPv6: we are in 2014!

Why Poor's Man?
===============
A system administrator usually needs to monitor constantly the machines and system he is responsible for. This is often done by central monitoring systems, with several nodes like Nagios, Zabbix or Cacti. But this would require a central server to keep track of all uptime/downtime data, server's info like load average etc. A poor man (a ironic way to refer to a modest sysadmin) wouldn't have a central server to do such thing or even not too many hosts to care about. So the objective with this project is just to give a quick desktop alert to sysadmins that something is wrong with a server or network. Quick alerts can lead to quick responses and less downtime.

Useful Applications
* John has many websites hosted in different datacenters. He wants to be alerted if any of his websites go down to jump on the tech support's neck as soon as possible.
* Mike is responsible to monitor several VPNs with dynamic IPs and domestic broadbands. He wants to know if xpto.no-ip.org stopped responding to act as quickly as he can.
* Mark is an IRC administrator of a network that is a constant target of DDoS. He needs to be warned if a server stopped responding even if he is not using an IRC client at the moment.
* Kurt is some sort of wierd telecom geek that wants to measure and monitor absolutely everything on internet to warn his friends over twitter when a famous service is offline.

Software Dependencies and Technology
====================================

You will find what are pomamonitor's software dependencies and how does it work under the hood on SoftwareDependencies page.

I'm impatient: how do I run it?
===============================

So, want to download the latest pomamonitor version? Just read HowToInstall page.

Help needed
===========

We don't need to be Obama to say 'Yes we can!'. This is free software: no matter how inexperienced you are, you can help us with something you know or think. We're currently missing experience in the follow subjects:

* An equivalent to the command notify-send to other enviroments, like KDE.
* How to package pomamonitor to major Linux distributions.
* A GUI for settings. Zenity may be?
* If you can help us in those subject or any not listed above, don't be shy, let us have a chat

Feature Request/Roadmap
=======================

What to suggest/request a feature? Please, provide us rich details on what you're thinking. Or take a look on what has already been suggested on RoadMap.
