import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.less']
})
export class DashboardComponent implements OnInit {

  public route: string | undefined;

  constructor() { }

  ngOnInit(): void {
    const path = location.pathname.split('/').pop();
    this.route = path;
  }

}
