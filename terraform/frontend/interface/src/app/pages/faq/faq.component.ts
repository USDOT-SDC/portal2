import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-faq',
  templateUrl: './faq.component.html',
  styleUrls: ['./faq.component.less']
})
export class FaqComponent implements OnInit {

  public all_expanded: boolean = false;

  constructor() { }

  public toggle_collapse_all(): void {
    this.all_expanded = !this.all_expanded;
    const collapsable: any = document.querySelectorAll('.collapse');
    const collapsable_elements: Array<HTMLElement> = [...collapsable];
    collapsable_elements.forEach((element: HTMLElement): void => {
      if (this.all_expanded == true) element.classList.remove('show');
      else element.classList.add('show');
    });
  }

  ngOnInit(): void {
  }

}
