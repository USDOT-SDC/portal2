import { Component, OnInit } from '@angular/core';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-login-redirect',
  templateUrl: './login-redirect.component.html',
  styleUrls: ['./login-redirect.component.less']
})
export class LoginRedirectComponent implements OnInit {

  constructor(private auth: AuthService, private api: ApiService) { }

  ngOnInit(): void {
    // if (location.hostname === "localhost" || location.hostname === "127.0.0.1") location.href = 'dashboard';
    // else {
      // Check Login Sync

      this.auth.current_user.subscribe((user: any) => {
        console.log(user);
        if (user) {
          if (user.token) {
            this.api.verify_account_linked(user.token).subscribe((response: any | { accountLinked: boolean }) => {
              console.log(response);
              // If Pass, Redirect to Dashboard
              if (response.accountLinked == true) location.href = 'dashboard';
              // If Failed, Redirect to Login Sync Page
              else location.href = 'login/sync';
            })
          }
        }
      })


    // }

  }

}
