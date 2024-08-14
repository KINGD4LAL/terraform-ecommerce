# terraform-ecommerce

terraform for the e-commerce web app

## Get Started

1. Login to google cloud

```bash
gcloud auth application-default login
gcloud auth login
```

2. If the google project DOES exists then run:

```bash
chmod +x ./scripts/target-project.sh
./scripts/target-project.sh <project>
```

2. If the google project DOES NOT exist

```bash
chmod +x ./scripts/create-project.sh
./scripts/create-project.sh <project>
```
