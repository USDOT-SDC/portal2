import { Component, Input, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';

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

  @Input() workstations: Array<any> = [];

  public selected_workstation: any;

  constructor(private api: ApiService) { }

  public WorkstationTrackBy(index: number, workstation: any): number { return workstation.instance_id; }

  public toggle_workstation(id: string): void {
    let workstation_data = this.workstations.find((workstation: any) => { if (workstation.instance_id == id) return workstation })
    workstation_data.loading = true;
    // console.log({ workstation_data });

    if (workstation_data.status == true) {
      this.selected_workstation = workstation_data;
      this.open_shutdown_workstation_modal();
    } else {
      const _API = this.api.workstation_action(id, 'run').subscribe((response: any) => {
        console.log('Workstation: run', response)
        _API.unsubscribe();
        workstation_data.status = true;
        workstation_data.loading = false;
      })
    }

  }

  public launch_workstation(id: string): void { }

  public open_shutdown_workstation_modal(): void { this.Modal_ShutDownWorkstation.open(); }

  public shutdown_workstation(): void {
    const id = this.selected_workstation.instance_id;
    const _API = this.api.workstation_action(id, 'stop').subscribe((response: any) => {
      console.log('Workstation: stop', response)
      _API.unsubscribe();
      this.selected_workstation.status = false;
      this.close_shutdown_workstation_modal();
    })
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

  ngOnInit(): void { }

}
