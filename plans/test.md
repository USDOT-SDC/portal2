# Test Plan
This Test Plan is designed to prescribe the scope, objectives, test
activities and deliverables of the testing activities for Portal resources.

### Confluence Pages
- [WI: Portal Testing - Unit Testing](https://securedatacommons.atlassian.net/wiki/spaces/DO/pages/2578972711/)
- [WI: Portal Testing - User Acceptance](https://securedatacommons.atlassian.net/wiki/spaces/DO/pages/2578579510/)
- [WI: Portal Testing - System Integration](https://securedatacommons.atlassian.net/wiki/spaces/DO/pages/2578710603/)

### In Scope Test Plan
Document the results of testing in the comments of the PR.  

#### Test Results  
Provide artifacts of the test results, as needed.
- [ ] Login with MFA
- [ ] Dashboard
    - [ ] My Resources
    - [ ] My Workstations
        - [ ] Start/Stop
        - [ ] Connect
        - [ ] Resize Workstation
    - [ ] My Data
        - [ ] Export Request
        - [ ] Download
    - [ ] SDC Resources
    - [ ] SDC Datasets
        - [ ] Request Access
    - [ ] Request Center
    - [ ] Request Trusted User Status
    - [ ] Request Edge Database
    - [ ] Approval Center
    - [ ] Export File Requests
        - [ ] More Details
        - [ ] Approve/Deny
    - [ ] Export Table Requests
        - [ ] More Details
        - [ ] Approve/Deny
    - [ ] Trusted User Requests
        - [ ] More Details
        - [ ] Approve/Deny
- [ ] FAQ
  - [ ] Frequently Asked Questions
  - [ ] Helpful Links
- [ ] Logout

### Out of Scope AWS Resources
- RDS, Guacamole database

### Objectives
The test objectives are to verify the functionality of the
Portal resources, and should focus on testing the in scope items
to guarantee they work normally in a production environment.
