import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-sdc-datasets',
  templateUrl: './sdc-datasets.component.html',
  styleUrls: ['./sdc-datasets.component.less']
})
export class SdcDatasetsComponent implements OnInit {

  public datasets: Array<any> = [];

  constructor() { }

  ngOnInit(): void {
  }

}
