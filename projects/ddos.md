# Cryptocurrency exchanges and Denial-Of-Service Attacks - mitigation strategies for legitimate businesses in the new wild west

## Executive Summary:

DDOS attacks hurt legitimate businesses and assailants know them to be an effective tool to extort. Leveraging cloud technologies and enterprise vendor solutions you can quickly and effectively alleviate these types of attacks. This document describes a sophisticated DDOS attack against a client and how we managed to:

1. Quickly alleviate the attack and get the system back online.
2. How we rebuilt the application stack with a focus on security and infrastructure redundancy.

## Background

A huge spike in traffic was noticed in business hours which overwhelmed the service and lasted about 30 minutes. Once the traffic abated and the service was able to once again resume normal function, the assailant started a live chat with the client via their support channel and explained they had just caused the outage and would attack again unless the client paid 20BTC [(Bitcoin)](https://bitcoin.org/en/) within 2 hours (at time of attack 1BTC ~$17,900USD).

I instructed the client to not engage with the assailant and to not respond to their messages. All C-level management was briefed and a war room established to decide next steps.

I performed some preliminary investigation into the traffic received, types of user-agents and number of connections per IP address etc. Given my experience with web scraping I could see the traffic wasn't coming from basic HTTP libraries/tools like python [requests](https://requests.readthedocs.io/en/master/) or [curl](https://curl.haxx.se/) etc. but instead from web browsers (either hijacked or programmatically controlled with tools like [selenium](https://www.selenium.dev/documentation/en/). This was a reasonably sophisticated attack that attempted to load different pages, login/logout of the web application and attempt to load WordPress resources and execute plug-ins to overwhelm server resources. It was a targeted attack and effective against the current application stack. The traffic most probably came from a for hire bot-net tuned for the nuances of the target system.

I presented my findings to the team and came up with a solution to quickly alleviate further attack attempts. We chose to engage CloudFlare and discuss advanced enterprise options with their engineers because the free tier solutions do not mitigate sophisticated browser-based DDOS attacks that programmatically controlled browsers get around. Once CloudFlare had been engaged and the application DNS switched we could breathe a collective sigh of relief that successive attacks should not be effective. Once the initial attack had ceased, I set about redesigning the systems infrastructure.

The client had quite a basic application stack running in AWS. This solution did not account for traffic spikes or redundancy in case of failure. This could have possibly led to why the assailants chose them as a target.

### Rudimentary architecture of the original v1 system:

<img src="http://yuml.me/diagram/scruffy/class/[note: Original v1 architecture{bg:wheat}],[User]<->[Route53 DNS Lookup],[User]->[EC2 Instance (app)],[EC2 Instance (app)]<->[Cache],[EC2 Instance (app)]<->[Database]"/>

This document does not go into details of the application stack, nor the software optimisations that were carried out and focuses purely on infrastructure.

### v2 architecture:

<img src="http://yuml.me/diagram/scruffy/class/[note: Target v2 architecture{bg:wheat}],[User]<->[CloudFlare DNS Lookup],[User]<->[CloudFlare DDOS Protection Proxy]<->[EC2 Application LB N+1 Multi-AZ],[EC2 Application LB N+1 Multi-AZ]<->[EC2 AutoScaling Group Instances N..],[EC2 AutoScaling Group Instances N..]<->[Cache],[EC2 AutoScaling Group Instances N..]<->[Database]"/>

When rebuilding the infrastructure I tried to align to AWS best practices at the time.

### Key takeaways from rebuild:

#### Positives:
- Use of CloudFlare DNS and DDOS Proxy protection alleviated the sophisticated DDOS attacks, the client did not get held to ransom
- Attackers lost interest and moved on after they realised they could not extort the target.
- Multi-AZ AWS deployments for redundancy.
- CloudFlare interfaces directly with AWS Application Load Balancers (only CloudFlare IP ranges could communicate with LBs Security Group firewall rules).

#### Negatives:
- CloudFlare could be seen as a single-point-of-failure (what if CloudFlare's DNS is unavailable? Could we leverage multiple DNS providers for failover?).
- Higher costs involved
  - CloudFlare enterprise support
  - Increased AWS infrastructure costs for new application architecture
- Increased infrastructure complexity.
