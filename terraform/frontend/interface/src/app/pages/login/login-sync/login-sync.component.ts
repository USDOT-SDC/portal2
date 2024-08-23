import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-login-sync',
  templateUrl: './login-sync.component.html',
  styleUrls: ['./login-sync.component.less']
})
export class LoginSyncComponent implements OnInit {

  public show_password: boolean = false;
  public is_loading: boolean = false;

  public username: string | undefined;
  public password: string | undefined;

  constructor() { }

  public submit_login_sync(): void {
    this.is_loading = true;

    const payload = { username: this.username, password: this.password, };
    console.log({ payload });

    /// API CALL.....
    setTimeout(() => {
      console.log({ response: "Dummy API call: Success" });
      this.reset();
    }, 1000)

  }

  public reset() {
    this.username = undefined;
    this.password = undefined;
    this.is_loading = false;
  }


  ngOnInit(): void {
  }

}
