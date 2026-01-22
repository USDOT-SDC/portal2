import { Component, OnInit } from '@angular/core';
import { ApiService } from 'src/app/services/api.service';

@Component({
    selector: 'app-reset-password',
    templateUrl: './reset-password.component.html',
    styleUrls: ['./reset-password.component.less'],
    standalone: false
})
export class ResetPasswordComponent implements OnInit {

  public is_loading: boolean = false;

  public show_new_password: boolean = false;
  public show_confirm_password: boolean = false;

  public new_password: string | undefined;
  public confirm_password: string | undefined;

  constructor(private api: ApiService) { }

  public submit_reset_password(): void {
    this.is_loading = true;
    const payload: any = { username: '', password: '', new_password: this.new_password, confirm_password: this.confirm_password }
    console.log({ payload });
    const API = this.api.reset_temporary_password(payload.username, payload.password, payload.new_password, payload.confirm_password).subscribe((response) => {
      console.log({ response });
      API.unsubscribe();
      this.reset();
    });

  }

  public reset() {
    this.new_password = undefined;
    this.confirm_password = undefined;
    this.is_loading = false;
  }

  ngOnInit(): void {
  }

}
