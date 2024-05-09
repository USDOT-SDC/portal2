import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-workstations',
  templateUrl: './workstations.component.html',
  styleUrls: ['./workstations.component.less']
})
export class WorkstationsComponent implements OnInit {

  public workstations: Array<any> = [{},{}];

  constructor() { }

  ngOnInit(): void {
  }

}
