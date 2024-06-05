import { AfterViewInit, Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/services/auth.service';

declare var bootstrap: any;

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.less']
})
export class DashboardComponent implements OnInit, AfterViewInit {

  public current_user: any;

  constructor(private auth: AuthService) { }

  ngOnInit(): void {
    this.auth.current_user.subscribe((user: any) => {
      console.log(user)
      this.current_user = user;
    })

  }

  ngAfterViewInit(): void {
    const tooltipTriggerList: any = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
    console.log(tooltipList);
  }
}
