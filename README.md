# Terraform - Host a Web Key Directory (WKD)
Host a [Web Key Directory (WKD)](https://wiki.gnupg.org/WKD) to serve an OpenPGP public key at `https://openpgpkey.<domain.name>` using the [WKD Advanced Setup](https://keyoxide.org/guides/web-key-directory#the-advanced-setup).

The public key is stored in an S3 bucket and served from a CloudFront distribution. CORS is enabled to allow [Keyoxide](https://keyoxide.org/) to encrypt messages using the public key and verify signatures created by the private key.

## Configuration

**Step 1.** Create a file to store the input variables using the sample file `mumbai.tfvars.sample`. The file should be called `mumbai.tfvars` or edit the following files with the appropriate filename,
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

**Step 4.** Obtain a certificate from [ACM](https://aws.amazon.com/certificate-manager/) for your domain and save the ARN in `acm_arn`.

## Deployment

### Step 1

Create a Terraform plan by running plan.sh; the script will read input variables from the file mumbai.tfvars.
```
./bin/plan.sh
```

To avoid fetching the latest state of resources, run the following command.
```
./bin/plan.sh --refresh=false
```

### Step 2

Review the generated plan.
```
./bin/view.sh
```

### Step 3

Run the verified plan.
```
./bin/apply.sh
```

## Encryption

Sensitive files like the input variables (mumbai.tfvars) and Terraform state files are encrypted before being stored in the repository. 

You must add the unencrypted file paths to `.gitignore`.

Use the following command to decrypt the files after cloning the repository.
```
./bin/decrypt.sh
```

Use the following command after running terraform to update the encrypted files.
```
./bin/encrypt.sh <gpg key id>
```
