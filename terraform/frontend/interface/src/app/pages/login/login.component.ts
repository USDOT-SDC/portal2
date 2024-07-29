import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.less']
})
export class LoginComponent implements OnInit {


  private BASE_URL: string = 'https://ecs-dev-sdc-dot-webportal.auth.us-east-1.amazoncognito.com/oauth2/authorize'
  private URI_PARAMS: string = `?redirect_uri=${location.origin}/dashboard&response_type=token`;

  public signing_in: boolean = false;

  constructor(private auth: AuthService) { }

  public login(dot: boolean) {

    this.signing_in = true;

    if (dot == true) {
      console.log("Logging in: COGNITO");
      this.auth.login();
      this.signing_in = false;
    } else {
      console.log("Logging in: LOGIN.GOV");
      location.href = `${this.BASE_URL}${this.URI_PARAMS}&client_id=122lj1qh9e5qam3u29fpdt9ati`;
      this.signing_in = false;
    }

  }

  ngOnInit(): void {
    this.auth.isLoggedIn();
  }

}
