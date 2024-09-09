define(`__Q__', ``''')dnl
swagger: '2.0'
info:
  version: 2024-01-01-preview
  title: RADNAC REST API
  description: Azure REST API
host: management.azure.com
schemes:
  - https
security:
ifdef(`MP', `dnl
  - msEntraIDAuthentication:
      - user_impersonation', `dnl
  - azureFunctionAccessKey: []')
securityDefinitions:
ifdef(`MP', `dnl
  msEntraIDAuthentication:
    description: Microsoft Entra ID OAuth2 Flow
    type: oauth2
    authorizationUrl: https://login.microsoftonline.com/common/oauth2/authorize
    flow: implicit
    scopes:
      user_impersonation: Impersonate your user account', `dnl
  azureFunctionAccessKey:
    description: Provides per deployment authorization (Azure Function access key)
    type: apiKey
    in: query
    name: code')
paths:
  PREFIX`ping':
    post:
      operationId: pingAction
      description: Initiate an ICMP ping to the service(s)
      parameters:
        - $ref: '#/parameters/subscriptionId'
        - $ref: '#/parameters/resourceGroupName'
ifdef(`MP', `dnl
        - $ref: __Q__`#/parameters/resourceName'__Q__
        - $ref: __Q__`#/parameters/apiVersion'__Q__', `dnl
        - $ref: __Q__`#/parameters/customRpName'__Q__')
      consumes:
        - application/json
      produces:
        - application/json
      responses:
        '200':
          description: success
  PREFIX`backup':
    post:
      operationId: backupAction
      description: Create and upload a backup to the provided URL
      parameters:
        - $ref: '#/parameters/subscriptionId'
        - $ref: '#/parameters/resourceGroupName'
ifdef(`MP', `dnl
        - $ref: __Q__`#/parameters/resourceName'__Q__
        - $ref: __Q__`#/parameters/apiVersion'__Q__', `dnl
        - $ref: __Q__`#/parameters/customRpName'__Q__')
        - name: parameters
          description: Parameters to the backup function
          in: body
          schema:
            $ref: '#/definitions/backup'
      consumes:
        - application/json
      produces:
        - application/json
      responses:
        '204':
          description: success
        '400':
          description: invalid parameters
          schema:
            $ref: '#/definitions/error'
        '502':
          description: destination URL generated an non-2xx response
          schema:
            $ref: '#/definitions/error'
  PREFIX`restore':
    post:
      operationId: restoreAction
      description: Download and restore a backup from the provided URL
      parameters:
        - $ref: '#/parameters/subscriptionId'
        - $ref: '#/parameters/resourceGroupName'
ifdef(`MP', `dnl
        - $ref: __Q__`#/parameters/resourceName'__Q__
        - $ref: __Q__`#/parameters/apiVersion'__Q__', `dnl
        - $ref: __Q__`#/parameters/customRpName'__Q__')
        - name: parameters
          description: Parameters to the backup function
          in: body
          required: true
          schema:
            $ref: '#/definitions/restore'
      consumes:
        - application/json
      produces:
        - application/json
      responses:
        '200':
          description: success
          schema:
            type: object
            properties:
              success:
                description: statement if there was an error
                type: boolean
              log:
                description: breakdown of each file that was processed
                type: array
                items:
                  type: object
                  properties:
                    name:
                      description: name of the section being imported
                      type: string
                      enum:
                        - msentraid
                        - group
                        - user
                        - client
                        - server
                    stats:
                      type: object
                      properties:
                        load:
                          type: integer
                        drop:
                          type: integer
                    error:
                      description: error message
                      type: string
                  required:
                    - name
            required:
              - success
              - log
        '400':
          description: invalid parameters
          schema:
            $ref: '#/definitions/error'
        '502':
          description: source URL generated an non-2xx response
          schema:
            $ref: '#/definitions/error'
definitions:
  error:
    # https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/common-api-details.md
    description: The error body contract
    type: object
    properties:
      error:
        description: The error details for a failed request
        type: object
        properties:
          code:
            description: The error type
            type: string
          message:
            description: The error message
            type: string
          details:
            description: The error details
            type: array
            items:
              type: object
              properties:
                code:
                  description: The error details code
                  type: string
                message:
                  description: The error details message
                  type: string
              required:
                - code
                - message
          innererror:
            type: object
        required:
          - code
          - message
  backup:
    description: Parameters for the backup action
    type: object
    properties:
      method:
        description: "HTTP method to use to upload backup (the header 'x-ms-blob-type: BlockBlob' will automatically be added for detected Azure Storage Account blob uploads)"
        type: string
        default: PUT
        enum:
          - PUT
          - POST
      headers:
        description: HTTP headers to include with request
        type: array
        items:
          type: object
          properties:
            name:
              description: HTTP header name
              type: string
              pattern: ^\w[\w-]*\w$
            value:
              description: HTTP header value
              type: string
              pattern: ^[\x20-\x7e]+$
          example:
            name: authorization
            value: Bearer e3R5cDpKV1Qs...
      url:
        type: string
        description: URL location for the backup
        pattern: ^https?://
        example: https://STORAGEACCOUNT.blob.core.windows.net/CONTAINER/FILE?sp=w&st=2024-01-01T10:00:00Z&se=2024-01-01T10:15:00Z&spr=https&sv=2022-11-02&sr=b&sig=...
    required:
      - url
  restore:
    description: Parameters for the restore action
    type: object
    properties:
      method:
        description: HTTP method to use to download backup
        type: string
        default: GET
        enum:
          - GET
      headers:
        description: HTTP headers to include with request
        type: array
        items:
          type: object
          properties:
            name:
              description: HTTP header name
              type: string
              pattern: ^\w[\w-]*\w$
            value:
              description: HTTP header value
              type: string
              pattern: ^[\x20-\x7e]+$
          example:
            name: authorization
            value: Bearer e3R5cDpKV1Qs...
      url:
        type: string
        description: URL location for the backup
        pattern: ^https?://
        example: https://STORAGEACCOUNT.blob.core.windows.net/CONTAINER/FILE?sp=r&st=2024-01-01T10:00:00Z&se=2024-01-01T10:15:00Z&spr=https&sv=2022-11-02&sr=b&sig=...
    required:
      - url
parameters:
  subscriptionId:
    name: subscriptionId
    description: The subscription ID
    type: string
    in: path
    required: true
    minLength: 36
    maxLength: 36
    pattern: ^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$
  # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftresources
  resourceGroupName:
    name: resourceGroupName
    description: Resource group name (not case sensitive)
    type: string
    in: path
    required: true
    minLength: 1
    maxLength: 90
    pattern: ^[\w._()-]+(?!\.)$
ifdef(`MP', `dnl
  # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcustomproviders
  resourceName:
    name: resourceName
    description: Resource name (not case sensitive)
    type: string
    in: path
    required: true
  # https://learn.microsoft.com/en-us/rest/api/customproviders/
  apiVersion:
    name: api-version
    description: Azure ARM Resource API version
    type: string
    in: query
    required: true
    enum:
      - 2018-09-01-preview', `dnl
  customRpName:
    name: resourceName
    description: Resource name (not case sensitive)
    type: string
    in: path
    required: true
    enum:
     - public')
