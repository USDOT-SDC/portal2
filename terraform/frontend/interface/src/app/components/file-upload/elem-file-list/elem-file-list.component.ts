import { Component, OnInit, Input } from '@angular/core';

@Component({
    selector: 'app-elem-file-list',
    templateUrl: './elem-file-list.component.html',
    styleUrls: ['./elem-file-list.component.less'],
    standalone: false
})
export class ElemFileListComponent implements OnInit {

  @Input() files: any = [];

  constructor() { }

  public remove_file(index: number): void { this.files.splice(index, 1) }

  public formatBytes(bytes: any, decimals = 2) {
    const units = ['bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'];
    let l = 0, n = parseInt(bytes, 10) || 0;
    while (n >= 1024 && ++l) { n = n / 1024; }
    return (n.toFixed(n < 10 && l > 0 ? 1 : 0) + ' ' + units[l]);
  }

  ngOnInit(): void {
  }

}
