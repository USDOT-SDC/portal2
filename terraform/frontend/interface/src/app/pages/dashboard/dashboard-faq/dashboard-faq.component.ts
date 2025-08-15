import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, NavigationStart } from '@angular/router';
import { ModalComponent } from 'src/app/components/modal/modal.component';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'app-dashboard-faq',
  templateUrl: './dashboard-faq.component.html',
  styleUrls: ['./dashboard-faq.component.less']
})
export class DashboardFaqComponent implements OnInit {

  @ViewChild('AuthWarningModal') AuthWarningModal: ModalComponent | any;
  @ViewChild('AuthExpirationModal') AuthExpirationModal: ModalComponent | any;

  constructor(private auth: AuthService, private router: Router) { }

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

  private warning_modal_open(): void {
    this.AuthWarningModal.open();
  }

  private expiration_modal_open(): void {
    this.AuthExpirationModal.open();
  }

  private inactivityTimer() {
    let sessionTimer: any;
    let warningTimer: any;
    let sessionStart: number;
    // const sessionTimeout = 1800000; // 30 minutes in milliseconds
    const sessionTimeout = 60000; // one minute in milliseconds
    // const warningTime = 1680000; // 28 minutes in milliseconds
    const warningTime = 40000; // forty seconds in milliseconds

    const isSessionExpired = () => {
      return Date.now() - sessionStart > sessionTimeout;
    };

    const startSessionTimer = () => {
      sessionTimer = setTimeout(() => {
        this.auth.logout();
        this.expiration_modal_open();
      }, sessionTimeout);
    };

    const showWarningAlert = () => {
      warningTimer = setTimeout(() => {
        this.warning_modal_open();

        // if (isSessionExpired()) {
        //   this.refreshPage();
        // }
      }, warningTime);
    };

    const resetTimers = () => {
      clearTimeout(sessionTimer);
      clearTimeout(warningTimer);
      startSessionTimer();
      showWarningAlert();
    };

    sessionStart = Date.now();
    startSessionTimer();
    showWarningAlert();

    this.router.events.subscribe((event) => {
      if (event instanceof NavigationStart) {
        resetTimers();
      }
    });
  }

  refreshPage() {
    window.location.reload(); // Refresh the page
  }

  ngOnInit(): void {
    
    const body = document.body;
    const theme = localStorage.getItem('sdc_ui_theme');
    console.log({ theme })

    this.inactivityTimer();
    if (theme) body.dataset['bsTheme'] = theme;


    // Check if URL has Hashed Parameter
    if (location.hash)
      // If True, Toggle the Collapse that belongs to the Hash Parameter
      this.toggle_collapse(location.hash);
  }

}
