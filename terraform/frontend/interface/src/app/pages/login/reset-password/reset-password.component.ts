import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-reset-password',
  templateUrl: './reset-password.component.html',
  styleUrls: ['./reset-password.component.less']
})
export class ResetPasswordComponent implements OnInit {

  public is_loading: boolean = false;

  public show_new_password: boolean = false;
  public show_confirm_password: boolean = false;

  public new_password: string | undefined;
  public confirm_password: string | undefined;

  constructor() { }

  public submit_reset_password(): void {
    const payload = { new_password: this.new_password, confirm_password: this.confirm_password }
    console.log({ payload });

    /// API CALL.....
    setTimeout(() => {
      console.log({ response: "Dummy API call: Success" });
      this.reset();
    }, 1000)
  }

  public reset() {
    this.new_password = undefined;
    this.confirm_password = undefined;
    this.is_loading = false;
  }

  ngOnInit(): void {
  }

}
