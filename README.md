# How to create an Azure Kubernetes Service (AKS) with Application Gateway as ingress controller - Fully Automated

## Introduction

After read the article on how to [Create an Application Gateway ingress controller in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-aks-applicationgateway-ingress), it is clear the solution is not fully automated. The solution presented created all the components, like AKS Cluster, Application Gateway, and Virtual Network, but does not perform the configuration, meaning, do not set up AAD Pod Identity, Service Principal

