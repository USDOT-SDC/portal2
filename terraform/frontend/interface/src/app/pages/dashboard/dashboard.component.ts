import { AfterViewInit, Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs';
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

  private _subscriptions: Array<Subscription> = [];

  constructor(private auth: AuthService) { }

  public parseUserName(name: string): string {
    if (name == undefined || name == "") return "User TBD";
    else { return `${name.split("\\").pop()}`; }
  }

  ngOnInit(): void {
    this.loading = true;
    this.auth.isLoggedIn().then(() => {
      const user_subscription = this.auth.current_user.subscribe((user: any) => {
        console.log("User: ", user)
        setTimeout(() => {
          this.loading = false;
          this.current_user = user;
        }, 500)
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
