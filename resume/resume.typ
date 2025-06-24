// For more customizable options, please refer to official reference: https://typst.app/docs/reference/

#show heading: set text(font: "libertinus serif")
#show link: underline

// #set text(size: 11pt)

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
Engineering leader and hands-on IC with over 13 years experience designing, scaling, and managing distributed systems. Currently leading platform engineering at Community.com, driving infrastructure, AI, and operational strategy. Proven track record of building resilient platforms, optimizing cloud and compute costs, and aligning engineering roadmaps with business objectives. Deep expertise in Kubernetes, cloud-native architecture, and AI/ML infrastructure. Passionate about solving complex technical challenges, fostering high-performing teams, and delivering scalable, reliable solutions.

== Education
#chiline()

*University of Portsmouth* \
Computer Network Management and Design BSc (Hons) \
- First Class Honours (UK equivalent to GPA 4.0) \
- Winner of The School of Engineering Top Dissertation Project - 1st Place

== Work Experience
#chiline()

*Community.com* #h(1fr) September 2020 -- Present \
Staff Platform Engineer #h(1fr) Remote, UK \
- Built a customer and internal knowledgebase as an in-product popup chat component using LLM-based RAG with Agno, CopilotKit, Python, and React, implementing vector search and real-time query processing for accurate company-related answers.
- Lead strategy, architecture, and operations for the platform team, collaborating closely with the CTO and VP of Architecture to drive scalable, cost-efficient infrastructure solutions. \
- Spearheaded the migration from Apache Mesos to Kubernetes on AWS, ensuring high availability and minimal disruption during the transition. \
- Developed an AI-driven On-Call Slack Bot in Go that streamlined access to community runbooks and on-call information; facilitating a 50% reduction in manual lookup times during active incidents. \
- Optimized cloud infrastructure, maintaining a 99.5% uptime SLA while simplifying systems and reducing complexity. \
- Achieved an average 33% annual cloud cost reduction (\$320,000) by implementing spend controls, policies, and workload rightsizing.

*Nomura* #h(1fr) May 2020 -- August 2020 \
VP Cloud Engineering #h(1fr) Remote, UK \
- Led the design and provisioning of core banking network infrastructure at Nomura, implementing AWS DirectConnect, BGP, and VPC peering. Utilized Terraform, Ansible, and Python to automate deployment, ensuring secure, high-performance cloud connectivity for critical financial operations.

*Westpac New Zealand* #h(1fr) December 2018 -- November 2019 \
Senior Platform Engineer #h(1fr) Auckland, New Zealand \
- Designed and implemented a fraud data processing platform leveraging Kafka, Spark, Hadoop, Hive, and Airflow on Kubernetes. Integrated IBM MQ mainframe queues with Kafka for real-time fraud detection and transaction monitoring.

*Bitcoin.com.au* #h(1fr) November 2017 -- October 2018 \
DevOps Engineer #h(1fr) Melbourne, Australia \
- Led the migration of the entire platform to AWS with Terraform, Ansible, and Docker. Rewrote their fiat-to-Bitcoin payment gateway for improved robustness and scalability.

*PPL UK* #h(1fr) July 2016 -- October 2017 \
DevOps Engineer #h(1fr) London, UK \
- Drove DevOps innovation as part of their digital transformation programme, working closely with leadership to revolutionize infrastructure with Apache Hadoop, AWS CloudFormation, and Docker.

*Incopro* #h(1fr) May 2013 -- July 2016 \
Platform Engineer #h(1fr) London, UK \
- Founding member of Incopro, automating deployments for 500+ servers with Ansible and scaling web scraping to protect content and trademarks across 1,000+ sites.

== Technical Skills
#chiline()

*Programming:* Python, Go, Ruby, Shell derivatives (Bash etc.)  
*Leadership & Management:* Engineering Leadership, People Management, Project Management  
*Infrastructure (IaC) & Cloud:* Kubernetes, Docker, Helm, Containerd, Podman, AWS, GCP, Azure, Linux/UNIX, Terraform, Ansible, Packer, Vagrant  
*Networking & Security:* OpenVPN, WireGuard, Tailscale, HAProxy, Envoy, Kong, IAM, VPC, Cloudflare  
*Databases & Messaging:* PostgreSQL, Cassandra, MariaDB, DynamoDB, Trino, Athena, RabbitMQ, Elasticache, Elasticsearch, Redis, Prometheus  
*DevOps & Monitoring:* Git, Concourse, NewRelic, SumoLogic, AppSignal, PagerDuty, Jenkins  
*Machine Learning & AI:* PyTorch, TensorFlow, FastAPI, OpenAI, Hugging Face, LlamaIndex, LLamafile, Ollama, Databricks, Temporal

== Open-Source Contributions
#chiline()

== Links
#chiline()

Github: #link("https://github.com/danpilch")[danpilch]  
LinkedIn: #link("https://www.linkedin.com/in/danpilch")[danpilch]

#lastupdated(datetime.today().display())
