import { Component, Input, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';

@Component({
  selector: 'app-user-request-center',
  templateUrl: './user-request-center.component.html',
  styleUrls: ['./user-request-center.component.less']
})
export class UserRequestCenterComponent implements OnInit {

  @ViewChild('Modal_RequestTrustedUserStatus') Modal_RequestTrustedUserStatus: ModalComponent | any;
  @ViewChild('Modal_RequestEdgeDatabases') Modal_RequestEdgeDatabases: ModalComponent | any;

  @Input() datasets: Array<any> = [];


  public export_table_name: any;
  public export_table_additional_sources: any;
  public export_workflows: any[] = [];
  public export_workflows_datasets: any[] = [];

  public selected_dataset_project: any;
  public selected_provider: any;
  public selected_provider_sub_dataset: any;

  private request_type: any;
  public request_justification: any;
  public request_policy_agreement: boolean = false;

  constructor() { }


  public open_modal_request_trusted_user_status(): void { this.request_type = 'trusted-user-status'; this.Modal_RequestTrustedUserStatus.open(); }
  public close_modal_request_trusted_user_status(): void { this.Modal_RequestTrustedUserStatus.close(); this.reset_forms(); }

  public open_modal_request_edge_databases(): void { this.request_type = 'edge-databases'; this.Modal_RequestEdgeDatabases.open(); }
  public close_modal_request_edge_databases(): void { this.Modal_RequestEdgeDatabases.close(); this.reset_forms(); }

  public select_dataset_project(event: any): void {
    this.selected_dataset_project = event.target.value;
    const project = this.datasets.find((d: any) => { if (d.Name == this.selected_dataset_project) return d; });

    this.export_workflows = [];
    this.export_workflows_datasets = [];
    this.selected_provider = undefined;
    this.selected_provider_sub_dataset = undefined;

    for (let key in project.exportWorkflow) {
      const pro_workflow = project.exportWorkflow[key];
      for (let w_key in pro_workflow) {
        const workflow = pro_workflow[w_key];
        this.export_workflows.push({ name: w_key, ...workflow });
        for (let d_key in workflow.datatypes) {
          const datatype = workflow.datatypes[d_key];
          this.export_workflows_datasets.push({ name: d_key, ...datatype });
        }
      }
    }


    console.log({
      project,
      export_workflows: this.export_workflows,
      export_workflows_datatypes: this.export_workflows_datasets
    });
  }

  public select_dataset_provider(event: any): void {
    const provider = this.export_workflows.find(w => w.name == event.target.value);
    this.selected_provider = provider;
    console.log(this.selected_provider);
  }

  public select_dataset_provider_sub_dataset(event: any): void {
    const dataset = this.export_workflows_datasets.find(d => d.name == event.target.value)
    this.selected_provider_sub_dataset = dataset;
    console.log(this.selected_provider_sub_dataset);
  }

  public reset_forms(): void {
    this.export_table_name = undefined;
    this.export_table_additional_sources = undefined;
    this.export_workflows = [];
    this.export_workflows_datasets = [undefined];
    this.selected_dataset_project = undefined;
    this.selected_provider = undefined;
    this.selected_provider_sub_dataset = undefined;
    this.request_type = undefined;
    this.request_justification = undefined;
    this.request_policy_agreement = false;
  }

  public is_request_valid(): boolean {
    const type = this.request_type;

    // console.log({ request_type: this.request_type, dataset: this.selected_dataset_project, justification: this.request_justification, export_table_name: this.request_type == 'edge-databases' ? this.export_table_name : undefined, export_table_additional_sources: this.request_type == 'edge-databases' ? this.export_table_additional_sources : undefined, });

    if (this.selected_dataset_project == undefined) return false;
    if (this.request_justification == undefined) return false;
    if (this.request_policy_agreement == false) return false;

    if (type == 'edge-databases') {
      if (this.export_table_name == undefined) return false;
      // if (this.export_table_additional_sources == undefined) return false;
    }

    return true;
  }

  public submit_request(): void {

    var payload: any = {
      request_type: this.request_type,
      project: this.selected_dataset_project,
      justification: this.request_justification,
      policy_accepted: this.request_policy_agreement
    };

    if (this.request_type == 'trusted-user-status') {
      payload.provider = this.selected_provider;
      payload.dataset = this.selected_provider_sub_dataset;
    }

    if (this.request_type == 'edge-databases') {
      payload.table_name = this.export_table_name;
      payload.additional_sources = this.export_table_additional_sources;

    }

    console.log("SUBMITTING REQUEST", payload);
  }

  ngOnInit(): void { }

}
