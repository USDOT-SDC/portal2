import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { Subscription } from 'rxjs';
import { ApiService } from 'src/app/services/api.service';

@Component({
  selector: 'app-user-dataset',
  templateUrl: './user-dataset.component.html',
  styleUrls: ['./user-dataset.component.less']
})
export class UserDatasetComponent implements OnInit {

  @Input() location: any;
  @Input() dataset: any;

  @Output() emit_action: EventEmitter<any> = new EventEmitter(undefined);

  public is_loading: boolean = false;
  public meta_data: { "publish": boolean; "download": boolean; "export": boolean; "requestReviewStatus": string; } | any;

  constructor(private api: ApiService) { }

  public checkbox_selected(): void {
    this.dataset.selected = !this.dataset.selected;
    this.emit_action.emit({ action: 'selected', data: this.dataset })
  }

  public toggle_export_request(): void { this.emit_action.emit({ action: 'export', data: this.dataset }) }

  ngOnInit(): void {
    this.is_loading = true;
    const init_api: Subscription = this.api.get_s3_object_metadata(this.location, this.dataset.filename).subscribe((response: any) => {
      this.is_loading = false;
      this.meta_data = response;
      this.dataset.status = this.meta_data.requestReviewStatus == "-1" ? 'Denied' : this.meta_data.requestReviewStatus;
      // console.log(this);
      init_api.unsubscribe();
    })
  }

}
