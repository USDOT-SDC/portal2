import { Component, Input, OnInit } from '@angular/core';
import { ApiService } from 'src/app/services/api.service';

@Component({
  selector: 'app-workstation',
  templateUrl: './workstation.component.html',
  styleUrls: ['./workstation.component.less']
})
export class WorkstationComponent implements OnInit {

  @Input() workstation: any;

  constructor(private api: ApiService) { }

  private get_workstation_status() {
    const api = this.api.workstation_status(this.workstation.instance_id).subscribe((response: any) => {
      console.log("Workstation Status: ", response);
      api.unsubscribe();
    })
  }

  ngOnInit(): void {
    if (this.workstation) {
      console.log(this.workstation);
      this.get_workstation_status();
      const config_params = this.workstation.current_configuration.replace('vCPUs:', '').replace('RAM(GiB):', '').split(',');
      this.workstation['machine'] = {
        cpu: config_params[0],
        ram: config_params[1],
        os: this.workstation.operating_system.toLowerCase()
      };
    }
  }

}
