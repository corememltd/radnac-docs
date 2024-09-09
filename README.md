The [RADIUS based Network Access Control (RADNAC)](https://radnac.com/) deployment for Azure: Documentation.

RADAC provides a native-esque Azure experience by being deployed as a [Managed Application](https://learn.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/overview) through the [Azure Marketplace](https://azuremarketplace.microsoft.com/) and integrating tightly with [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview).

This project covers public materials.

## Related Links

 * Azure:
    * [Tutorial: Create managed application with custom actions and resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/managed-applications/tutorial-create-managed-app-with-custom-provider)
    * [Azure - Incorporating swagger into Custom Providers](https://github.com/Azure/azure-custom-providers/tree/master/CustomRPWithSwagger)
 * [OpenAPI/Swagger](https://swagger.io/)
    * [OpenAPI Specification version 2.0 (Swagger)](https://swagger.io/docs/specification/2-0/what-is-swagger/)
    * [Swagger Editor](https://editor.swagger.io/)

# Usage

Interaction with the API is best done using the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) against your Managed Application deployment resource.

So start by logging in with:

    az login

As an end user, use the OpenAPI specification found in `specification/user/managed-application`.

To determine the API version your deployment uses inspect the value 'api.version' returned by running:

    az rest --verbose \
      --method post \
      --uri '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Solutions/applications/radnac-YYYYMMDDhhmmss/customstatus' \
      --uri-parameters api-version=2018-09-01-preview

**N.B.** `api-version` in the query string is not related to the specifications found in this repository and must be provided and set to the value shown as it is required and [consumed by Azure](https://learn.microsoft.com/en-us/rest/api/customproviders/custom-resource-provider)

The API version is fixed for a given deployment but may vary between differing deployments.

As an example, of using the API, to perform a 'restore' operation, use:

    az rest --verbose \
      --method post \
      --uri '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Solutions/applications/radnac-YYYYMMDDhhmmss/customrestore' \
      --uri-parameters api-version=2018-09-01-preview \
      --header 'content-type=application/json' \
      --body '{"url":"https://account.blob.core.windows.net/container/backups/radnac?..."}'

**N.B.** your request is validated at runtime against the specification

# Development

## Pre-flight

You will require pre-installed:

 * `m4`
 * `yq`

## Build

Generate the usable assets with:

    sh specification.sh
