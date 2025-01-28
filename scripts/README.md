# Portal 2 Deployment Scripts

## Environment Setup
1. Follow instructions in the repo's [Environment Setup](/plans/setup.md)
1. Install Node.js
1. Run: `npm install -g @angular/cli`

## 1 tfinit
The `1-tfinit.cmd` script sets the active AWS profile (`set AWS_PROFILE=%env%`) and initializes Terraform (`terraform init`).  
### Parameters
The first parameter is the environment (dev | prod) to deploy to  
The second optional parameter sets an alternate AWS profile (e.g., default)  
### Examples
```
1-tfinit dev  
1-tfinit prod  
1-tfinit dev default
```
### Output
```
Your active AWS profile is: dev

terraform init -backend-config "bucket=dev.sdc.dot.gov.platform.terraform" -upgrade -reconfigure

Would you like to execute the above command to initialize Terraform?
Press Y for Yes, or C to Cancel.
```

## 2 frontend-init
The `2-frontend-init.cmd` script runs preps and builds the Angular frontend interface.
### Parameters
The first parameter is the environment (dev | prod) to deploy to  
### Examples
```
2-frontend-init dev  
2-frontend-init prod  
2-frontend-init dev default
```
### Output
```
up to date, audited 1290 packages in 19s

139 packages are looking for funding
  run `npm fund` for details

# npm audit report

...
...

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
✔ Browser application bundle generation complete.
✔ Copying assets complete.
✔ Index html generation complete.

Initial Chunk Files | Names         |  Raw Size
vendor.js           | vendor        |   2.82 MB |
main.js             | main          | 550.48 kB |
styles.css          | styles        | 225.60 kB |
polyfills.js        | polyfills     | 109.31 kB |
scripts.js          | scripts       |  78.87 kB |
runtime.js          | runtime       |   6.35 kB |

                    | Initial Total |   3.76 MB

Build at: 2025-01-28T03:02:19.116Z - Hash: f6bb21559f5e71bf - Time: 25962ms
```

## 3 tfplan
Terraform must be initialized (`1-tfinit {env}`) before running `3-tfplan`
### Example
```
3-tfplan  
```
### Output
```
Your active AWS profile is: dev

terraform plan -var=config_version="0.0.1" -var-file="env_vars/dev.tfvars" -out="tfplans/0.0.1_dev_147"

Would you like to execute the above command to create a Terraform execution plan?
Press Y for Yes, or C to Cancel.
```

## 4 tfapply
You must run `3-tfplan` to create a Terraform execution plan before running `4-tfapply`
### Example
```
4-tfapply  
```
### Output
```
Your active AWS profile is: dev

terraform apply "tfplans/0.0.1_dev_147"

Would you like to execute the above command to apply a Terraform execution plan?
Press Y for Yes, or C to Cancel.
```
