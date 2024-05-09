import { Component, Input, OnInit } from '@angular/core';

@Component({
  selector: 'app-elem-drag-and-drop',
  templateUrl: './elem-drag-and-drop.component.html',
  styleUrls: ['./elem-drag-and-drop.component.less']
})
export class ElemDragAndDropComponent implements OnInit {

  @Input() files: any = [];
  @Input() single_file: boolean = false;
  @Input() mini_loader: boolean = false;

  public deny_file_types: Array<string> = ['application/vnd.rar', 'application/x-rar-compressed', 'application/octet-stream', 'application/zip', 'application/octet-stream', 'application/x-zip-compressed', 'multipart/x-zip'];
  public accept_file_types: string = "audio/*, video/*, image/*, application/msword, application/vnd.ms-excel, application/vnd.ms-powerpoint, text/plain, application/pdf, .xls, .xlsx, .dotx, .dot, .docx, .doc, .pptx, .ppt, .rtf, .pub"

  constructor() { }

  public add_files(event: any) {

    const files: Array<any> = [...event.target.files];

    for (const item of files) {
      if (this.deny_file_types.includes(item.type)) { console.info(`Invalid File Type: ${item.type}`); return; }

      var file = { file_name: item.name, file_size: item.size, file_type: item.type, file_thumb: null };

      const reader = new FileReader();
      reader.onload = function (event: any) { file.file_thumb = event.target.result; };
      if (item && item.type.startsWith('image/')) reader.readAsDataURL(item);

      this.files.push(file);
    }

    console.log(this.files)
  }

  ngOnInit(): void {
  }

}
