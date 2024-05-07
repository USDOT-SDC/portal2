import { Component, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';

@Component({
  selector: 'app-datasets',
  templateUrl: './datasets.component.html',
  styleUrls: ['./datasets.component.less']
})
export class DatasetsComponent implements OnInit {

  @ViewChild('Modal_UploadFiles') Modal_UploadFiles: ModalComponent | any;
  @ViewChild('Modal_RequestTrustedUser') Modal_RequestTrustedUser: ModalComponent | any;
  @ViewChild('Modal_UploadFiles') Modal_RequestTableExport: ModalComponent | any;

  public user_datasets_algorithms: Array<any> = [];
  public user_edge_databases: Array<any> = [];
  public sdc_datasets: Array<any> = [];
  public sdc_algorithms: Array<any> = [];

  public files_to_upload: Array<any> = [
    { file_name: 'example.pdf', file_size: 0 },
    { file_name: 'example_two.pdf', file_size: 0 },
    { file_name: 'example_three.docx', file_size: 0 },
  ]

  constructor() { }

  // Modal Open - File Upload
  public modal_open_file_upload(): void { this.Modal_UploadFiles.open(); }
  // Modal Close - File Upload
  public modal_close_file_upload(): void { this.Modal_UploadFiles.close(); }

  // Modal Open - Request trusted User
  public modal_open_request_trusted_user(): void { this.Modal_RequestTrustedUser.open(); }
  // Modal Close - Request trusted User
  public modal_close_request_trusted_user(): void { this.Modal_RequestTrustedUser.close(); }

  // Modal Open - Request Table Export
  public modal_open_request_table_export(): void { this.Modal_RequestTableExport.open(); }
  // Modal Close - Request Table Export
  public modal_close_request_table_export(): void { this.Modal_RequestTableExport.close(); }

  // Sort Method - Sort User Datasets and Algorithms
  public sort_ds_and_alg(event: any): void {
    const value: number = parseInt(event.target.value);
    switch (value) {
      case 1: break
      case 2: break
      case 3: break
      case 4: break
    }
  }

  ngOnInit(): void {
  }

}
