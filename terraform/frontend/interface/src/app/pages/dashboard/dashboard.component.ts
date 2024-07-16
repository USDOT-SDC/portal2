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
  public user_workstations: any = [];

  private _subscriptions: Array<Subscription> = [];

  constructor(private auth: AuthService, private api: ApiService) { }

  public parseUserName(name: string): string {
    if (name == undefined || name == "") return "User TBD";
    else { return `${name.split("\\").pop()}`; }
  }

  ngOnInit(): void {
    this.loading = true;
    this.auth.isLoggedIn().then(() => {
      // Get User from Cognito
      const user_subscription = this.auth.current_user.subscribe((user: any) => {
        console.log("User: ", user);
        this.loading = false;
        this.current_user = user;

        if (location.hostname === "localhost" || location.hostname === "127.0.0.1") {
          this.user_workstations = [/* {
            "current_configuration": "vCPUs:2,RAM(GiB):8",
            "instance_id": "i-0ea40269f4a0e68e0",
            "application": "SDC Support Workstation, SDC 01, Peter/Paul/Mary",
            "configuration": "vCPUs:2,RAM(GiB):8",
            "allow_resize": "true",
            "current_instance_type": "t3a.large",
            "operating_system": "Windows",
            "display_name": "DUMMY-INSTANCE",
            "instance_type": "t3a.large",
            "team_bucket_name": "dev.sdc.dot.gov.team.sdc-support",
            "machine": {
              "cpu": "2",
              "ram": "8",
              "os": "windows"
            }
          } */]
        } else {
          this.api.get_user().subscribe((response: any) => {
            console.log("Response: ", response);
            if (response) this.user_workstations = response.stacks
          });
        }
      });
      this._subscriptions.push(user_subscription)
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
