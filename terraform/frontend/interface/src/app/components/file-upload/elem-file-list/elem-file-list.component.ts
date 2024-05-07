import { Component, OnInit, Input } from '@angular/core';

@Component({
  selector: 'app-elem-file-list',
  templateUrl: './elem-file-list.component.html',
  styleUrls: ['./elem-file-list.component.less']
})
export class ElemFileListComponent implements OnInit {

  @Input() files: any = [];

  constructor() { }

  public remove_file(index: number): void { this.files.splice(index, 1) }

  public formatBytes(bytes: number, decimals = 2) {
    if (bytes === 0) return '0 KB';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    const formattedBytes = parseFloat((bytes / Math.pow(k, i)).toFixed(dm));
    return formattedBytes + ' ' + sizes[i];
  }

  ngOnInit(): void {
  }

}
