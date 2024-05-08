import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-file-upload',
  templateUrl: './file-upload.component.html',
  styleUrls: ['./file-upload.component.less']
})
export class FileUploadComponent implements OnInit {

  public files_to_upload: Array<any> = [];

  constructor() { }

  ngOnInit(): void {
  }

}
