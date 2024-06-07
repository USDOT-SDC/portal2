import { Component, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';

@Component({
  selector: 'app-workstations',
  templateUrl: './workstations.component.html',
  styleUrls: ['./workstations.component.less']
})
export class WorkstationsComponent implements OnInit {

  @ViewChild('Modal_ShutDownWorkstation') Williams_modal: ModalComponent | any;
  @ViewChild('Modal_ShutDownWorkstation') Modal_ShutDownWorkstation: ModalComponent | any;
  @ViewChild('Modal_ResizeWorkstation') Modal_ResizeWorkstation: ModalComponent | any;
  @ViewChild('Modal_ScheduleWorkstation') Modal_ScheduleWorkstation: ModalComponent | any;
  @ViewChild('Modal_AddToWorkstationStorage') Modal_AddToWorkstationStorage: ModalComponent | any;

  public workstations: Array<any> = [];
  public selected_workstation: any;

  constructor() { }

  public WorkstationTrackBy(index: number, workstation: any): number {
    return workstation.instance_id;
  }

  public toggle_workstation(id: string): void {
    let workstation_data = this.workstations.find((workstation: any) => { if (workstation.instance_id == id) return workstation })
    console.log({ workstation_data });

    workstation_data.loading = true;

    if (workstation_data.status == true) {
      this.selected_workstation = workstation_data;
      this.open_shutdown_workstation_modal();
    }
    else setTimeout(() => {
      workstation_data.status = true;
      workstation_data.loading = false;
    }, 1500)

  }

  public open_shutdown_workstation_modal(): void { this.Modal_ShutDownWorkstation.open(); }

  public shutdown_workstation(): void {
    this.Modal_ShutDownWorkstation.close();
    setTimeout(() => {
      this.selected_workstation.status = false;
      this.close_shutdown_workstation_modal();
    }, 1500)
  }

  public close_shutdown_workstation_modal(): void {
    this.selected_workstation.loading = false;
    this.selected_workstation = undefined;
    this.Modal_ShutDownWorkstation.close();
  }


  public open_modal_resize_workstation_modal(): void { this.Modal_ResizeWorkstation.open(); }
  public close_modal_resize_workstation_modal(): void { this.Modal_ResizeWorkstation.close(); }

  public open_modal_schedule_workstation_modal(): void { this.Modal_ScheduleWorkstation.open(); }
  public close_modal_schedule_workstation_modal(): void { this.Modal_ScheduleWorkstation.close(); }

  public open_modal_add_to_workstation_storage_modal(): void { this.Modal_AddToWorkstationStorage.open(); }
  public close_modal_add_to_workstation_storage_modal(): void { this.Modal_AddToWorkstationStorage.close(); }

  ngOnInit(): void {
    const incoming_workstations = [
      {
        status: true,
        loading: false,
        current_configuration: "vCPUs:2,RAM(GiB):8",
        instance_id: "i-0cb69169b64fb1843",
        application: "SDC Support Workstation, Enablement Team, Brandon and Gautam",
        configuration: "vCPUs:2,RAM(GiB):4",
        allow_resize: "true",
        current_instance_type: "m5ad.large",
        operating_system: "Windows",
        display_name: "ECSPWSDC01",
        instance_type: "t3a.medium",
        team_bucket_name: "prod.sdc.dot.gov.team.sdc-support",
      },
      {
        status: false,
        loading: false,
        current_configuration: "vCPUs:2,RAM(GiB):8",
        instance_id: "i-029550cf92e933e48",
        application: "SDC Support Workstation, Enablement Team, Pallavi and Christine",
        configuration: "vCPUs:2,RAM(GiB):4",
        allow_resize: "true",
        current_instance_type: "t3a.large",
        operating_system: "Windows",
        display_name: "ECSPWSDC02",
        instance_type: "t3a.medium",
        team_bucket_name: "prod.sdc.dot.gov.team.sdc-support",
      },
      {
        status: false,
        loading: false,
        current_configuration: "vCPUs:2,RAM(GiB):4",
        instance_id: "i-0f9a56646513b8a9d",
        application: "SDC Research Workstation, Acme",
        configuration: "vCPUs:2,RAM(GiB):4",
        allow_resize: "true",
        current_instance_type: "t3a.medium",
        operating_system: "Windows",
        display_name: "ECSPWART02 (Acme Researcher)",
        instance_type: "t3a.medium",
        team_bucket_name: "prod.sdc.dot.gov.team.acme-research-team",
      },
      {
        status: false,
        loading: false,
        current_configuration: "vCPUs:4,RAM(GiB):16",
        instance_id: "i-0856042747c808661",
        application: "SDC Pipeline Server, HSIS",
        configuration: "vCPUs:4,RAM(GiB):16",
        allow_resize: "true",
        current_instance_type: "t3a.xlarge",
        operating_system: "Linux",
        display_name: "ECSPWHSISPL",
        instance_type: "t3a.xlarge",
        team_bucket_name: "prod.sdc.dot.gov.team.sdc-support",
      },
    ];


    this.workstations = incoming_workstations.map((workstation: any) => {
      const config_params = workstation.current_configuration.replace('vCPUs:', '').replace('RAM(GiB):', '').split(',');
      workstation['machine'] = {
        cpu: config_params[0],
        ram: config_params[1],
        os: workstation.operating_system.toLowerCase()
      };

      return workstation;
    });

    console.log(this.workstations)
  }

}
