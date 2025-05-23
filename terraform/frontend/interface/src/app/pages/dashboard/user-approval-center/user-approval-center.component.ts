import { AfterViewInit, Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

declare var bootstrap: any;

@Component({
  selector: 'app-user-approval-center',
  templateUrl: './user-approval-center.component.html',
  styleUrls: ['./user-approval-center.component.less']
})
export class UserApprovalCenterComponent implements OnInit, OnDestroy, AfterViewInit {

  @ViewChild('Modal_RequestDetails') Modal_UploadFiles: ModalComponent | any;

  private _subscription: Array<Subscription> = [];

  public api_is_loading: boolean = false;

  public s3_requests: Array<any> = [];

  public table_export_requests: Array<any> = [];

  public trusted_user_status_requests: Array<any> = [];

  public view_raw_data: boolean = false;

  constructor(private api: ApiService, private auth: AuthService) { }

  private sort_requests(a: any, b: any): number {
    // Convert dates to timestamps for comparison
    const dateA = new Date(a.ReqReceivedTimestamp).getTime();
    const dateB = new Date(b.ReqReceivedTimestamp).getTime();

    // Define submission status order
    const statusOrder: any = { "Submitted": 1, "Approved": 2, "Rejected": 3 };

    // Compare dates first (newest first)
    if (dateA !== dateB) { return dateB - dateA; /* Newest date first */ }

    // If dates are the same, sort by submission status
    return statusOrder[a.RequestReviewStatus] - statusOrder[b.RequestReviewStatus];
  }

  public timestamp_to_date(timestamp: number): Date { return new Date(timestamp * 1000); }


  public selected_request: any;

  public toggle_view_request_details(request: any) {
    this.selected_request = request;
    this.open_request_details_modal();
  }

  public open_request_details_modal(): void { this.Modal_UploadFiles.open(); }

  public close_request_details_modal(): void {
    this.Modal_UploadFiles.close();
    this.selected_request = undefined;
    this.view_raw_data = false;
  }

  
  /**
   * Export Table Request - Handle Approver Response
   */
  public submit_export_table_request(approved: boolean, data: any) {
    const user = this.auth.user_info.getValue();
    // console.log('submit_export_table_request, incoming data: ', { data, user });
    var payload: any = {
      status: approved == true ? 'Approved' : 'Rejected',
      key1: data.S3KeyHash,
      key2: data.RequestedBy_Epoch,
      userEmail: user.email
    };
    // console.log('submit_export_table_request', payload);
    const api = this.api.send_update_export_table_status(payload).subscribe((response: any) => {
      // console.log(response);
      this.get_approvals(user);
      window.location.reload;
      api.unsubscribe();
    });

  }

  /**
   * Export File Request - Handle Approver Response
   */
  public submit_file_status_request(approved: boolean, data: any) {
    const user = this.auth.user_info.getValue();
    this.api_is_loading = true; // Enable Loading Boolean
    console.log('submit_file_export_request, incoming data: ', { data });
    console.log('submit_file_export_request, incoming user: ', { user });
    var payload: any = {
      status: approved == true ? 'Approved' : 'Rejected',
      key1: data.S3KeyHash,
      key2: data.RequestedBy_Epoch,
      datainfo: data['Dataset-DataProvider-Datatype'],
      S3Key: data.S3Key,
      TeamBucket: data.TeamBucket,
      userEmail: user.email
    };
    console.log('submit_file_export_request', payload);
    const api = this.api.send_update_file_status(payload).subscribe((response: any) => {
      console.log('send_update_files_status response: ', response);
      console.log('user param submitted to "this.get_approvals": ', user)
      this.get_approvals(user);
      window.location.reload;
      this.api_is_loading = false; // Disabled Loading Boolean 
      api.unsubscribe();
    });
  }

  /**
   * Trusted User Status Request - Handle Approver Response
   */
  public respond_trusted_status_request(approved: boolean, data: any) {
    const user = this.auth.user_info.getValue();
    console.log('respond_trusted_status_request, incoming data: ', { data, user });
    var payload: any = {
      status: approved == true ? 'Trusted' : 'Untrusted',
      key1: data.UserID,
      datainfo: data['Dataset-DataProvider-Datatype'],
      userEmail: data.UserEmail
    };
    console.log('respond_trusted_status_request', payload);
    const api = this.api.send_update_trusted_status(payload).subscribe((response: any) => {
      console.log(response);
      this.get_approvals(user);
      window.location.reload;
      api.unsubscribe();
    });
  }

  public get_approvals(user: any) {
  console.log('get_approvals called');
  console.log('get_approvals-user: ', user);
    const API = this.api.get_export_request_approval_list(user.email).subscribe((response: any) => {
      console.log(response);
      if (response.exportRequests) {
        const { exportRequests, trustedRequests, autoExportRequests } = response;
        this.table_export_requests = exportRequests.tableRequests.sort(this.sort_requests);
        this.s3_requests = exportRequests.s3Requests.sort(this.sort_requests);
        if (trustedRequests.length > 0) {
          this.trusted_user_status_requests = [];
          trustedRequests.forEach((array: any) => { this.trusted_user_status_requests.push(...array) });
        }
        console.log({ trusted_user_status_requests: this.trusted_user_status_requests });
      }
      API.unsubscribe();
    });
  }

  ngOnInit(): void {
    this._subscription.push(
      this.auth.user_info.subscribe((user) => {
        if (user) { this.get_approvals(user); }
      })
    )
  }

  ngAfterViewInit(): void {
    // Initialize Bootstrap JS Tooltips
    const tooltipTriggerList: any = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
  }

  ngOnDestroy(): void { this._subscription.forEach((s) => s.unsubscribe()); }

}
