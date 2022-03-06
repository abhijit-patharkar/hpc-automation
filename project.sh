#!/bin/bash
gcloud projects create $1
gcloud projects add-iam-policy-binding $1 --member=serviceAccount:vasten-service-account@tactile-acolyte-282822.iam.gserviceaccount.com --role=roles/editor
gcloud config set project $1
gcloud alpha billing accounts projects link $1 --billing-account=017421-A19C6D-252A9A	
gcloud services enable file.googleapis.com
gcloud services enable networkservices.googleapis.com
gcloud services enable compute.googleapis.com
gcloud compute --project=$1 images create vasten-2x --source-image=vasten-2x --source-image-project=tactile-acolyte-282822
gcloud compute --project=$1 images create ubuntu-gui --source-image=ubuntu-gui --source-image-project=tactile-acolyte-282822
