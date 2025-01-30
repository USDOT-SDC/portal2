import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-login-redirect',
  templateUrl: './login-redirect.component.html',
  styleUrls: ['./login-redirect.component.less']
})
export class LoginRedirectComponent implements OnInit {

  constructor(private router: Router, private OICD_Auth: OidcSecurityService, private auth: AuthService) { }

  ngOnInit(): void {
    this.OICD_Auth.checkAuth(location.href).subscribe((data: any) => {
      // console.log({ checkAuth: data })
      if (data.isAuthenticated) {
        this.auth.current_user.next(data);
        this.auth.isAuthenticated.next(data.isAuthenticated);
        this.router.navigate(['dashboard'])
      }
      // else /* NOT LOGGED IN, REDIRECT BACK TO LOGIN */
    });

  }

}
