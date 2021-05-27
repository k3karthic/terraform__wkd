#!/usr/bin/env bash

terraform plan -var-file=mumbai.tfvars --out=tf.plan $@
