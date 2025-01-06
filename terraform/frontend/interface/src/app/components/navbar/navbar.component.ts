import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.less']
})
export class NavbarComponent implements OnInit {

  public isLoggedIn: boolean = false;

  constructor(private auth: AuthService) { }

  public logOut() {
    this.auth.logout()
      .then(() => { location.href = '/'; })
      .catch(() => { this.isLoggedIn = false; });
  }

  ngOnInit(): void {
    console.log('Navbar - this.auth.isLoggedIn() start');    
    this.auth.isLoggedIn()
      .then((bool) => { this.isLoggedIn = bool; })
      .catch(() => { this.isLoggedIn = false; });
    console.log('Navbar - this.isLoggedIn value: ', this.isLoggedIn);
  }

}
