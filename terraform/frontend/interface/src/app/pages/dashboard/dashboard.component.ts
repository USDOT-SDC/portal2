import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { map, Subscription, take } from 'rxjs';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

declare var bootstrap: any;

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.less']
})
export class DashboardComponent implements OnInit, AfterViewInit, OnDestroy {

  public loading: boolean = false;

  public current_user: any;
  public user_is_approver: boolean = false;

  public user_workstations: any = [];
  public user_datasets: any = [];
  public sdc_datasets: any = [];

  private _subscriptions: Array<Subscription> = [];

  constructor(private auth: AuthService, private api: ApiService, private OICD_Auth: OidcSecurityService) { }

  public parseUserName(name: string): string {
    if (name == undefined || name == "") return "Researcher";
    else { return `${name.split("\\").pop()}`; }
  }

  private set_user_as_approver(): void {
    const datasets: Array<any> = this.sdc_datasets;
    var approver_list: Array<string> = [];
    datasets.forEach((dataset: any) => {
      for (let key in dataset.exportWorkflow) {
        const sub_workflow = dataset.exportWorkflow[key];
        for (let w_key in sub_workflow) {
          const workflow = sub_workflow[w_key];
          workflow.ListOfPOC.forEach((person: string) => {
            const exists = approver_list.find(approver => approver == person)
            if (exists == undefined) approver_list.push(person.toLowerCase().trim());
          });
        }
      }
    });

    const user_info = this.auth.user_info.getValue();
    // console.log("user_info: ", user_info);

    this.user_is_approver = approver_list.includes(user_info.email.toLowerCase().trim());
    // console.log("user_is_approver: ", this.user_is_approver);

  }

  ngOnInit(): void {
    this.loading = true;

    this.auth.isLoggedIn().then(() => {
      this._subscriptions.push(

        // New User Get Method
        this.OICD_Auth.getAuthenticationResult().subscribe((user_data) => {
          if (user_data) {
            this.auth.current_user.next(user_data)
            this.current_user = this.auth.current_user.getValue();
            this.auth.isAuthenticated.next(true);
            const GetUserAPI = this.api.get_user().subscribe((response: any) => {
              console.log("GetUserAPI: ", { response });
              if (response) {
                this.auth.user_info.next(response);
                this.user_workstations = response.stacks;
                this.sdc_datasets = response.datasets;
                this.set_user_as_approver();
                this.loading = false;
              }
              GetUserAPI.unsubscribe();
            })
          } else { location.href = "/"; }
        }),

      )
    }).catch(error => console.log(error));
  }

  ngAfterViewInit(): void {
    // Initialize Bootstrap JS Tooltips
    const tooltipTriggerList: any = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
  }

  ngOnDestroy(): void { this._subscriptions.forEach(s => s.unsubscribe()) }
}
