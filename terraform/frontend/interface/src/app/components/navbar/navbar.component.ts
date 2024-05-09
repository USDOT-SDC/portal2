import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-navbar',
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.less']
})
export class NavbarComponent implements OnInit {

  public isLoggedIn: boolean = false;

  constructor() { }

  ngOnInit(): void {
    const path: Array<string> = location.pathname.split('/').filter((item: string) => item !== "");

    // Temporary Login Solution - Remove Once Login is in Place
    if (path.length > 0) {
      if (path[0] == "dashboard") this.isLoggedIn = true;
    }

    console.log(path, this.isLoggedIn);
  }

}
