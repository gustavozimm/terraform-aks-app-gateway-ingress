# How to create an Azure Kubernetes Service (AKS) with Application Gateway as ingress controller

## Introduction

After read the article on how to [Create an Application Gateway ingress controller in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-aks-applicationgateway-ingress), it is clear the solution is not fully automated. The solution presented created all the components, like AKS Cluster, Application Gateway, and Virtual Network, but does not perform the ingress controller configuration, meaning, do not set up AAD Pod Identity, Service Principal, etc. One of my customers challenged me to have everything automated, so here we go. The objective of this article is to present a fully automated deployment of Azure Kubernetes Services using Application Gateway as Ingress Controller.

## Workloads Deployed

The Terraform template is configured to deploy the following components:

* Azure Kubernetes Services
* Azure Application Gateway
* Azure Database for MySQL
* Virtual Network with two subnets
    * Subnet for AKS nodes
    * Subnet for Application Gateway
* Public IP
* Persistent Volume Claim (PVC)

## Prerequisites


## Setup correct subscription

## Terraform Variables Config files

## Declaring Variables

## Defining Resources 
