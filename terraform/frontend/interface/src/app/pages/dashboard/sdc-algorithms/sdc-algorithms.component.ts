import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-sdc-algorithms',
  templateUrl: './sdc-algorithms.component.html',
  styleUrls: ['./sdc-algorithms.component.less']
})
export class SdcAlgorithmsComponent implements OnInit {

  public algorithms: Array<any> = [];

  constructor() { }

  ngOnInit(): void {
  }

}
