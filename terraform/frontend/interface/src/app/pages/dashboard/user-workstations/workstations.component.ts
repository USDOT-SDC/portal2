import { AfterViewInit, Component, Input, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';
import { environment } from 'src/environments/environment';

declare var bootstrap: any;

@Component({
  selector: 'app-workstations',
  templateUrl: './workstations.component.html',
  styleUrls: ['./workstations.component.less']
})
export class WorkstationsComponent implements OnInit, AfterViewInit, OnDestroy {

  @ViewChild('Modal_ShutDownWorkstation') Williams_modal: ModalComponent | any;
  @ViewChild('Modal_ShutDownWorkstation') Modal_ShutDownWorkstation: ModalComponent | any;
  @ViewChild('Modal_ResizeWorkstation') Modal_ResizeWorkstation: ModalComponent | any;
  @ViewChild('Modal_ScheduleWorkstation') Modal_ScheduleWorkstation: ModalComponent | any;
  @ViewChild('Modal_AddToWorkstationStorage') Modal_AddToWorkstationStorage: ModalComponent | any;

  @Input() workstations: Array<any> = [];

  @Input() loading: boolean = false;

  public get CPU_options(): Array<number> { return [2, 4, 8, 16, 24, 36, 40, 48, 60, 64, 72, 96, 128]; };
  public get RAM_options(): Array<number> { return [2, 3.75, 4, 5.25, 7.5, 8, 10.5, 15, 15.25, 16, 21, 30, 30.5, 32, 42, 61, 64, 72, 96, 128, 144, 160, 192, 256, 384, 768,]; };

  public selected_workstation: any;

  constructor(private api: ApiService, private auth: AuthService) { }

  public WorkstationTrackBy(index: number, workstation: any): number { return workstation.instance_id; }

  public handle_workstation_action(event: { action: string, data?: any }): void {

    console.log(event);

    const { action, data } = event;

    switch (action) {
      case 'toggle': this.toggle_workstation(data.instance_id); break;
      case 'launch': this.launch_workstation(data.instance_id); break;
      case 'resize': this.open_modal_resize_workstation_modal(data.instance_id); break;
      case 'schedule': this.open_modal_schedule_workstation_modal(data.instance_id); break;
      case 'storage': this.open_modal_add_to_workstation_storage_modal(data.instance_id); break;
    }
  }

  // Turn the Workstation On or Off
  public toggle_workstation(id: string): void {
    let workstation_data = this.workstations.find((workstation: any) => { if (workstation.instance_id == id) return workstation })
    workstation_data.loading = true;
    // console.log({ workstation_data });

    if (workstation_data.status == true) {
      this.selected_workstation = workstation_data;
      this.open_shutdown_workstation_modal();
    } else {
      const _API = this.api.workstation_action(id, 'run').subscribe((response: any) => {
        console.log('Workstation: running', response)
        _API.unsubscribe();
        workstation_data.status = true;
        workstation_data.loading = false;
      })
    }

  }

  // Launch and Connect to Workstation
  public launch_workstation(id: string): void {

    // Get Guacamole URL from **Resource URLS** in `environment.ts`
    const guacamole_url = `https://${environment.resource_urls.guacamole}/guacamole/#/`;

    // Create Headers for Guacamole using current user `username`
    const guacamole_headers: Headers = new Headers();
    guacamole_headers.set("remote_user", this.user_info.username);

    // Create Async Function that will generate Guacamole Window with headers.
    const OpenGuacamoleWindow = async (url: string, headers: Headers) => {
      console.log("[OpenGuacamoleWindow]: ", { url, headers });
      fetch(url, { method: "GET", headers, mode: "no-cors" }).then((res) => res.blob()).then((blob) => {
        console.log("[fetch:response]: ", { blob: blob.text() })
        var guacamole = window.URL.createObjectURL(blob);
        console.log("Opening New Tab....\n")
        window.open(guacamole, "_blank")?.focus();
      })
    };

    // Call Async Function with URL and Headers, wait for window to open. 
    OpenGuacamoleWindow(guacamole_url, guacamole_headers).then(() => { });
  }

  /* ::===================:: MODALS ::===================:: */

  // :: Shutdown Workstation Modal

  // Open Shutdown Workstation Modal
  public open_shutdown_workstation_modal(): void { this.Modal_ShutDownWorkstation.open(); }
  // Shutdown Workstation Api Call
  public shutting_down_workstation: boolean = false;
  public shutdown_workstation(): void {
    const id = this.selected_workstation.instance_id;
    this.shutting_down_workstation = true;
    const _API = this.api.workstation_action(id, 'stop').subscribe((response: any) => {
      console.log('Workstation: stopped', response)
      _API.unsubscribe();
      this.selected_workstation.status = false;
      this.close_shutdown_workstation_modal();
      this.shutting_down_workstation = false;
    })
  }
  // Close Shutdown Workstation Modal
  public close_shutdown_workstation_modal(): void {
    this.selected_workstation.loading = false;
    this.shutting_down_workstation = false;
    this.selected_workstation = undefined;
    this.Modal_ShutDownWorkstation.close();
  }

  // :: Resize Workstation Modal
  public resize_params: { id: any, cpu: any, ram: any } = { id: undefined, cpu: undefined, ram: undefined };

  public loading_instance_types: boolean = false;
  public resize_instance_type: Array<any> = [];
  public resize_recommended_instance_type: Array<any> = [];
  public start_after_resize: boolean = false;

  // Open Resize Workstation Modal
  public open_modal_resize_workstation_modal(id: string): void {
    let workstation_data = this.workstations.find((workstation: any) => { if (workstation.instance_id == id) return workstation });
    this.selected_workstation = workstation_data;
    this.Modal_ResizeWorkstation.open();
    this.resize_params = { id, cpu: undefined, ram: undefined }
  }

  public gather_instance_types(): void {
    this.loading_instance_types = true;
    this.selected_instance_type = undefined;
    const { cpu, ram } = this.resize_params;
    console.log('gather_instance_types', { cpu, ram })
    if (cpu && ram) {
      const API = this.api.get_instance_types(cpu, ram, 'windows').subscribe((response: any) => {
        console.log("response", response)
        if (response.length > 0) {
          const [list, recommended] = response;
          console.log("response array objects", { list, recommended });
          this.resize_instance_type = [
            ...recommended.recommendedlist.filter((instance: any) => { if (instance.instanceType) return instance; }).map((instance: any) => { return { ...instance, recommended: true } }),
            ...list.pricelist.filter((instance: any) => { if (instance.instanceType) return instance; }).map((instance: any) => { return { ...instance, recommended: false } }),
          ];
        }
        this.loading_instance_types = false;
        API.unsubscribe();
      })
    }
  }
  public selected_instance_type: any;

  public select_instance_type(instance: any) { this.selected_instance_type = instance; }

  // Submit Resize Workstation Form
  public submit_resize_workstation(): void {
    const user = {
      username: this.user_info.username,
      user_email: this.user_info.email
    };

    const workstation = {
      instance_type: this.selected_workstation.instance_type.trim(),
      instance_id: this.selected_workstation.instance_id.trim(),
      operating_system: this.selected_workstation.operating_system.trim(),
    };

    const instance_params = {
      requested_instance_type: this.selected_instance_type.instanceType,
      cpu: parseInt(this.selected_instance_type.vcpu),
      ram: parseInt(this.selected_instance_type.memory.split(" ")[0]),
      start_after_resize: this.start_after_resize
    };

    const API = this.api.send_resize_instance_request(user, workstation, instance_params).subscribe((response: any) => {
      console.log(response);
      this.selected_workstation.status = false;
      this.close_modal_resize_workstation_modal();
      API.unsubscribe();
    });

  }

  // Close Resize Workstation Modal
  public close_modal_resize_workstation_modal(): void {
    this.Modal_ResizeWorkstation.close();
    this.selected_workstation = undefined;
    this.selected_instance_type = undefined;
  }

  // :: Schedule Workstation Modal
  // Open Schedule Workstation Modal
  public open_modal_schedule_workstation_modal(id: string): void { this.Modal_ScheduleWorkstation.open(); }
  // Submit Schedule Workstation Form
  public submit_schedule_workstation(): void { }
  // Close Schedule Workstation Modal
  public close_modal_schedule_workstation_modal(): void { this.Modal_ScheduleWorkstation.close(); }

  // :: Add Storage to Workstation Modal
  // Open Add Storage to Workstation Modal
  public open_modal_add_to_workstation_storage_modal(id: string): void { this.Modal_AddToWorkstationStorage.open(); }
  // Submit Add Storage to Workstation Form
  public submit_add_to_workstation(): void { }
  // Close Add Storage to Workstation Modal
  public close_modal_add_to_workstation_storage_modal(): void { this.Modal_AddToWorkstationStorage.close(); }



  public _subscriptions: Array<Subscription> = [];
  public user_info: any;

  ngOnInit(): void {
    this._subscriptions.push(
      this.auth.user_info.subscribe((user: any) => {
        console.log("User: ", user);
        this.user_info = user;
      }),
    );

  }

  ngAfterViewInit(): void {
    // Initialize Bootstrap JS Tooltips
    const tooltipTriggerList: any = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
  }

  ngOnDestroy(): void { this._subscriptions.forEach(s => s.unsubscribe()); }
}
