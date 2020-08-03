#Cryptocurrency exchanges and Denial-Of-Service Attacks - Mitigation strategies for legitimate businesses in the new wild west

##Executive Summary:

DDOS attacks hurt legitimate businesses and their assailants know them to be an effective tool to extort. Levaraging cloud technologies and enterprise vendor solutions you can quickly and effectively alleviate these types of attacks. This document describes a sophisticated DDOS attack against a client and how we managed to:

1. Quickly alleviate the attack and get the system back online.
2. How we rebuilt the application stack with a focus on security and infrastructure redundancy. 

## Background

A huge spike in traffic was noticed in business hours which overwhelmed the service and lasted about 30 minutes. Once the traffic abated and the service was able to once again resume normal function, the assailant started a live chat with the client and explained they had just caused the outage and would attack again unless the client paid 20BTC [(Bitcoin)](https://bitcoin.org/en/) within 2 hours (at time of attack 1BTC = ~$17,900USD).

I instructed the client to not engage with the assailant and to not respond to their messages. All C-level management was brefied and a war room established to decide next steps.

I performed some preliminary investigation into the traffic received, types of user-agents and number of connections per IP address etc. Given my expierince with web scraping I could see the traffic wasn't coming from basic HTTP libraries/tools like python [requests](https://requests.readthedocs.io/en/master/) or [curl](https://curl.haxx.se/) etc. but was probably from web browsers (either hijacked or programatically controlled with tools like [selenium](https://www.selenium.dev/documentation/en/). This was a reasonably sophisticated attack that attempted to load different pages, login/logout of the web application and attempt to load Wordpress resources. It was a targeted attack and effective against the current application stack. The traffic most probably came from a for hire bot-net tuned for the nuances of this system.

I presented my findings to the team and came up with a solution to quickly alleviate further attack attempts. I decided to engage CloudFlare and discuss advanced enterprise options with them because their free-tier solutions for example the "I am under attack page" do not mitigate sophisticated browser-based DDOS that tools like Selenium using real web browsers get around. Once CloudFlare had been engaged and the application DNS switched we could breath a collective sigh of relief that successive attacks should not be effective. Once the initial attack period had resided, I set about rearchitecting the system's infrastructure.

The client initially had quite a basic application stack running in AWS. This solution did not particulary account for traffic spikes or redundancy in case of failure. This could have possibly led to why the assailants chose them as a target.

###Rudimentary diagram of the original v1 system architecture:

<img src="http://yuml.me/diagram/scruffy/class/[note: Original v1 architecture{bg:wheat}],[User]<->[Route53 DNS Lookup],[User]->[EC2 Instance (app)],[EC2 Instance (app)]<->[Cache],[EC2 Instance (app)]<->[Database]"/>

###V2 architecture:

<img src="http://yuml.me/diagram/scruffy/class/[note: Target v2 architecture{bg:wheat}],[User]<->[CloudFlare DNS Lookup],[User]<->[CloudFlare DDOS Protection Proxy]<->[EC2 Application LB N+1 Multi-AZ],[EC2 Application LB N+1 Multi-AZ]<->[EC2 AutoScaling Group Instances N..],[EC2 AutoScaling Group Instances N..]<->[Cache],[EC2 AutoScaling Group Instances N..]<->[Database]"/>

###Key takeaways from the new stack:

####Positives:
- Use of CloudFlare DNS and DDOS Proxy protection alleviated the sophisticated DDOS attacks, the client did not get held to ransom
- attackers got bored and moved on after they realised they could not extort the target
- Multi-AZ AWS deployments for redundancy
- CloudFlare interfaces directly with AWS Application LoadBalancers (only CloudFlare IP ranges could communicate with LBs Security Group rules for security) 

####Negatives:
- CloudFlare could be seen as a single-point-of-failure (what if CloudFlare's DNS goes down? could we leverage multiple DNS providers for failover?)
- Higher costs involved
  - CloudFlare enterprise support
  - Increased AWS infrastructure costs for new appication architecture
  - Increased infrastructure complexity
