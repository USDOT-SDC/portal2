import { Component, ElementRef, Input, ViewChild } from '@angular/core';

/**
 * ## MODAL COMPONENT
 * 
 * --- 
 * 
 * ### USAGE
 * 
 * Imagine we want to add the modal to our About Page. 
 * 
 * This is what our page looks like on our project. 
 * 
 * | root    | files                  |
 * |---------|------------------------|
 * | ./about |                        |
 * |         | ./about.component.html |
 * |         | ./about.component.less |
 * |         | ./about.component.ts   |    
 *    
 * #### Adding the Modal to your Page
 * 
 * * Add `<app-modal></app-modal>` anywhere on your page
 * * In order to interact with a modal you must give it an ID: `<app-modal #MyModalOne ></app-modal>`
 *    * Note: If you want to have multiple Modals on a page, each modal must have a unique ID.
 * * Define the Modal Element in the Component TS:
 *    1) Add `ViewChild` to imports at the top of the component: 
 * 
 *    `import { Component, ElementRef, Input, ViewChild } from '@angular/core';`
 * 
 *    2) Define the Modal in your component: 
 * 
 *    `@ViewChild('MyModalOne', { static: false }) MyModalOne: ElementRef | any;`
 * 
 *    * Note: For multiple Modal you will need to define a `ViewChild` for each individual Modal on your Page.
 * * On your HTML we will add three elements
 *    1) Modal Header: 
 *    
 *    `<ng-container modal-header> <!-- Custom HEADER Content Goes Here... --> </ng-container>`
 *    
 *    2) Modal Body: 
 * 
 *    `<ng-container modal-body> <!-- Custom BODY Content Goes Here... --> </ng-container>`
 *    
 *    3) Modal Footer: 
 * 
 *    `<ng-container modal-footer> <!-- Custom FOOTER Content Goes Here... --> </ng-container>`
 * 
 * #### Opening and Closing the Modal
 * 
 * Normally I would set up Two functions per Modal on my Page: `modal_open()` and `modal_close()`
 * 
 * **EXAMPLE: Open Modal Function**
 * 
 * `public modal_open(): void { this.MyModalOne.open(); }`
 * 
 * **EXAMPLE: Close Modal Function**
 * 
 * `public modal_close(): void { this.MyModalOne.close(); }`
 * 
 */
export interface ModalComponent {
  /**
   * @name size
   * @type String<'bottom' | 'sm' | 'md' | 'lg'>
   * @description The Size of the Modal Element to Render
   */
  size: 'bottom' | 'sm' | 'md' | 'lg';

  /**
   * @name ModalWrapper
   * @type ElementRef | any
   * @description The Modal Element Rendered on the Page.
   */
  ModalWrapper: ElementRef | any;

  /**
   * @name open
   * @description Toggles the Modal to Open
   */
  open(): void;

  /**
   * @name close
   * @description Toggles the Modal to Close
   */
  close(): void;

  /** 
   * @name resize
   * @description Resizes the Modal
   * @param size 
   */
  resize(size: 'bottom' | 'sm' | 'md' | 'lg'): void;
}

@Component({
  selector: 'app-modal',
  templateUrl: './modal.component.html',
  styleUrls: ['./modal.component.less']
})
export class ModalComponent {

  @Input() size: 'bottom' | 'sm' | 'md' | 'lg' = 'md';

  @ViewChild('ModalWrapper', { static: false }) ModalWrapper: ElementRef | any;

  public open(): void { this.ModalWrapper.nativeElement.style.display = 'flex'; }

  public close(): void { this.ModalWrapper.nativeElement.style.display = 'none'; }

  public resize(size: 'bottom' | 'sm' | 'md' | 'lg'): void { this.size = size; }

}
