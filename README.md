# Play 2.8 Runner
Alpine based image with tools and scripts installed to support the running of a **Play Framework 2.8** server.
Expects build artifacts mounted at /home/runner/artifacts.
Timezone can be set via the TZ environment varaible.

This runner also provides ability to fetch prebuilt artifacts from an AWS S3 bucket location. The S3 URI should be 
provided to the runner image as argument and also you need to provide ENVs for AWS credentials (that is configured to fetch artifacts from specified S3 bucket) to the runner. 

e.g. ```docker run -e AWS_ACCESS_KEY_ID={you_access_key_id} -e AWS_SECRET_ACCESS_KEY={your_secret} play28-runner s3://artifacts/component/release_number```
