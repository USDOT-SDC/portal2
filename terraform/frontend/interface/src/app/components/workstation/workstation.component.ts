import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { ApiService } from 'src/app/services/api.service';

@Component({
  selector: 'app-workstation',
  templateUrl: './workstation.component.html',
  styleUrls: ['./workstation.component.less']
})
export class WorkstationComponent implements OnInit {

  @Input() workstation: any;

  @Output() action: EventEmitter<any> = new EventEmitter();

  constructor(private api: ApiService) { }

  private get_workstation_status() {
    this.workstation.status = false;
    const api = this.api.workstation_status(this.workstation.instance_id).subscribe((response: any) => {
      const instance_status = response.Status.InstanceStatuses;
      if (instance_status.length > 0) {
        if (instance_status[0].InstanceState.Name == 'running') this.workstation.status = true;
      }
      api.unsubscribe();
      this.workstation.loading = false;
    })
  }

  public emit_action(action: string, data?: any): void { this.action.emit({ action, data }); }

  ngOnInit(): void {
    if (this.workstation) {
      // console.log(this.workstation);
      this.workstation.loading = true;
      this.get_workstation_status();
      const config_params = this.workstation.current_configuration.replace('vCPUs:', '').replace('RAM(GiB):', '').split(',');
      this.workstation['machine'] = { cpu: config_params[0], ram: config_params[1], os: this.workstation.operating_system.toLowerCase() };
    }
  }

}
