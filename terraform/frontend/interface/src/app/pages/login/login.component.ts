import { Component, OnInit } from '@angular/core';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { Subscription } from 'rxjs';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.less']
})
export class LoginComponent implements OnInit {

  private _subscriptions: Array<Subscription> = []

  public signing_in: boolean = false;
  public user_data: any;
  public is_logged_in: boolean = false;

  constructor(private auth: AuthService, private OICD_Auth: OidcSecurityService) { }

  public login(): void { this.auth.login(); }

  ngOnInit(): void {

    this.auth.isLoggedIn().then((response: any) => { this.is_logged_in = response; });

    this._subscriptions.push(

      this.OICD_Auth.userData$.subscribe((user) => {
        this.user_data = user;
      }),

      this.OICD_Auth.isAuthenticated$.subscribe(({ isAuthenticated }) => {
        console.warn('authenticated: ', isAuthenticated);
        this.is_logged_in = isAuthenticated;
      }),

    )
  }

}
