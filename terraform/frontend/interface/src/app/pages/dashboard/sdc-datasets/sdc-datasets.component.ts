import { Component, Input, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-sdc-datasets',
  templateUrl: './sdc-datasets.component.html',
  styleUrls: ['./sdc-datasets.component.less']
})
export class SdcDatasetsComponent implements OnInit {

  @ViewChild('Modal_RequestDatasets') Modal_RequestDatasets: ModalComponent | any;

  @Input() sdc_datasets: Array<any> = [];

  public selected_dataset: any;

  public accepted_use_policy: boolean = false;
  public is_us_dot_employee: boolean = false;
  public request_dot_email: any;
  public request_justification: any;
  public is_loading: boolean = false;

  constructor(private auth: AuthService, private api: ApiService) { }

  public select_dataset_to_request(dataset: any): void {
    this.selected_dataset = dataset;
    this.open_request_datasets_modal();
  }

  public open_request_datasets_modal(): void { this.Modal_RequestDatasets.open(); }

  public is_request_valid(): boolean {
    if (this.is_us_dot_employee == true) if (this.request_dot_email === undefined || this.request_dot_email.trim() === "") return false;
    if (this.request_justification === undefined || this.request_justification.trim() === "") return false;
    if (this.accepted_use_policy == false) return false;
    return true;
  }

  public submit_data_access_request(): void {
    this.is_loading = true;

    console.log(this.selected_dataset)

    var payload: any = {
      dataset: this.selected_dataset,
      us_dot_email: this.request_dot_email,
      approver_email: JSON.stringify(this.find_key(this.selected_dataset["exportWorkflow"], "ListOfPOC"))
    };
    const user = this.auth.user_info.getValue();

    console.log("SUBMITTING REQUEST", { user, payload });

    const req_message = `User: ${user} is requesting access to dataset: ${this.selected_dataset["Name"]} which you are an approver for. Please update their access or notify them if access will not be granted.
    
    User email: ${this.request_dot_email}`

    // API CALL . . . .
    this.api.send_email_request(this.request_dot_email, req_message, JSON.stringify(this.find_key(this.selected_dataset["exportWorkflow"], "ListOfPOC"))).subscribe((response: any) => { console.log(response); });

    setTimeout(() => {
      this.is_loading = false;
      this.close_request_datasets_modal();
    }, 1000)
  }


  public close_request_datasets_modal(): void {
    this.selected_dataset = undefined;
    this.Modal_RequestDatasets.close();
  }

  ngOnInit(): void {
  }

  find_key(obj: object, key: string) {
  const ret: any[] = [];
  JSON.stringify(obj, (_, nested) => {
    if (nested && nested[key]) {
      ret.push(nested[key]);
    }
    return nested;
  });
  return ret;
};

}
