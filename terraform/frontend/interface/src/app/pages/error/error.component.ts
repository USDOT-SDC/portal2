import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-error',
  templateUrl: './error.component.html',
  styleUrls: ['./error.component.less']
})
export class ErrorComponent implements OnInit {

  public domain: string = location.host;
  public path: string | undefined;

  constructor() { }

  ngOnInit(): void {
    this.path = location.pathname;
  }

}
