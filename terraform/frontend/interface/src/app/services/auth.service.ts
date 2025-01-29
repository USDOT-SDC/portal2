import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { BehaviorSubject, map, take } from 'rxjs';


@Injectable({ providedIn: 'root' })
export class AuthService {

  public isAuthenticated: BehaviorSubject<boolean> = new BehaviorSubject(false);

  // Current User houses Cognito Auth data (accessToken, idToken, and UserData)
  public current_user: BehaviorSubject<any> = new BehaviorSubject(undefined);

  // User Info is Data Coming from DynamoDB Table
  public user_info: BehaviorSubject<any> = new BehaviorSubject(undefined);

  public user_uploaded_data: BehaviorSubject<any> = new BehaviorSubject(undefined);

  constructor(private OICD_Auth: OidcSecurityService, private router: Router) { }

  public async login(): Promise<void> {
    try {
      const logged_in = await this.isLoggedIn();
      if (logged_in == true) this.router.navigate(["dashboard"])
      else this.OICD_Auth.authorize();
    } catch (error) { console.log('error logging in: ', error); }
  }

  public async isLoggedIn(): Promise<boolean> {
    try {
      const isAuthenticated: boolean = this.isAuthenticated.getValue();
      this.isAuthenticated.next(isAuthenticated)
      return isAuthenticated; // true or false
    } catch (err) {
      return false;
    }
  }

  public async logout(): Promise<void> {
    if (window.sessionStorage) window.sessionStorage.clear();
    this.isAuthenticated.next(false);
    this.current_user.next(undefined);
    this.user_info.next(undefined);
    this.user_uploaded_data.next(undefined);
    window.location.href = "https://usdot-sdc-dev.auth.us-east-1.amazoncognito.com/logout?client_id=4binc5ifp081iu97i0dhb10q68&logout_uri=http://localhost:4200/index.html";
  }

}
