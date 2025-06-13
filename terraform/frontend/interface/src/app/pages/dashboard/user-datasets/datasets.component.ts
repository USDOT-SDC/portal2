import { Component, Input, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { FileUploadComponent } from 'src/app/components/file-upload/file-upload.component';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-datasets',
  templateUrl: './datasets.component.html',
  styleUrls: ['./datasets.component.less']
})
export class DatasetsComponent implements OnInit, OnDestroy {

  @Input() sdc_datasets: Array<any> = [];

  @ViewChild('Modal_UploadFiles') Modal_UploadFiles: ModalComponent | any;
  @ViewChild('Modal_RequestExportData') Modal_RequestExportData: ModalComponent | any;
  @ViewChild('file_uploader') file_uploader: FileUploadComponent | any;
  @ViewChild('AuthRenewModal') AuthRenewModal: ModalComponent | any;


  private _subscriptions: Array<Subscription> = [];

  public current_user: any;
  public current_user_upload_bucket: any;
  public current_user_upload_locations: any = [];
  public user_datasets_algorithms: Array<any> = []; 
  public uploading_files: boolean = false;
  public file_upload_bucket: any;
  public file_upload_bucket_prefix: any;
  public selected_files: Array<any> = [];
  public file_upload_search_term: any;
  private request_type: any;

  constructor(private auth: AuthService, private api: ApiService) { }

  private refresh_user_uploads(): void {
    // console.log('start refresh_user_uploads')
    const user_name = this.current_user.username;
    const user_data_api = this.api.get_user_uploaded_data(this.current_user_upload_bucket, user_name).subscribe((response: any) => {
      this.user_datasets_algorithms = response
        .map((file: string) => { return { filename: file, status: false } })
        .filter((file: any) => { if (this.file_is_folder(file.filename) == false) return file });
      console.log('refresh_user_uploads_this.user_datasets_algorithms: ', this.user_datasets_algorithms);
      user_data_api.unsubscribe();
    })
  }

// Placeholder: sort user_uploads by last modified desc... 
// Note: lambda chgs likely required, since lastmodified data is not currently included in response
        //this.user_datasets_algorithms.sort((a, b) => b.lastModified.getTime() - a.lastModified.getTime());
        

  public clear_search_filter(): void { this.file_upload_search_term = undefined; }

  // Sort Method - Sort User Datasets and Algorithms
  public sort_ds_and_alg(event: any): void {
    console.log('sort_ds_and_alg event; ', event)
    const value: number = parseInt(event.target.value);

    switch (value) {
      case 1: this.user_datasets_algorithms = this.user_datasets_algorithms.sort(sortByName_asc); break
      case 2: this.user_datasets_algorithms = this.user_datasets_algorithms.sort(sortByName_desc); break
      case 3: this.user_datasets_algorithms = this.user_datasets_algorithms.sort(sortByStatus_asc); break
      case 4: this.user_datasets_algorithms = this.user_datasets_algorithms.sort(sortByStatus_desc); break
    }

    function sortByName_asc(a: any, b: any) {
      // Convert both names to lowercase to ensure case insensitivity
      let nameA = a.filename.toLowerCase(), nameB = b.filename.toLowerCase();
      if (nameA < nameB) return -1;
      if (nameA > nameB) return 1;
      return 0; // names must be equal
    }

    function sortByName_desc(a: any, b: any) {
      // Convert both names to lowercase to ensure case insensitivity
      let nameA = a.filename.toLowerCase(), nameB = b.filename.toLowerCase();
      if (nameA > nameB) return -1;
      if (nameA < nameB) return 1;
      return 0; // names must be equal
    }

    function sortByStatus_asc(a: any, b: any) {
      const statusOrder: any = { "-": 0, "Submitted": 1, "Rejected": 2, "Approved": 3 };

      let statusA: any = a.status, statusB: any = b.status;
      // Use the predefined order to compare statuses
      return statusOrder[statusA] - statusOrder[statusB];
    }

    function sortByStatus_desc(a: any, b: any) {
      const statusOrder: any = { "-": 0, "Submitted": 1, "Rejected": 2, "Approved": 3 };
      let statusA: any = a.status, statusB: any = b.status;
      // Use the predefined order to compare statuses
      return statusOrder[statusB] - statusOrder[statusA];
    }
  }

  public file_is_folder(filename: string): boolean { return filename.endsWith('/'); }

  public toggle_select_files(event: any) {
    console.log(event.target.checked)
    if (event.target.checked == false) {
      this.user_datasets_algorithms.map(d => d.selected = false);
      this.selected_files = [];
    } else {
      this.user_datasets_algorithms.map(d => { if (d.status == 'Approved') d.selected = true })
      this.selected_files = [...this.user_datasets_algorithms];
    }
  }

  public handle_file_action(event: { action: string, data: any }) {
    console.log(event);
    switch (event.action) {
      case 'selected': this.select_folder(event.data); break;
      case 'export': this.toggle_request_export_data(event.data); break;
      default: break;
    }
  }

  private select_folder(data: any) {
    console.log({ file_to_add: data, file_list: this.selected_files })
    const exists = this.selected_files.findIndex(f => f.filename == data.filename);
    if (exists == -1) {
      this.selected_files.push(data)
      data.selected = true;
    }
    else {
      this.selected_files.splice(exists, 1)
      data.selected = false;
    };
    console.log({ file_list: this.selected_files });
  }

  /**
   * Export Data Modal Functions
   */
  public submitting_export_request: boolean = false;
  public selected_data_for_export: any;

  public data_for_export_project: any;
  public data_for_export_provider: any;
  public data_for_export_dataset: any;

  
  // Toggles open the Export Data Modal
  private toggle_request_export_data(dataset: any): void {
    this.selected_data_for_export = dataset;
    this.request_type = 'exportRequest';
    this.Modal_RequestExportData.open();
  }

  

  // Modal Close - Request Export Data Modal -- NOT CURRENTLY USED
  public modal_close_request_export_data(): void {
        this.selected_data_for_export = undefined;
        this.Modal_RequestExportData.close();
      }


  /**
   * File Upload Modal Functions
   */
  // Modal Open - File Upload
  public modal_open_file_upload(): void { this.Modal_UploadFiles.open(); }

  public upload_files(): void {
    this.uploading_files = true;

    const [bucket, prefix, files] = [this.file_upload_bucket, this.file_upload_bucket_prefix, this.file_uploader.files_to_upload];

    console.log("===========::UPLOADING:INITIALIZED::===========");
    console.log({ bucket, prefix, files });

    var promises: Array<Promise<any>> = [];

    // Loop over Each File
    this.file_uploader.files_to_upload.forEach((file: any, index: number) =>
      // Push the Promise to Promises
      promises.push(new Promise((resolve, reject) => {
        // Send API Request, Promise is dependant on API response

        console.log(`===========::FILE:${index + 1}::===========`);
        console.log("File Data: ", file);
        console.log("Grabbing Presigned Upload URL for: ", file.file_name);

        this.api.get_s3_upload_url(bucket, file.file_name, file.file_type).subscribe((presigned_url: any) => {

          console.log("The Presigned Upload URL: ", presigned_url);

          console.log(`Will now Upload ${file.file_name} to ${presigned_url}`);

          this.api.upload_file_to_s3(presigned_url, file.file, file.file_type).subscribe({
            next: (uploaded) => { console.log(uploaded); resolve({ success: true, response: uploaded }) },
            error: (error: any) => { console.error(error); reject({ success: false, response: error }) }
          })
        })
      }))
    );

    // Await for all Promises to Complete
    Promise.all(promises).then((responses: any) => {
      console.log("Promise Responses: ", responses);
      this.uploading_files = false;
      this.refresh_user_uploads();
      this.modal_close_file_upload();
    });

  }

  public download_files() {
    // console.log("download_files called");
    for (let selectedFile of this.selected_files) {
      this.user_datasets_algorithms.forEach((datasetObj, index) => {
          if (selectedFile["filename"] == datasetObj["filename"]) {
            if (datasetObj["status"] == "Approved") {
              this.api
                .download_file_from_s3(
                  this.current_user_upload_bucket,
                  selectedFile.filename,
                  this.current_user.username
                )
                  .subscribe({
                    next: (response: any) => {
                    window.open(response, "_blank");
                    },
                    error: (err: any) => {
                    console.log(err);
                    },
                    complete: () => {
                    console.log('download url(s) received');
                    }
                  });
            } 
          }
        }
      )
    }
  }

  // Export Request Module Functions


  public selected_dataset_project: any;
  public selected_provider: any;
  public request_name: any;
  public request_email: any;
  public request_address: any;
  public request_city: any;
  public request_state: any;
  public request_zipcode: any;
  public request_additional_data_sources: any;
  public selected_provider_sub_dataset: any;
  public export_workflows: any[] = [];
  public export_workflows_datasets: any[] = [];
  public request_justification: any;
  public request_policy_agreement: boolean = false;
  public S3Key: any;
  public export_table_name: any;
  public export_table_additional_sources: any;
  public is_loading: boolean = false;
  public data_for_export_approval_form : any;

  public select_dataset_project(event: any): void {
    // console.log('select_dataset_project starts');
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



  public is_request_valid(): boolean {
    const type = this.request_type;

    // console.log({ request_type: this.request_type, dataset: this.selected_dataset_project, justification: this.request_justification, export_table_name: this.request_type == 'edge-databases' ? this.export_table_name : undefined, export_table_additional_sources: this.request_type == 'edge-databases' ? this.export_table_additional_sources : undefined, });
    if (this.request_name == undefined) return false;
    if (this.request_email == undefined) return false;
    if (this.request_address == undefined) return false;
    if (this.request_city == undefined) return false;
    if (this.request_state == undefined) return false;
    if (this.request_zipcode == undefined) return false;
    if (this.request_justification == undefined || this.request_justification.trim() == "") return false;
    if (this.request_policy_agreement == false) return false;

    if (type == 'edge-databases') {
      if (this.export_table_name == undefined || this.export_table_name.trim() == "") return false;
      // if (this.export_table_additional_sources == undefined) return false;
    }

    return true;
  }

  public reset_forms(): void {
    this.request_name = undefined;
    this.request_email = undefined;
    this.request_address = undefined;
    this.request_zipcode = undefined;
    this.request_city = undefined;
    this.request_state = undefined;
    this.request_additional_data_sources = undefined;
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
    this.selected_data_for_export = undefined;
    this.data_for_export_approval_form = undefined;
  }


  // public data_for_export_approval_form: any = {
  //   name: undefined,
  //   address: undefined,
  //   city: undefined,
  //   state: undefined,
  //   zip: undefined,
  //   // . . .
  // }
  // // Modal Submit - Submit the Modal Form data to API
  // public submit_request_export_data(): void {
  //   this.submitting_export_request = true;
  //   const payload: any = {
  //     project: {
  //       name: this.data_for_export_project,
  //       provider: this.data_for_export_provider,
  //       dataset: this.data_for_export_dataset
  //     },
  //     approval_form: this.data_for_export_approval_form
  //   };

  //   console.log(payload);

  //   // API call ....  
  //   // API call ....  
  //   setTimeout(() => {
  //     this.submitting_export_request = false;
  //     this.modal_close_request_export_data();
  //   }, 1000)
  //   // API call ....  
  //   // API call ....  

  // };

  public submit_request(): void {
    console.log('submit_request() starts');
    this.is_loading = true;

    var payload: any = {
      request_type: this.request_type,
      project: this.selected_dataset_project,
      justification: this.request_justification,
      policy_accepted: this.request_policy_agreement,
      name: this.request_name,
      email: this.request_email,
      address: this.request_address,
      city: this.request_city,
      state: this.request_state,
      zipcode: this.request_zipcode,
      additional_data_sources: this.request_additional_data_sources,
      S3Key: this.selected_data_for_export.filename
    };
    // payload.provider = this.selected_provider;
    payload.dataset =  this.selected_provider_sub_dataset;
    // payload.table_name = this.export_table_name;
    // payload.additional_sources = this.export_table_additional_sources;
    this.data_for_export_approval_form = payload
    console.log("SUBMITTING REQUEST", payload);
    console.log("Submission Type == ", this.request_type)


    this.send_export_request().then((response: any) => {
      console.log('submit_request--this.send_export_request response:',response);
      this.refresh_user_uploads();
      setTimeout(() => {
        this.is_loading = false;
        window.location.reload();
        this.close_modal_export_request();
      }, 2 * 1000);
    });
  }

  private send_export_request(): Promise<any> {
    // console.log('send_export_request starts');
    const user = this.auth.user_info.getValue();
    return new Promise((resolve, reject) => {
      const message = {
        UserID: user.username,
        RequestReviewStatus:"Submitted",
        S3Key: this.selected_data_for_export.filename,
        TeamBucket: this.current_user_upload_bucket,
        ApprovalForm: this.data_for_export_approval_form,
        // trustedRequest: {
        //   trustedRequestStatus: "Submitted",
        //   trustedRequestReason: this.request_justification,
        // },
        selectedDataInfo: {
          selectedDataSet: this.selected_dataset_project,
          selectedDataProvider: this.selected_provider.name,
          selectedDatatype: this.selected_provider_sub_dataset.name
        }
      }
      console.log("send_export_request--message", message);

      const API = this.api.send_trusted_user_request(message).subscribe((response: any) => {
        console.log('send export request--api.send_trusted_user_request response: ', response);
        resolve(response);
        API.unsubscribe();
      })
    });
  }

  public close_modal_export_request(): void {
    console.log('in close_modal_export-request');
    this.Modal_RequestExportData.close();
    this.reset_forms();
    }


  public select_dataset_provider_sub_dataset(event: any): void {
    const dataset = this.export_workflows_datasets.find(d => d.name == event.target.value)
    this.selected_provider_sub_dataset = dataset;
    console.log(this.selected_provider_sub_dataset);
  }

  public select_dataset_provider(event: any): void {
    const provider = this.export_workflows.find(w => w.name == event.target.value);
    this.selected_provider = provider;
    console.log(this.selected_provider);
  }


  // Modal Close - File Upload
  public modal_close_file_upload(): void {
    this.Modal_UploadFiles.close();
    this.file_upload_bucket = undefined;
    this.file_upload_bucket_prefix = undefined;
    this.file_uploader.files_to_upload = [];
  }

  public auth_modal_open(): void {
    this.AuthRenewModal.open();
  }

  public auth_modal_close(): void {
    this.AuthRenewModal.close();
  }

  ngOnInit(): void {
    this._subscriptions.push(
      this.auth.user_info.subscribe((user: any) => {
        this.current_user = user;
        if (this.current_user) {
          this.current_user_upload_locations = user.upload_locations.map((l: any) => { return { path: l } });
          this.current_user_upload_bucket = user.upload_locations[0].split('/')[0];
          // console.log('ngOnInit calls refresh_user_uploads');
          this.refresh_user_uploads();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this._subscriptions.forEach(s => s.unsubscribe())
  }
}
