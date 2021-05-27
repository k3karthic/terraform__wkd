# Terraform - Host OpenPGP keys under a domain as a Web Key Directory (WKD)
Host a [Web Key Directory (WKD)](https://wiki.gnupg.org/WKD) to serve public keys usig the [Advanced Setup](https://keyoxide.org/guides/web-key-directory#the-advanced-setup) at https://openpgpkey.<domain\>

The public key is stored in an S3 bucket and served from a CloudFront distribution. CORS is enabled to allow [Keyoxide](https://keyoxide.org/) to encrypt messages using the public key and verify signatures created by the secret key.

## Input Variables

Create a file to store the input variables using the sample file `mumbai.tfvars.sample`. The file should be called `mumbai.tfvars` or edit `bin/plan.sh` with the appropriate file name.

## Deployment

### Step 1

Create a Terraform plan by running plan.sh; the script will read input variables from the file mumbai.tfvars

```
./bin/plan.sh
```

To avoid fetching the latest state of resources, run the following command.

```
./bin/plan.sh --refresh=false
```

### Step 2

Review the generated plan

```
./bin/view.sh
```

### Step 3

Run the verified plan

```
./bin/apply.sh
```

## Encryption

Sensitive files like the input variables (mumbai.tfvars) and Terraform state files are encrypted before being stored in the repository. 

You must add the unencrypted file paths to `.gitignore`.

Use the following command to decrypt the files after cloning the repository,

```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files,

```
./bin/encrypt.sh <gpg key id>
```
