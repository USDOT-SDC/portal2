# Repository Structure

├── .githooks
│   └── pre-commit
├── doc
│   ├── administration
│   ├── development
│   ├── user
│   ├── index.md
│   └── repository-structure.md
├── plans
│   ├── deployment.md
│   ├── disaster-recovery.md
│   ├── rollback.md
│   ├── setup.md
│   └── test.md
├── res
│   └── dot.png
├── terraform
│   ├── backend
│   │   ├── api_resource
│   │   │   ├── api.tf
│   │   │   ├── lambda.tf
│   │   │   └── variables.tf
│   │   ├── lambdas
│   │   │   └── {lambda_name}
│   │   │       ├── src
│   │   │       │   └── lambda_function.py
│   │   │       └── lambda_deployment_package.zip
│   │   ├── api.tf
│   │   ├── cloudfront.tf
│   │   ├── iam.tf
│   │   ├── lambda.tf
│   │   ├── modules.tf
│   │   ├── outputs.tf
│   │   ├── route53.tf
│   │   ├── s3.tf
│   │   └── variables.tf
│   ├── frontend
│   │   ├── interface
│   │   │   ├── src
│   │   │   │   ├── app
│   │   │   │   │   ├── classes
│   │   │   │   │   ├── components
│   │   │   │   │   ├── guards
│   │   │   │   │   ├── pages
│   │   │   │   │   ├── services
│   │   │   │   │   ├── app-routing.module.ts
│   │   │   │   │   ├── app.component.html
│   │   │   │   │   ├── app.component.less
│   │   │   │   │   ├── app.component.spec.ts
│   │   │   │   │   ├── app.component.ts
│   │   │   │   │   └── app.module.ts
│   │   │   │   ├── assets
│   │   │   │   │   ├── images
│   │   │   │   │   │   ├── faqs
│   │   │   │   │   │   │   ├── dashboard
│   │   │   │   │   │   │   └── home
│   │   │   │   │   │   ├── providers
│   │   │   │   │   │   ├── sdc-home-banner.jpg
│   │   │   │   │   │   └── sdc-home-banner.webp
│   │   │   │   │   └── .gitkeep
│   │   │   │   ├── environments
│   │   │   │   │   ├── environment.dev.ts
│   │   │   │   │   ├── environment.prod.ts
│   │   │   │   │   └── environment.ts
│   │   │   │   ├── favicon.ico
│   │   │   │   ├── index.html
│   │   │   │   ├── main.ts
│   │   │   │   ├── polyfills.ts
│   │   │   │   ├── styles.less
│   │   │   │   └── test.ts
│   │   │   ├── .browserslistrc
│   │   │   ├── .editorconfig
│   │   │   ├── .gitignore
│   │   │   ├── angular.json
│   │   │   ├── karma.conf.js
│   │   │   ├── package-lock.json
│   │   │   ├── package.json
│   │   │   ├── README.md
│   │   │   ├── tsconfig.app.json
│   │   │   ├── tsconfig.json
│   │   │   └── tsconfig.spec.json
│   │   ├── interface_build
│   │   ├── environment.ts.tpl
│   │   ├── interface_build.md
│   │   ├── interface_build.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── .terraform.lock.hcl
│   ├── configuration.tf
│   ├── data.tf
│   ├── import.tf
│   ├── modules.tf
│   ├── outputs.tf
│   └── variables.tf
├── tests
│   └── bruno
│       ├── .gitignore
│       ├── bruno.json
│       ├── Get Health.bru
│       ├── Get User Info.bru
│       ├── Health.bru
│       ├── Hello World.bru
│       └── William Test.bru
├── .gitignore
├── CONTRIBUTING.md
├── GitExtensions.settings
├── issue_template.md
├── LICENSE.md
├── pull_request_template.md
├── README.md
└── RELEASE-NOTES.md