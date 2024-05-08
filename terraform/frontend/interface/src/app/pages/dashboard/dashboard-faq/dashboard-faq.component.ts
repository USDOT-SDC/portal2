import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-dashboard-faq',
  templateUrl: './dashboard-faq.component.html',
  styleUrls: ['./dashboard-faq.component.less']
})
export class DashboardFaqComponent implements OnInit {

  public all_expanded: boolean = false;

  /**
   * Toggles to open a Bootstrap Collapse Element, while collapsing all others
   * @param id The ID of the Element you wish to open
   */
  public toggle_collapse(id: string): void {

    // Generate Collapse ID from Incoming ID
    const collapse_id: string = id.replace("#", "") + '-collapse';

    // Query All Collapse Elements on Page. 
    const collapsable: any = document.querySelectorAll('.collapse');
    const collapsable_elements: Array<HTMLElement> = [...collapsable];

    // Loop over all the Collapse Elements, and run logic on them
    collapsable_elements.forEach((element: HTMLElement): void => {

      // if collapse_id matches element.id, show collapse 
      if (collapse_id == element.id) { element.classList.add('show'); }

      // if not, hide collapse 
      else { element.classList.remove('show'); }

    });
  }

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
    // Check if URL has Hashed Parameter
    if (location.hash)
      // If True, Toggle the Collapse that belongs to the Hash Parameter
      this.toggle_collapse(location.hash);
  }

}
