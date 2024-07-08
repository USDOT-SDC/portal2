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
  public user_workstations = [];

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
        // Get User From DB
        this.api.get_user().subscribe((response: any) => {
          console.log("Response: ", response);
          if (response) {
            this.user_workstations = response.stacks.map((workstation: any) => {
              const config_params = workstation.current_configuration.replace('vCPUs:', '').replace('RAM(GiB):', '').split(',');
              workstation['machine'] = { cpu: config_params[0], ram: config_params[1], os: workstation.operating_system.toLowerCase() };
              return workstation;
            });;
          }
        })
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
