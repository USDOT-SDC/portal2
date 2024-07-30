import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs';
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

  constructor(private auth: AuthService, private api: ApiService) { }

  public parseUserName(name: string): string {
    if (name == undefined || name == "") return "User TBD";
    else { return `${name.split("\\").pop()}`; }
  }

  private set_user_as_approver() {
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
      // Get User from Cognito

      this._subscriptions.push(
        this.auth.current_user.subscribe((user: any) => {

          // console.log("User: ", user);
          this.current_user = user;

          if (location.hostname === "localhost" || location.hostname === "127.0.0.1") { this.loading = false; }
          else {
            const API = this.api.get_user().subscribe((response: any) => {
              if (response) {
                console.log(response)
                this.auth.user_info.next(response);
                this.user_workstations = response.stacks;
                this.sdc_datasets = response.datasets;
                this.set_user_as_approver();
              }
              this.loading = false;
              API.unsubscribe();
            });
          }
        })
      )
    });
  }

  ngAfterViewInit(): void {
    // Initialize Bootstrap JS Tooltips
    const tooltipTriggerList: any = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
  }

  ngOnDestroy(): void {
    this._subscriptions.forEach(s => s.unsubscribe())
  }
}
