# Cryptocurrency Exchanges and Denial-of-Service Attacks - mitigation strategies for legitimate businesses in the new wild west

## Executive Summary:

DDoS attacks hurt legitimate businesses and assailants know them to be an effective tool to extort. Leveraging cloud technologies and enterprise vendor solutions you can quickly and effectively stop these types of attacks.

This document describes a sophisticated DDoS attack and how we managed to:

1. Quickly mitigate the attack and get the system back online.
2. Establish a project to rebuild the platform with a focus on security and infrastructure redundancy.

The learnings from this event helped the organisation to build a more robust platform that was more secure, fault-tolerant and able to scale.

## Background

A huge spike in traffic was noticed in business hours which overwhelmed the service and lasted about 30 minutes. Once the traffic abated and the service was able to once again resume normal function, the assailant started a live chat with the customer support team via their support channel and explained they had just caused the outage and would attack again unless the business paid 20BTC [(Bitcoin)](https://bitcoin.org/en/) within 2 hours (at time of attack 1BTC ~$17,900USD).

After consulting with C-level management, a war room was established to decide next steps. We instructed the support team to not engage with the assailant and to not respond to their messages.

I performed some preliminary investigation into the traffic received, types of user-agents and number of connections per IP address etc. Given my experience with web scraping I could see the traffic wasn't coming from basic HTTP libraries/tools like python [requests](https://requests.readthedocs.io/en/master/) or [curl](https://curl.haxx.se/) etc. but instead from web browsers (either hijacked or programmatically controlled with tools like [selenium](https://www.selenium.dev/documentation/en/)). This was a reasonably sophisticated attack that attempted to load different pages, login/logout of the web application, load WordPress resources and execute plug-ins to overwhelm server resources. It was a targeted attack and effective against the current application stack. The traffic most likely came from a for hire bot-net tuned to the target system.

I presented my findings to the team and came up with a solution to quickly alleviate further attack attempts. We chose to engage CloudFlare and discuss advanced enterprise options with their engineers because their free tier solutions do not mitigate sophisticated browser-based DDoS attacks. Once CloudFlare had been engaged and the application DNS switched over, we could breathe a collective sigh of relief that successive attacks should not be effective.

Once the initial attack had ceased, we held a post-mortem with relevant stakeholders to further understand how and why this attack could happen and what we could do to prevent this scenario happening again in future.

Key points from the post-mortem:

- Monitoring and alerting tools were lacking. We would need to build better solutions moving forward.
- The current platform architecture was no longer fit for purpose and we would need to plan for a redesign.

### v1 architecture:

<img src="http://yuml.me/diagram/scruffy/class/[note: Original v1 architecture{bg:wheat}],[User]<->[Route53 DNS Lookup],[User]->[EC2 Instance (app)],[EC2 Instance (app)]<->[Cache],[EC2 Instance (app)]<->[Database]"/>

This document does not explore the application stack, nor the software optimisations that were made and focuses purely on infrastructure.

### v2 architecture:

<img src="http://yuml.me/diagram/scruffy/class/[note: Target v2 architecture{bg:wheat}],[User]<->[CloudFlare DNS Lookup],[User]<->[CloudFlare DDoS Protection Proxy]<->[EC2 Application LB N+1 Multi-AZ],[EC2 Application LB N+1 Multi-AZ]<->[EC2 AutoScaling Group Instances N..],[EC2 AutoScaling Group Instances N..]<->[Cache],[EC2 AutoScaling Group Instances N..]<->[Database]"/>

When rebuilding the infrastructure we tried to align to current AWS best practices.

### Key takeaways from rebuild project:

#### Positives:
- The use of CloudFlare DNS and DDoS Proxy protection mitigated the sophisticated DDoS attack, the business was not held to ransom.
- Attackers lost interest and moved on after they realised they could not extort the target.
- Multi-AZ AWS deployments for redundancy.
- CloudFlare's proxy connectivity established with AWS Application Load Balancers (only CloudFlare owned IP ranges whitelisted in Load Balancer Security Groups).

#### Negatives:
- CloudFlare could be seen as a single-point-of-failure (what if CloudFlare's DNS is unavailable? Could we leverage multiple DNS providers for failover?).
- Higher costs involved:
  - CloudFlare enterprise support
  - Increased AWS infrastructure costs for new platform architecture
- Increased infrastructure complexity.
