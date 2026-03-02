# API Gateway Assignment – Manual Configuration and Terraform Automation

This project demonstrates the creation of a REST API using Amazon API Gateway in the **ap-south-1 (Mumbai)** region.

The assignment is completed in two stages:
- Manual setup using AWS Console
- Automation using Terraform (Infrastructure as Code)

A single REST API was created with three endpoints, each integrated with a public backend service. All routes are deployed under a common stage named **v1** and share the same base invoke URL. CORS has been configured for cross-origin access.

---

# Level 1 – Manual API Configuration

## Base Invoke URL

https://s5p2ay9de5.execute-api.ap-south-1.amazonaws.com/v1

---

## Route 1 – /json/{todo}

**Backend API:** JSONPlaceholder  
**Integration Type:** HTTP Proxy

This route forwards the request to the backend JSONPlaceholder API to retrieve todo data.

### Curl Test

curl https://s5p2ay9de5.execute-api.ap-south-1.amazonaws.com/v1/json/todos

Expected Result: Returns a JSON list of todo items.

---

## Route 2 – /weather

**Backend API:** Open-Meteo  
**Integration Type:** Query parameter mapping

Required query parameters:
- latitude
- longitude

Optional parameter:
- hourly

### Curl Test

curl "https://s5p2ay9de5.execute-api.ap-south-1.amazonaws.com/v1/weather?latitude=13.0827&longitude=80.2707"

Expected Result: Returns weather details for the specified coordinates.

---

## Route 3 – /countries/{name}

**Backend API:** REST Countries  
**Integration Type:** Path parameter forwarding

This route forwards the country name to the backend API.

### Curl Test

curl https://s5p2ay9de5.execute-api.ap-south-1.amazonaws.com/v1/countries/japan

Expected Result: Returns detailed country information for Japan.

---

## CORS Configuration

CORS has been enabled for all endpoints with the following configuration:

- Allowed Origins: *
- Allowed Methods: GET, OPTIONS
- Default headers enabled

---

## Manual Configuration Summary

- Single REST API created
- Three routes configured
- Stage name: v1
- Shared base invoke URL
- Successful backend integrations
- CORS enabled on all routes
- Curl commands tested and verified

Screenshots of Resources, Methods, Integrations, and Stage deployment are included in the repository.

---

# Level 2 – Terraform Automation

This stage recreates the same API Gateway infrastructure using Terraform.

## Infrastructure Provisioned

- REST API Gateway
- Three routes
- Deployment stage: v1
- Automatic redeployment on configuration changes
- Output variable displaying invoke URL

---

## Prerequisites

- AWS CLI configured
- Terraform installed
- AWS Free Tier account

---

## Deployment Steps

```bash
cd api_terraform
terraform init
terraform plan
terraform apply
```

## Terraform Output

After successful deployment:

invoke_url = https://59z84f5isb.execute-api.ap-south-1.amazonaws.com/v1

---

## Destroy Infrastructure

```bash
terraform destroy
```

## Conclusion

This project provided practical experience in building and automating a REST API using Amazon API Gateway. In Level 1, the API was manually configured through the AWS Console to gain a clear understanding of resources, methods, integrations, stages, and CORS behavior.

In Level 2, the same setup was automated using Terraform, applying Infrastructure as Code (IaC) principles to ensure repeatability, consistency, and easier management. Overall, the assignment strengthened hands-on knowledge in AWS services, API integration, and DevOps automation practices
