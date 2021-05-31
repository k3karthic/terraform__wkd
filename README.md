# Terraform - Host a Web Key Directory (WKD)
A [Terraform](https://www.terraform.io/) script to host a [Web Key Directory (WKD)](https://wiki.gnupg.org/WKD) to serve an [OpenPGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) public key at `https://openpgpkey.<domain.name>` using the [WKD Advanced Setup](https://keyoxide.org/guides/web-key-directory#the-advanced-setup).

The public key is stored in an [Amazon S3](https://aws.amazon.com/s3/) bucket and served from an [Amazon CloudFront](https://aws.amazon.com/cloudfront/) distribution. [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) is enabled to allow [Keyoxide](https://keyoxide.org/) to encrypt messages using the public key and verify signatures created by the private key.

This Terraform script was used to deploy the key at [https://keyoxide.org/wkd/karthic%40maverickgeek.xyz](https://keyoxide.org/wkd/karthic%40maverickgeek.xyz).

![demo screenshot](https://github.com/k3karthic/terraform__wkd/raw/main/resources/demo_screenshot.png)

## Configuration

**Step 1.** Create a file to store the [Terraform input variables](https://www.terraform.io/docs/language/values/variables.html) using the sample file `mumbai.tfvars.sample`. The file should be called `mumbai.tfvars` or edit the following files with the appropriate filename,
1. `.gitignore`
1. `bin/plan.sh`
1. `bin/encrypt.sh`
1. `bin/decrypt.sh`

**Step 2.** Get the WKD hash for your public key using the following gpg command and save it as `key_hash`. The hash is just below the `uid` as `<hash>@<domain>`.
```
gpg --with-wkd-hash --fingerprint <email address>
```
![gpg screenshot](https://github.com/k3karthic/terraform__wkd/raw/main/resources/gpg_wkd_hash_screenshot.png)

**Step 3.** Export your public key into the `keys` folder using the script `bin/update_key.sh`. Replace `A38FE080` with your public key id and `m5am4h8agwz48rkwjqeeyp49pi8re5kb` with your WKD hash in `bin/update_key.sh`

**Step 4.** Obtain a certificate from [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) in the [US East (N. Virginia)](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html#https-requirements-aws-region) region for your domain and save the ARN in `acm_arn`.

![acm screenshot](https://github.com/k3karthic/terraform__wkd/raw/main/resources/acm_screenshot.png)

## Authentication

This Terraform script uses the [HashiCorp AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and the authentication options for the provider are available at [https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication).

[AWS CloudShell](https://aws.amazon.com/cloudshell/) is a pre-authenticated browser-based shell that can be used to deploy this script without additional configuration.

## Deployment

### Step 1

Use the following command to create a [Terraform plan](https://www.terraform.io/docs/cli/run/index.html#planning).
```
./bin/plan.sh
```

To avoid fetching the latest state of resources, use the following command.
```
./bin/plan.sh -refresh=false
```

### Step 2

Review the plan using the following command.
```
./bin/view.sh
```

### Step 3

[Apply](https://www.terraform.io/docs/cli/run/index.html#applying) the plan using the following command.
```
./bin/apply.sh
```

## Encryption

Sensitive files like the input variables (mumbai.tfvars) and [Terraform state](https://www.terraform.io/docs/language/state/index.html) files (terraform.tfstate) are encrypted before being stored in the repository. 

You must add the unencrypted file paths to `.gitignore`.

Use the following command to decrypt the files after cloning the repository.
```
./bin/decrypt.sh
```

Use the following command after running `bin/apply.sh` to encrypt the updated state files.
```
./bin/encrypt.sh <gpg key id>
```
