import { Component, OnInit, ViewChild } from '@angular/core';
import { ModalComponent } from 'src/app/components/modal/modal.component';

@Component({
  selector: 'app-user-request-center',
  templateUrl: './user-request-center.component.html',
  styleUrls: ['./user-request-center.component.less']
})
export class UserRequestCenterComponent implements OnInit {

  @ViewChild('Modal_RequestTrustedUserStatus') Modal_RequestTrustedUserStatus: ModalComponent | any;
  @ViewChild('Modal_RequestEdgeDatabases') Modal_RequestEdgeDatabases: ModalComponent | any;

  constructor() { }

  public open_modal_request_trusted_user_status(): void { this.Modal_RequestTrustedUserStatus.open(); }
  public close_modal_request_trusted_user_status(): void { this.Modal_RequestTrustedUserStatus.close(); }

  public open_modal_request_edge_databases(): void { this.Modal_RequestEdgeDatabases.open(); }
  public close_modal_request_edge_databases(): void { this.Modal_RequestEdgeDatabases.close(); }

  ngOnInit(): void { }

}
