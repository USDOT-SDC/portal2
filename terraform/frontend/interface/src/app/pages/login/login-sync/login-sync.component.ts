import { Component, OnInit } from '@angular/core';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-login-sync',
  templateUrl: './login-sync.component.html',
  styleUrls: ['./login-sync.component.less']
})
export class LoginSyncComponent implements OnInit {

  public show_password: boolean = false;
  public is_loading: boolean = false;
  public is_invalid: boolean = false;

  public username: string | undefined;
  public password: string | undefined;

  constructor(private api: ApiService, private auth: AuthService) { }

  public submit_login_sync(): void {
    console.log('login-sync - Start submit_login_sync()');
    this.is_loading = true;

    setTimeout(() => {
      console.log('login-sync - start setTimeout');
      this.reset();
      this.auth.logoutAfterSyncandRedirectToLogin();
    }, 2000)
    

    const payload: { username: any; password: any } = { username: this.username, password: this.password, };
       const API = this.api.link_an_account(payload.username, payload.password).subscribe({
      next: (response: any) => {
        console.log('login-sync - observer next');
        console.log({ response });
        // Response is Good? Redirect to Dashboard or Login . . .
        API.unsubscribe();
        this.reset();
      },
      error: (error: any) => {
        if (error) if (error.userErrorMessage) {
          this.is_invalid = true;
          this.is_loading = false;
          console.log("Error:", error.userErrorMessage)
          }
      },
      complete: () => {
        console.log("login-sync - observer complete");
       }
    })
  }

  public reset() {
    this.username = undefined;
    this.password = undefined;
    this.is_loading = false;
  }


  ngOnInit(): void {
  }

}
