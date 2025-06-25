// For more customisable options, please refer to official reference: https://typst.app/docs/reference/

#show heading: set text(font: "libertinus serif")
#show link: underline

#set text(size: 9.5pt)

#set page(
  margin: (x: 0.9cm, y: 1.3cm),
)

#set par(justify: true)

#let chiline() = { v(-3pt); line(length: 100%); v(-5pt) }
#let continuescvpage() = {
  place(
    bottom + center,
    dx: 0pt,
    dy: -10pt,
    float: true,
    scope: "parent",
    [
      #text(fill: gray)[... continues on the next page ...]
    ]
  )
}
#let lastupdated(date) = {
  h(1fr); text("Last Updated " + date, fill: color.gray)
}

// Uncomment the following line if multi-page
#continuescvpage()

= Daniel Pilch

danielpilch\@hotmail.co.uk | #link("https://github.com/danpilch")[github.com/danpilch] | #link("https://danpilch.github.io/")[danpilch.github.io] | #link("https://www.linkedin.com/in/danpilch")[linkedin.com/in/danpilch]

== Summary
#chiline()
Builder and engineering leader with 13+ years designing, scaling, and operating distributed infrastructure. I lead platform engineering at Community.com, driving everything from cloud architecture and AI/ML infra to DevOps, SRE, and hands-on software development. Deep roots in Linux and system administration, with a security-first mindset and a focus on automation and resilience. I thrive in startup environments, solving hard technical problems, wearing many hats, and building systems that are fast, secure, and cost-effective. Deep expertise in Kubernetes, cloud-native platforms, and scaling teams and systems alike.

== Education
#chiline()

#link("https://www.port.ac.uk/")[*University of Portsmouth*] \
Computer Network Management and Design BSc (Hons) \
- First Class Honours (UK equivalent to GPA 4.0) \
- Winner of The School of Engineering Top Dissertation Project - 1st Place

== Work Experience
#chiline()

#link("https://www.community.com/")[*Community.com*] #h(1fr) September 2020 -- Present \
Staff Platform Engineer #h(1fr) _Remote, USA_ \
- Led the zero-downtime migration of 150+ microservices serving 5M+ unique external client API requests daily from Apache Mesos (EC2) to Kubernetes (EKS), running both platforms in parallel using our custom #link("https://github.com/ninesstack/sidecar")[sidecar] service discovery layer to enable seamless cutover and instant rollback.
- Built a customer support knowledgebase as an in-product popup chat component using LLM-based RAG with Agno, CopilotKit, Python and React, implementing vector search and real-time query processing for accurate company-related answers.
- Maintained event-driven platform processing 142+ million events monthly (113M message events, 15M entity events, 11M command and 3M metric events) using RabbitMQ clusters and Protobuf schemas, ensuring reliable message delivery across distributed microservices architecture.
- Own platform strategy, architecture, and operations, working closely with executive leadership to scale infrastructure while optimising for cost and reliability.
- Created a Go-based Slack bot leveraging OpenAI `GPT-4o` to automate runbook retrieval with simple vector RAG and insert on-call context, reducing friction during incidents and slashing response time.
- Optimised cloud infrastructure, maintaining a 99.5% uptime SLA while simplifying systems and reducing complexity.
- Drove a 33% annual reduction in cloud costs (~\$320K/year) by implementing spend controls, cost-aware policies, and systematic workload rightsizing across environments.
- Driving SOC 2 Type 2 audit preparation, implementing infrastructure controls, access policies, and internal security processes to align with compliance standards.
- Developed self-service infrastructure provisioning with Terraform and Ansible, and deployed highly available RabbitMQ clusters in Kubernetes and backed by HAProxy to ensure robust messaging and load distribution.

#link("https://www.nomura.com/")[*Nomura*] #h(1fr) May 2020 -- August 2020 \
VP Cloud Engineering #h(1fr) _Remote, UK_ \
- Contributed to the design and provisioning of core banking network infrastructure, including AWS DirectConnect, BGP, and VPC peering, using Terraform, Ansible, and Python to support secure, high-performance cloud connectivity.

#link("https://www.westpac.co.nz/")[*Westpac New Zealand*] #h(1fr) December 2018 -- November 2019 \
Senior Platform Engineer #h(1fr) _Auckland, New Zealand_ \
- Designed and implemented a fraud data processing platform using Kafka, Spark, Hadoop, Hive, and Airflow on Kubernetes. Integrated IBM MQ mainframe queues with Kafka to enable real-time fraud detection and transaction monitoring. Maintained and optimised Airflow pipelines for reliability and performance.

#link("https://bitcoin.com.au/")[*Bitcoin.com.au*] #h(1fr) November 2017 -- October 2018 \
DevOps Engineer #h(1fr) _Melbourne, Australia_ \
- Rebuilt the company’s cloud infrastructure from scratch, migrating to AWS using Terraform, Ansible, and Docker. Established isolated environments with new accounts, VPCs, and security best practices.
- Introduced GitLab and CI/CD pipelines to replace a previously unmanaged codebase, enabling version control, team collaboration, and safer deployments.
- Hardened platform during active DDoS attacks by implementing Cloudflare protections, and deployed highly available `bitcoind` nodes to ensure uptime and service reliability.

#link("https://www.ppluk.com/")[*PPL UK*] #h(1fr) July 2016 -- October 2017 \
DevOps Engineer #h(1fr) _London, UK_ \
- Led DevOps efforts during a major digital transformation initiative, modernising infrastructure with Apache Hadoop, AWS CloudFormation, and Docker in close collaboration with senior leadership.
- Rebuilt and automated the deployment of multiple Oracle WebLogic services using Selenium and Ansible, replacing fragile manual processes with reliable, repeatable pipelines.
- Developed an internal self-service platform using Rundeck, enabling non-technical teams to safely execute operational tasks and improving engineering efficiency.

#link("https://corsearch.com/incopro/")[*Incopro*] #h(1fr) May 2013 -- July 2016 \
Platform Engineer #h(1fr) _London, UK_ \
- Successfully acquired by Corsearch.
- Founding engineer at Incopro, built and scaled a distributed web scraping system using Selenium, Ansible, and residential proxies to monitor 1,000+ websites for trademark infringement.
- Designed and deployed data infrastructure using Cassandra and Elasticsearch to ingest and query gigabytes of scraped data daily for content protection and enforcement.
- Automated deployment and configuration of 500+ servers with Ansible, enabling scalable, reliable operations across a rapidly growing data platform.

#link("https://www.warnerbros.co.uk/")[*Warner Bros*] #h(1fr) July 2011 -- August 2012 \ 
Anti-Piracy Intern #h(1fr) _London, UK_
- Automated web scraping over hundreds of top sites and "cyberlockers" finding Warner Bro's copyrighted content.
- Managed the servers that ran webscrapers in colocated datacentres.

== Technical Skills
#chiline()

*Technical Methodologies*
- CI/CD, GitOps, Infrastructure as Code (IaC), Site Reliability Engineering (SRE), Observability, Microservices, Service Mesh, API Gateway, Cloud Migration, Incident Response, On-call, Cost Optimization, FinOps
*Software Engineering*
- Python, Golang, Elixir (intermediate), Ruby, Bash
*Infrastructure (IaC) & Cloud*
- Kubernetes, Docker, Helm, Containerd, Podman, AWS, GCP, Azure, Linux/UNIX, Terraform, Ansible, Packer, Vagrant
*Networking & Security*
- Drata, OpenVPN, WireGuard, Tailscale, HAProxy, Envoy, Kong, IAM, VPC, Cloudflare
*Databases & Messaging*
- PostgreSQL, Cassandra, MariaDB, DynamoDB, Trino, Athena, RabbitMQ, Elasticache, Elasticsearch, Redis, Prometheus, DuckDB, Protobuf
*DevOps & Monitoring*
- Git, Concourse, NewRelic, SumoLogic, AppSignal, PagerDuty, Jenkins
*Linux System Administration*
- Ubuntu, Debian, Alpine, CentOS, NixOS
*Machine Learning & AI*
- PyTorch, TensorFlow, OpenAI, Groq, Cursor, Windsurf, Databricks, Temporal, Agno, HuggingFace, llama.cpp

== Open-Source Contributions
#chiline()
*agno* #link("https://github.com/agno-agi/agno")[github.com/agno-agi/agno] #h(1fr) Since 2025
- Regular feature committer to `agno`. Agno is a full-stack framework for building Multi-Agent Systems with memory, knowledge and reasoning.
*sidecar* #link("https://github.com/NinesStack/sidecar")[github.com/NinesStack/sidecar] #h(1fr) Since 2023
- Sidecar is a dynamic service discovery platform requiring no external coordination service. It's a peer-to-peer system that uses a gossip protocol for all communication between hosts. Sidecar predates most modern service discovery systems and was originally developed at NewRelic.
- Community currently uses sidecar as service discovery in Kubernetes, I maintain the project with new features and maintenance releases as and when required.
*nmesos-k8s* #link("https://github.com/NinesStack/nmesos-k8s")[github.com/NinesStack/nmesos-k8s] #h(1fr) Since 2023
- Maintain community.com's internal version of the deployment tool to abstract simple YAML deployment manifests into complex Kubernetes objects and deploy (we open sourced the project to the `NinesStack` Github organisation). 

== Certifications
#chiline()
#link("https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka")[*Certified Kubernetes Administrator (CKA)*] #h(1fr) Expired 2023
- Certificate ID Number #link("https://www.credly.com/badges/e2b64d9e-9a8e-42ad-afb0-db552a480353")[`CKA-2000-007699-0100`]

#lastupdated(datetime.today().display())
