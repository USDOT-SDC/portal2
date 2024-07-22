import { Component, Input, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';

@Component({
  selector: 'app-sdc-datasets',
  templateUrl: './sdc-datasets.component.html',
  styleUrls: ['./sdc-datasets.component.less']
})
export class SdcDatasetsComponent implements OnInit {

  @ViewChild('Modal_RequestDatasets') Modal_RequestDatasets: ModalComponent | any;

  @Input() datasets: Array<any> = [];

  public selected_dataset: any;

  public is_us_dot_employee: boolean = false;

  constructor() { }

  public select_dataset_to_request(dataset: any): void {
    this.selected_dataset = dataset;
    this.open_request_datasets_modal();
  }

  public open_request_datasets_modal(): void { this.Modal_RequestDatasets.open(); }

  public close_request_datasets_modal(): void {
    this.selected_dataset = undefined;
    this.Modal_RequestDatasets.close();
  }

  ngOnInit(): void {
  }

}
