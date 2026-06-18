## Automated CI/CD Infrastructure & Multi-Tier Monitoring System

## Project Goal: Provision, automate, and monitor a CI/CD infrastructure using Terraform, Docker, Jenkins, Prometheus, and Grafana.

## PROVISION INFRASTRUCTURE (TERRAFORM):
Create the base Ubuntu server in AWS using Infrastructure as Code (IaC) to ensure consistency.
---bash
terraform init
terraform plan
terraform apply -auto-approve

## CONFIGURE DOCKER ENVIRONMENT:
Install the Docker engine to host all our DevOps tools as isolated containers.
---bash
sudo apt-get update
sudo apt-get install docker.io -y

## CONFIGURE USER PERMISSIONS:
Enable the ubuntu user to run Docker commands without needing sudo every time.
---bash
sudo usermod -aG docker $USER
newgrp docker

## DEPLOY JENKINS (CI/CD):
Launch Jenkins with "Docker-in-Docker" (DinD) capabilities so it can build container images.
---bash
sudo docker run -d

--name jenkins

-p 8080:8080 -p 50000:50000

-v /var/run/docker.sock:/var/run/docker.sock

-v jenkins_home:/var/jenkins_home

jenkins/jenkins:lts

## INSTALL JENKINS PROMETHEUS PLUGIN:
Inside the Jenkins UI (Port 8080), install the Prometheus metrics plugin so Jenkins can export data.

Manage Jenkins -> Plugins -> Available Plugins.

Search "Prometheus metrics" and Install.

Restart Jenkins.

## SETUP NODE EXPORTER:
Launch Node Exporter to "read" the hardware metrics (CPU/RAM/Disk) of your Ubuntu server.
---bash
sudo docker run -d

--name node-exporter

-p 9100:9100

prom/node-exporter

## CREATE PROMETHEUS CONFIGURATION FILE:
Create a file named prometheus.yml to define the targets that Prometheus will monitor.
---yaml
scrape_configs:
- job_name: 'prometheus'
static_configs:
- targets: ['localhost:9090']

    - job_name: 'node_exporter'
      static_configs:
        - targets: ['34.239.150.182:9100']

    - job_name: 'jenkins'
      metrics_path: '/prometheus/'
      static_configs:
        - targets: ['34.239.150.182:8080']
## DEPLOY PROMETHEUS:
Launch Prometheus and "link" prometheus.yml file into the container using a volume.
---bash
sudo docker run -d

--name prometheus

-p 9090:9090

-v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml

prom/prometheus

## DEPLOY GRAFANA (VISUALIZATION):
Launch the Grafana container to create dashboards for your metrics.
---bash
sudo docker run -d

--name grafana

-p 3000:3000

grafana/grafana

## CONFIGURE GRAFANA DATA SOURCE:
Connect Grafana to Prometheus so it can pull the data.

Login to Grafana at http://<YOUR-IP>:3000.

Go to Connections -> Data Sources.

Add Prometheus and set the URL to http://<YOUR-IP>:9090.

## IMPORT SERVER MONITORING DASHBOARD:
Import a pre-built dashboard to see your Ubuntu server's health.

Dashboards -> New -> Import.

Enter ID 1860 (Node Exporter Full) and Load.

## IMPORT JENKINS MONITORING DASHBOARD:
Import a dashboard to see your Jenkins pipeline success/failure stats.

Dashboards -> New -> Import.

Enter ID 9964 (Jenkins Performance) and Load.

## MONITOR DISK SPACE (CRITICAL):
Check your disk space regularly to prevent the "Jenkins Offline" error.
---bash
df -h
# Look for /dev/root usage percentage.

## PERFORM DOCKER SYSTEM CLEANUP:
If the disk hits 99% usage, use this command to reclaim space.
---bash
sudo docker system prune -a --volumes -f
# This reclaimed 1.67GB in project.

## RESTART MONITORING STACK:
After a cleanup or config change, restart the containers to ensure they are active.
---bash
sudo docker restart prometheus jenkins grafana node-exporter

## CONCLUSION: SUCCESSFULLY IMPLEMENTED A FULL-STACK CI/CD PIPELINE WITH INFRASTRUCTURE-AS-CODE AND TOTAL OBSERVABILITY.
