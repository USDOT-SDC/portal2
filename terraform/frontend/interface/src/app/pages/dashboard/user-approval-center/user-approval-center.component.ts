import { Component, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { Subscription } from 'rxjs';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-user-approval-center',
  templateUrl: './user-approval-center.component.html',
  styleUrls: ['./user-approval-center.component.less']
})
export class UserApprovalCenterComponent implements OnInit, OnDestroy {

  @ViewChild('Modal_RequestDetails') Modal_UploadFiles: ModalComponent | any;

  private _subscription: Array<Subscription> = [];

  public s3_requests: Array<any> = [];

  public table_export_requests: Array<any> = [];

  public trusted_user_status_requests: Array<any> = [];

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
  }

  ngOnInit(): void {
    this._subscription.push(
      this.auth.user_info.subscribe((user) => {
        if (user) {
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
      })
    )
  }

  ngOnDestroy(): void {
    this._subscription.forEach((s) => s.unsubscribe());
  }

}
