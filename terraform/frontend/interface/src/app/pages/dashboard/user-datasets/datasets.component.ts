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

  @ViewChild('Modal_UploadFiles') Modal_UploadFiles: ModalComponent | any;
  @ViewChild('Modal_RequestTrustedUser') Modal_RequestTrustedUser: ModalComponent | any;
  @ViewChild('Modal_UploadFiles') Modal_RequestTableExport: ModalComponent | any;


  @ViewChild('file_uploader') file_uploader: FileUploadComponent | any;


  private _subscriptions: Array<Subscription> = [];

  public current_user: any;
  public current_user_upload_bucket: any;
  public current_user_upload_locations: any = [];

  public user_datasets_algorithms: Array<any> = [];
  public user_edge_databases: Array<any> = [];
  public sdc_datasets: Array<any> = [];
  public sdc_algorithms: Array<any> = [];

  public uploading_files: boolean = false;
  public file_upload_bucket: any;
  public file_upload_bucket_prefix: any;
  public selected_files: Array<any> = [];
  public file_upload_search_term: any;

  constructor(private auth: AuthService, private api: ApiService) { }

  private refresh_user_uploads(): void {
    const user_name = this.current_user.username;
    const user_data_api = this.api.get_user_uploaded_data(this.current_user_upload_bucket, user_name).subscribe((response: any) => {
      this.user_datasets_algorithms = response
        .map((file: string) => { return { filename: file, status: false } })
        .filter((file: any) => { if (this.file_is_folder(file.filename) == false) return file });
      user_data_api.unsubscribe();
    })
  }

  // Modal Open - Request trusted User
  public modal_open_request_trusted_user(): void { this.Modal_RequestTrustedUser.open(); }
  // Modal Close - Request trusted User
  public modal_close_request_trusted_user(): void { this.Modal_RequestTrustedUser.close(); }

  // Modal Open - Request Table Export
  public modal_open_request_table_export(): void { this.Modal_RequestTableExport.open(); }
  // Modal Close - Request Table Export
  public modal_close_request_table_export(): void { this.Modal_RequestTableExport.close(); }



  public clear_search_filter(): void { this.file_upload_search_term = undefined; }

  // Sort Method - Sort User Datasets and Algorithms
  public sort_ds_and_alg(event: any): void {
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
      const statusOrder: any = { "Submitted": 0, "Denied": 1, "Approved": 2 };
      let statusA: any = a.status, statusB: any = b.status;
      // Use the predefined order to compare statuses
      return statusOrder[statusA] - statusOrder[statusB];
    }

    function sortByStatus_desc(a: any, b: any) {
      const statusOrder: any = { "Submitted": 0, "Denied": 1, "Approved": 2 };
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
      default: break;
    }
  }

  public select_folder(data: any) {
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

  // Modal Close - File Upload
  public modal_close_file_upload(): void {
    this.Modal_UploadFiles.close();
    this.file_upload_bucket = undefined;
    this.file_upload_bucket_prefix = undefined;
    this.file_uploader.files_to_upload = [];
  }


  ngOnInit(): void {
    this._subscriptions.push(
      this.auth.user_info.subscribe((user: any) => {
        this.current_user = user;
        if (this.current_user) {
          this.current_user_upload_locations = user.upload_locations.map((l: any) => { return { path: l } });
          this.current_user_upload_bucket = user.upload_locations[0].split('/')[0];
          this.refresh_user_uploads();
        }
      })
    );
  }

  ngOnDestroy(): void {
    this._subscriptions.forEach(s => s.unsubscribe())
  }
}
