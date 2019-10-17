# How to create an Azure Kubernetes Service (AKS) with Application Gateway as ingress controller

## Introduction

After read the article on how to [Create an Application Gateway ingress controller in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-aks-applicationgateway-ingress), it is clear the solution is not fully automated. The solution presented created all the components, like AKS Cluster, Application Gateway, and Virtual Network, but does not perform the ingress controller configuration, meaning, do not set up AAD Pod Identity, Service Principal, etc. One of my customers challenged me to have everything automated, so here we go. The objective of this article is to present a fully automated deployment of Azure Kubernetes Services using Application Gateway as Ingress Controller.



