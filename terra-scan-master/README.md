# Infrastructure As Code Scanning (IAC scanning)

In this workshop we will be demonstrating a popular open source IAC scanning tool called Checkov. 

## Checkov

The first task is to install Checkov on your system:
```
pip install checkov --user
```

Verify Checkov is working:
```
checkov -v
```
You should see a version printed if everything is working correctly.

## Terraform

Install terraform using [tfenv](https://github.com/tfutils/tfenv)

Navigate to the provided example
```
cd terra-scan [aws/azure]
```

Init terraform
```
terraform init
```

You should see a successful invocation and a .terraform folder should be created to store your state file.
Ensure your terraform can deploy:
```
terraform plan
```

You should see a successful plan here meaning we are deploying code which is valid to terraform, even though this code has common misconfigurations.

* NOTE if you do not see a successfull terraform plan, you must ensure your aws/azure configuration is set correctly on your machine.



## Code scanning example

The provided terraform code provides a very basic set of deployments. The first is an S3 object storage bucket on the AWS platform using a standard aws provider, there are 2 errors in this Terraform configuration, one which could be identified by manual review and one which could not.

*possible guess*

The first known error is inside provider.tf on lines `11-12`. Here you can the see user has hard coded their access keys to the AWS platform, inside the terraform resource itself, this a common mistake that can commonly be picked up by manual review of naive regex checks.

The second vulnerability may be a little harder to spot, so we will use Checkov to help us out here:
```
checkov -d aws
```

When running this you will see a large amount of text generated a report, the report is split into two sections Terraform and Secrets. In each section you will be presented with a summary of the results from each section.

*can anyone guess which was the error*

You will see that Chekov correctly discovered multiple issues with our code, identify the exposed secret but also the fact that our S3 bucket had no encryption enabled, among other things.

```
Check: CKV_AWS_19: "Ensure all data stored in the S3 bucket is securely encrypted at rest"
        FAILED for resource: aws_s3_bucket.data_science
        File: /s3.tf:1-13
        Guide: https://docs.bridgecrew.io/docs/s3_14-data-encrypted-at-rest

                1  | resource "aws_s3_bucket" "data_science" {
                2  |   # bucket is not encrypted (not so easy to spot)
                3  |   bucket = "${local.resource_prefix.value}-data-science"
                4  |   acl    = "private"
                5  |   versioning {
                6  |     enabled = true
                7  |   }
                8  |   logging {
                9  |     target_bucket = "${aws_s3_bucket.logs.id}"
                10 |     target_prefix = "log/"
                11 |   }
                12 |   force_destroy = true
                13 | }
```

The second example of a simple AKS deployment into Azure, which demonstrates the flexibility of checkov with it's multi-cloud support. Along side some more adavanced features aimed at reducing false positives.

As we did in the previous step, we must run checkov on the Azure code:
```
checkov -d azure
```
This time checkov will again detect multiple issues with the aks deployment, however one key part to note here is that we also added a handy comment in our terraform code:

```
  #checkov:skip=CKV_AZURE_4:Ignore logging errors
```

As you will now see, checkov has parsed this and made sure we do not see errors related to this policy:

```
Check: CKV_AZURE_4: "Ensure AKS logging to Azure Monitoring is Configured"
        SKIPPED for resource: azurerm_kubernetes_cluster.k8s_cluster
        Suppress comment: Ignore logging errors
        File: /aks.tf:1-27
        Guide: https://docs.bridgecrew.io/docs/bc_azr_kubernetes_1
```