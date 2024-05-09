import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.less']
})
export class LoginComponent implements OnInit {

  public email_address: string | undefined;
  public signing_in: boolean = false;

  constructor() { }

  public login() {
    // Demo Logic - Log and route to Dashboard
    this.signing_in = true;
    console.log("Logging in with Email: ", this.email_address);
    setTimeout(() => {
      location.href = '/dashboard';
      this.signing_in = false;
    }, 1500); 
  }

  ngOnInit(): void {
  }

}
