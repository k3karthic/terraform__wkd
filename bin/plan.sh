#!/usr/bin/env bash

terraform plan -var-file=wkd.tfvars --out=tf.plan $@
