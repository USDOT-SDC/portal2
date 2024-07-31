import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs';
import { ApiService } from 'src/app/services/api.service';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-user-approval-center',
  templateUrl: './user-approval-center.component.html',
  styleUrls: ['./user-approval-center.component.less']
})
export class UserApprovalCenterComponent implements OnInit, OnDestroy {

  private _subscription: Array<Subscription> = [];

  public s3_requests: Array<any> = [];

  public table_export_requests: Array<any> = [];

  public trusted_user_status_requests: Array<any> = [];

  constructor(private api: ApiService, private auth: AuthService) { }

  ngOnInit(): void {
    this._subscription.push(
      this.auth.user_info.subscribe((user) => {
        if (user) {
          const API = this.api.get_export_request_approval_list(user.email).subscribe((response: any) => {
            console.log(response);
            if (response.exportRequests) {
              const { exportRequests } = response;
              this.table_export_requests = exportRequests.tableRequests;
              this.s3_requests = exportRequests.s3Requests;
              this.trusted_user_status_requests = exportRequests.trustedRequests;
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
