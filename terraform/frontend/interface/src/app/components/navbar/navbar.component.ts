import { Component, OnDestroy, OnInit } from '@angular/core';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { Subscription } from 'rxjs';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.less']
})
export class NavbarComponent implements OnInit, OnDestroy {

  private _subscriptions: Array<Subscription> = [];

  public isLoggedIn: boolean = false;

  constructor(private auth: AuthService, private OICD_Auth: OidcSecurityService) { }

  public logOut() {
    this.auth.logout()
      .then(() => { location.href = '/'; })
      .catch(() => { this.isLoggedIn = false; });
  }

  ngOnInit(): void {
    // console.log('Navbar - this.OICD_Auth.isAuthenticated() start');
    this._subscriptions.push(
      this.OICD_Auth.isAuthenticated().subscribe((is_authed: boolean) => { this.auth.isAuthenticated.next(is_authed) }),
      this.auth.isAuthenticated.subscribe((response: boolean) => { this.isLoggedIn = response; })
    )
    // console.log('Navbar - this.OICD_Auth.isAuthenticated() value: ', this.isLoggedIn);
  }

  ngOnDestroy(): void { this._subscriptions.forEach((s) => s.unsubscribe()) }
}
