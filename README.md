# Azure-storage-account-JOIN-FILESHARE-TO-AD-TERRAFORM
This Terraform module facilitates the creation of an Azure Storage Account along with the configuration of a File Share, while seamlessly integrating it with an Active Directory (AD) domain. The module ensures a streamlined process for provisioning storage resources in the Azure cloud environment, enhancing the overall manageability and security of file storage.
The provided Terraform code implements several key features for the creation and configuration of an Azure Storage Account and File Share with Active Directory integration. Here are the key features:
Azure Storage Account Creation:

Efficiently creates an Azure Storage Account based on a naming convention provided by a separate module (nc_storage_account), allowing for consistent and organized resource naming.
File Share Configuration:

Configures a dedicated File Share within the Azure Storage Account, providing a centralized location for file storage and sharing.
Active Directory Integration:

Seamlessly integrates the File Share with Active Directory, allowing for secure access controls and authentication. This includes specifying domain-specific configurations such as domain name, domain GUID, and domain SID.
Azure Key Vault Integration:

Integrates with Azure Key Vault for managing encryption keys. Configures access policies to grant necessary permissions to the storage account and creates a customer-managed key for enhanced security.
Network Rules Configuration:

Defines network rules for the Storage Account, allowing fine-grained control over incoming traffic. This includes specifying IP rules and virtual network subnet IDs.
Routing Settings Configuration:

Configures routing settings for the Storage Account, specifying the choice of routing mechanism and whether to publish internet or Microsoft endpoints.
Blob Properties Configuration:

Configures various properties related to blob storage, including delete retention policies, restore policies, container delete retention policies, versioning, and change feed.
SMB Configuration:

Configures Server Message Block (SMB) properties for the File Share, including authentication types, channel encryption, Kerberos ticket encryption, multichannel support, and supported SMB protocol versions.
Azure Files Authentication Settings:

Dynamically configures Azure Files authentication settings based on the value of var.joinAD_enabled. Allows for the specification of Active Directory details such as domain name, domain GUID, domain SID, netbios domain name, and forest name.
Diagnostic Settings:

Configures diagnostic settings for monitoring, enabling the collection of metrics and audit logs for both the storage account and blob storage. Supports integration with a Log Analytics workspace.
Terraform Automation:

Leverages Terraform's infrastructure-as-code principles, providing version-controlled and reproducible infrastructure deployments.
These features collectively contribute to the creation of a secure, organized, and fully configured Azure Storage Account and File Share with seamless integration into an Active Directory environment. The modular and dynamic nature of the code enhances adaptability and maintainability across different scenarios and configurations.
