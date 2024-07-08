import { Component, Input, OnInit } from '@angular/core';

@Component({
  selector: 'app-workstations',
  templateUrl: './workstations.component.html',
  styleUrls: ['./workstations.component.less']
})
export class WorkstationsComponent implements OnInit {

  @Input() workstations = [];

  constructor() { }

  ngOnInit(): void {
  }

}
