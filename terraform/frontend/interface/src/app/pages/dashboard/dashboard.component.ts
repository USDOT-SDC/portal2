import { AfterViewInit, Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { map, Subscription, take } from 'rxjs';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';
import { Router, NavigationStart } from '@angular/router';

declare var bootstrap: any;

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.less']
})
export class DashboardComponent implements OnInit, AfterViewInit, OnDestroy {

  @ViewChild('AuthWarningModal') AuthWarningModal: ModalComponent | any;
  @ViewChild('AuthExpirationModal') AuthExpirationModal: ModalComponent | any;

  public loading: boolean = false;
  public is_dark_mode: boolean = false;

  public current_user: any;

  public user_is_approver: boolean = false;
  public user_name: any;

  public user_workstations: any = [];
  public user_datasets: any = [];
  public sdc_datasets: any = [];

  private _subscriptions: Array<Subscription> = [];

  constructor(private auth: AuthService, private api: ApiService, private OICD_Auth: OidcSecurityService, private router: Router) { }

  public parseUserName(name: string): string {
    if (name == undefined || name == "") return "Researcher";
    else { return `${name.split("\\").pop()}`; }
  }

  public toggle_theme_mode(): void {
    const body = document.body;
    body.dataset['bsTheme'] = body.dataset['bsTheme'] == 'dark' ? 'light' : 'dark';
    localStorage.setItem('sdc_ui_theme', body.dataset['bsTheme']);
    this.is_dark_mode = body.dataset['bsTheme'] == 'dark';
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
    console.log("user_info: ", user_info);

    this.user_is_approver = approver_list.includes(user_info.email.toLowerCase().trim());
    console.log("user_is_approver: ", this.user_is_approver);

  }

  private warning_modal_open(): void {
    this.AuthWarningModal.open();
  }

  private expiration_modal_open(): void {
    this.AuthExpirationModal.open();
  }

  private inactivityTimer() {
    let sessionTimer: any;
    let warningTimer: any;
    let sessionStart: number;
    const sessionTimeout = 30000; // 30 minutes in milliseconds
    const warningTime = 20000; // 28 minutes in milliseconds

    const isSessionExpired = () => {
      return Date.now() - sessionStart > sessionTimeout;
    };

    const startSessionTimer = () => {
      sessionTimer = setTimeout(() => {
        this.auth.logout();
        this.expiration_modal_open();
      }, sessionTimeout);
    };

    const showWarningAlert = () => {
      warningTimer = setTimeout(() => {
        this.warning_modal_open();

        // if (isSessionExpired()) {
        //   this.refreshPage();
        // }
      }, warningTime);
    };

    const resetTimers = () => {
      clearTimeout(sessionTimer);
      clearTimeout(warningTimer);
    };

    sessionStart = Date.now();
    startSessionTimer();
    showWarningAlert();

    this.router.events.subscribe((event) => {
      if (event instanceof NavigationStart) {
        clearTimeout(sessionTimer);
        clearTimeout(warningTimer);
        resetTimers();
      }
    });
  }

  refreshPage() {
    window.location.reload(); // Refresh the page
  }

  ngOnInit(): void {
    this.loading = true;
    this.inactivityTimer();

    const body = document.body;
    const theme = localStorage.getItem('sdc_ui_theme');
    if (theme) {
      body.dataset['bsTheme'] = theme;
      this.is_dark_mode = body.dataset['bsTheme'] == 'dark';
    }

    this.auth.isLoggedIn().then(() => {
      this._subscriptions.push(

        // New User Get Method
        this.OICD_Auth.getAuthenticationResult().subscribe((user_data) => {
          console.log('dashboard- user_data: ', user_data);
          if (user_data) {
            this.auth.current_user.next(user_data);
            this.current_user = this.auth.current_user.getValue();
            this.auth.isAuthenticated.next(true);
            const GetUserAPI = this.api.get_user().subscribe((response: any) => {
              console.log("dashboard- api.GetUser response: ", { response });
              if (response) {
                this.auth.user_info.next(response);
                this.user_name = response.name;
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
