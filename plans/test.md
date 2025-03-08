# Test Plan
This Test Plan is designed to prescribe the scope, objectives, test
activities and deliverables of the testing activities for Portal resources.

### Test Plan
1. Create a copy of [SDC-0000: Portal Testing, Results, Version 1.0.0](https://securedatacommons.atlassian.net/wiki/spaces/DO/pages/3465150473/)
1. Follow the instructions in the page's info box.
1. Post a link to the Confluence page in a comment on the PR.
   - Example: `[SDC-1234: Portal Testing, Results, Version 1.2.3](https://securedatacommons.atlassian.net/wiki/spaces/DO/pages/0123456789/)`


#### In Scope
- Login with MFA
- Dashboard
    - My Resources
        - My Workstations
            - Start/Stop
            - Connect
            - Resize Workstation
        - My Data
            - Export Request
            - Download
    - SDC Resources
        - SDC Datasets
            - Request Access
    - Request Center
        - Request Trusted User Status
        - Request Edge Database
    - Approval Center
        - Export File Requests
            - More Details
            - Approve/Deny
        - Export Table Requests
            - More Details
            - Approve/Deny
        - Trusted User Requests
            - More Details
            - Approve/Deny
- FAQ
  - Frequently Asked Questions
  - Helpful Links
- Logout

#### Out of Scope
- RDS, Guacamole database

### Objectives
The test objectives are to verify the functionality of the
Portal resources, and should focus on testing the in scope items
to guarantee they work normally in a production environment.
