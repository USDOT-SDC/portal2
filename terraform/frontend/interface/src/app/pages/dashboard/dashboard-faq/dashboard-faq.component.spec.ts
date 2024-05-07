import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DashboardFaqComponent } from './dashboard-faq.component';

describe('DashboardFaqComponent', () => {
  let component: DashboardFaqComponent;
  let fixture: ComponentFixture<DashboardFaqComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ DashboardFaqComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DashboardFaqComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
