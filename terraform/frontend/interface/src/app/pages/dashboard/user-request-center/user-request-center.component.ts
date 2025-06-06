import { Component, Input, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-user-request-center',
  templateUrl: './user-request-center.component.html',
  styleUrls: ['./user-request-center.component.less']
})
export class UserRequestCenterComponent implements OnInit, OnDestroy {

  @ViewChild('Modal_RequestTrustedUserStatus') Modal_RequestTrustedUserStatus: ModalComponent | any;
  @ViewChild('Modal_RequestEdgeDatabases') Modal_RequestEdgeDatabases: ModalComponent | any;

  @Input() sdc_datasets: Array<any> = [];

  public is_loading: boolean = false;

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

  public team_slug: any;

  constructor(private api: ApiService, private auth: AuthService) { }

  public open_modal_request_trusted_user_status(): void { this.request_type = 'trusted-user-status'; this.Modal_RequestTrustedUserStatus.open(); }
  public close_modal_request_trusted_user_status(): void { this.Modal_RequestTrustedUserStatus.close(); this.reset_forms(); }

  public open_modal_request_edge_databases(): void { this.request_type = 'edge-databases'; this.Modal_RequestEdgeDatabases.open(); }
  public close_modal_request_edge_databases(): void { this.Modal_RequestEdgeDatabases.close(); this.reset_forms(); }

  public select_dataset_project(event: any): void {
    this.selected_dataset_project = event.target.value;
    const project = this.sdc_datasets.find((d: any) => { console.log(d); if (d.Name == this.selected_dataset_project) return d; });

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
    this.export_workflows_datasets = [];
    this.selected_dataset_project = undefined;
    this.selected_provider = undefined;
    this.selected_provider_sub_dataset = undefined;
    this.request_type = undefined;
    this.request_justification = undefined;
    this.request_policy_agreement = false;
  }

  public is_request_valid(): boolean {
    const type = this.request_type;
    // console.log('user-req: is_req_valid');
    // console.log({ request_type: this.request_type, dataset: this.selected_dataset_project, justification: this.request_justification, export_table_name: this.request_type == 'edge-databases' ? this.export_table_name : undefined, export_table_additional_sources: this.request_type == 'edge-databases' ? this.export_table_additional_sources : undefined, });

    if (this.selected_dataset_project == undefined) return false;
    if (this.request_justification == undefined || this.request_justification.trim() == "") return false;
    if (this.request_policy_agreement == false) return false;

    if (type == 'edge-databases') {
      console.log('URC: is request valid(): type == edge-databases');
      if (this.export_table_name == undefined || this.export_table_name.trim() == "") return false;
      // if (this.export_table_additional_sources == undefined) return false;
    }

    return true;
  }

  public submit_request(): void {
    console.log ('URC: start submit_request()');

    this.is_loading = true;

    var payload: any = {
      request_type: this.request_type,
      project: this.selected_dataset_project,
      justification: this.request_justification,
      policy_accepted: this.request_policy_agreement
    };
    // payload.provider = this.selected_provider;
    // payload.dataset =  this.selected_provider_sub_dataset;
    // payload.table_name = this.export_table_name;
    // payload.additional_sources = this.export_table_additional_sources;

    console.log("URC- SUBMIT REQUEST- payload: ", payload);

    if (this.request_type == 'edge-databases') {
      console.log('URC: submit_request(): req_type == edge-databases');
      this.send_export_edge_database_request().then((response: any) => {
        console.log('URC: submit_request(): send_export_edge_db_req - response: ', response);
        this.is_loading = false;
        this.close_modal_request_edge_databases();
      });
    }

    if (this.request_type == 'trusted-user-status') {
      console.log('URC: submit_request(): req_type == trusted-user-status');
      this.send_trusted_user_request().then((response: any) => {
        console.log('URC: submit_request(): send_trusted_user_req - response: ', response);
        this.is_loading = false;
        this.close_modal_request_trusted_user_status();
      });
    }

  }

  private send_export_edge_database_request(): Promise<any> {
   console.log('send_export_edge_db_request starts');
    const user = this.auth.current_user.getValue();
    const database = this.sdc_datasets.find(d => d.Name == this.selected_dataset_project);
    console.log('URC: send_export_edge_db_req: user/db: ',{ user, database });
    console.log('URC: send_export_edge_db_req: user: ', user);
    console.log('URC: send_export_edge_db_req: database: ', database);

    return new Promise((resolve, reject) => {
      const message = {
        RequestedBy_Epoch: new Date().getTime(),
        ReqReceivedtimestamp: null,
        RequestedBy: null,
        WorkflowStatus: null,
        RequestReviewedBy: null,
        ReqReviewTimestamp: null,
        S3Key: this.selected_dataset_project,        // this.messageModel.fileFolderName,
        TeamBucket: null,   // this.userBucketName,
        RequestID: null,
        ApprovalForm: {
          privateDatabase: this.team_slug,
          privateTable: '',
          datasetName: '',
          derivedDataSetname: '',
          detailedderiveddataset: '',
          dataprovider: '',
          datatype: '',
          datasources: '',
          justifyExport: '',

        }, // approvalForm,
        RequestReviewStatus: "Submitted",
        UserID: user.username,
        selectedDataInfo: {
          selectedDataSet: this.selected_dataset_project,
          selectedDataProvider: this.selected_provider,
          selectedDatatype: this.selected_provider_sub_dataset,
        },
        acceptableUse: this.request_policy_agreement,
        DatabaseName: this.team_slug,
        TableName: this.export_table_name,
      }
      console.log('URC: send_export_edge_database_request() message: ', message );
      // resolve(undefined);
      const API = this.api.send_export_table_request(message).subscribe((response: any) => {
         console.log(response);
         resolve(response);
         API.unsubscribe();
       })
    })
  }

  private send_trusted_user_request(): Promise<any> {
    console.log('send_export_edge_db_request starts');
    const user = this.auth.user_info.getValue();
    return new Promise((resolve, reject) => {
      const message = {
        UserID: user.username,
        trustedRequest: {
          trustedRequestStatus: "Submitted",
          trustedRequestReason: this.request_justification,
        },
        selectedDataInfo: {
          selectedDataSet: this.selected_dataset_project,
          selectedDataProvider: this.selected_provider.name,
          selectedDatatype: this.selected_provider_sub_dataset.name
        },
        acceptableUse: this.request_policy_agreement == true ? "Accept" : "Decline"
      }
      console.log("send_trusted_user_request", message);

      const API = this.api.send_trusted_user_request(message).subscribe((response: any) => {
        console.log(response);
        resolve(response);
        API.unsubscribe();
      })
    });
  }

  private _subscriptions: Array<Subscription> = [];

  ngOnInit(): void {
    this._subscriptions.push(this.auth.user_info.subscribe((user) => {
      // console.log(user);
      if (user) { this.team_slug = user.team_slug; }
    }))
  }
  ngOnDestroy(): void {
    this._subscriptions.forEach(s => s.unsubscribe());
  }
}
