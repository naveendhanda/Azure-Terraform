# Azure Traffic Manager with Application Gateways

This Terraform configuration deploys an Azure Traffic Manager with two Application Gateways as backend endpoints in different Azure regions.

## Architecture Overview

```
Internet Traffic
      |
      v
[Traffic Manager]
      |
   (Routes traffic based on configured method)
      |
      +-- [Application Gateway 1] (Region 1: East US)
      |        |
      |        +-- [Backend Pool] (Ready for your applications)
      |
      +-- [Application Gateway 2] (Region 2: West US)
               |
               +-- [Backend Pool] (Ready for your applications)
```

## Resources Created

- **Resource Group**: Container for all resources
- **Virtual Networks**: One in each region for the Application Gateways
- **Subnets**: Dedicated subnets for Application Gateways
- **Public IP Addresses**: Static IPs for Application Gateways with DNS labels
- **Application Gateways**: Two Standard_v2 Application Gateways in different regions
- **Traffic Manager Profile**: Global load balancer with health monitoring
- **Traffic Manager Endpoints**: Endpoints pointing to Application Gateway public IPs

## Features

- **Multi-region deployment**: Application Gateways deployed in two different Azure regions
- **High availability**: Traffic Manager provides automatic failover
- **Health monitoring**: Built-in health checks for endpoints
- **Configurable routing**: Support for multiple traffic routing methods
- **Standard_v2 SKU**: Modern Application Gateway tier with autoscaling capabilities

## Prerequisites

1. **Azure Subscription**: You need an active Azure subscription
2. **Terraform**: Install Terraform (version 1.0+)
3. **Azure CLI**: Install and configure Azure CLI
4. **Service Principal**: Or use other Azure authentication methods

## Authentication

Ensure you're authenticated to Azure. You can use one of these methods:

```bash
# Azure CLI login
az login

# Or set environment variables for Service Principal
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

## Deployment

1. **Clone or download** this Terraform configuration

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review and modify variables** (optional):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Confirm the deployment** by typing `yes` when prompted

## Configuration Options

### Variables

| Variable | Description | Default | Options |
|----------|-------------|---------|---------|
| `resource_group_name` | Name of the resource group | `rg-traffic-manager-demo` | Any valid name |
| `location` | Primary region for resource group | `East US` | Any Azure region |
| `region1` | First region for Application Gateway | `East US` | Any Azure region |
| `region2` | Second region for Application Gateway | `West US` | Any Azure region |
| `traffic_manager_name` | Traffic Manager profile name | `tm-appgw-demo` | Any valid name |
| `traffic_manager_dns_name` | DNS name for Traffic Manager | `tm-appgw-demo` | Any valid DNS name |
| `traffic_routing_method` | Traffic routing method | `Performance` | Performance, Weighted, Priority, Geographic, MultiValue, Subnet |

### Traffic Routing Methods

- **Performance**: Routes traffic to the endpoint with the lowest latency
- **Weighted**: Distributes traffic based on assigned weights
- **Priority**: Routes traffic to the highest priority available endpoint
- **Geographic**: Routes traffic based on geographic location of DNS query
- **MultiValue**: Returns multiple healthy endpoints
- **Subnet**: Routes traffic based on source IP subnet

## Post-Deployment

After deployment, you'll receive outputs including:

- Traffic Manager FQDN (use this as your application endpoint)
- Application Gateway FQDNs and IP addresses
- Resource IDs for further configuration

### Adding Backend Servers

To make your Application Gateways functional, you'll need to:

1. Deploy your application servers (VMs, App Services, etc.)
2. Add them to the Application Gateway backend pools
3. Configure health probes as needed

Example to add a VM to the backend pool:

```bash
az network application-gateway address-pool update \
  --gateway-name appgw-eastus \
  --resource-group rg-traffic-manager-demo \
  --name backend-pool \
  --servers 10.0.2.4
```

## Monitoring and Management

- **Azure Portal**: Monitor Traffic Manager and Application Gateway metrics
- **Health Checks**: Traffic Manager automatically monitors endpoint health
- **Scaling**: Application Gateways support autoscaling (can be configured)
- **SSL/TLS**: Add SSL certificates and configure HTTPS (additional configuration needed)

## Cost Optimization

- Application Gateways use Standard_v2 SKU with capacity 2 (adjustable)
- Consider using autoscaling for production workloads
- Traffic Manager has minimal cost but charges per DNS query

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Security Considerations

- Application Gateways are configured for HTTP (port 80) by default
- Add SSL/TLS certificates for production use
- Configure Web Application Firewall (WAF) for additional security
- Use Network Security Groups for additional network security

## Troubleshooting

### Common Issues

1. **Region availability**: Ensure selected regions support Application Gateway v2
2. **Resource naming**: Azure resource names must be unique within certain scopes
3. **Quotas**: Check Azure subscription quotas for Application Gateways
4. **DNS propagation**: Traffic Manager DNS changes may take time to propagate

### Useful Commands

```bash
# Check Traffic Manager status
az network traffic-manager profile show --name tm-appgw-demo --resource-group rg-traffic-manager-demo

# Check Application Gateway status
az network application-gateway show --name appgw-eastus --resource-group rg-traffic-manager-demo

# View Terraform state
terraform show
```

## Next Steps

1. **Configure SSL/HTTPS**: Add certificates and configure HTTPS listeners
2. **Add backend servers**: Deploy and configure your application servers
3. **Set up monitoring**: Configure Azure Monitor and Application Insights
4. **Implement WAF**: Add Web Application Firewall rules for security
5. **Custom domains**: Configure custom domain names for your applications

## Support

For issues with this Terraform configuration:
- Check the Terraform AzureRM provider documentation
- Review Azure Application Gateway and Traffic Manager documentation
- Validate your Azure permissions and quotas