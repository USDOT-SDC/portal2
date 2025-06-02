import { Component, OnInit, ViewChild } from '@angular/core';
import { Router } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { AuthService } from 'src/app/services/auth.service';
import { ModalComponent } from 'src/app/components/modal/modal.component';

@Component({
  selector: 'app-login-redirect',
  templateUrl: './login-redirect.component.html',
  styleUrls: ['./login-redirect.component.less']
})
export class LoginRedirectComponent implements OnInit {

  @ViewChild('AuthRenewModal') AuthRenewModal: ModalComponent | any;

  constructor(private router: Router, private OICD_Auth: OidcSecurityService, private auth: AuthService) { }

  ngOnInit(): void {
    this.OICD_Auth.checkAuth(location.href).subscribe((data: any) => {
      console.log('login-redirect-checkAuth-data', { checkAuth: data })
      if (data.isAuthenticated) {
        this.auth.current_user.next(data);
        this.auth.isAuthenticated.next(data.isAuthenticated);
        this.router.navigate(['dashboard'])
      }
      else this.auth_modal_open();
    });

  }

  public auth_modal_open(): void {
    this.AuthRenewModal.open();
  }

  public auth_modal_close(): void {
    this.AuthRenewModal.close();
  }
}
