import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserApprovalCenterComponent } from './user-approval-center.component';

describe('UserApprovalCenterComponent', () => {
  let component: UserApprovalCenterComponent;
  let fixture: ComponentFixture<UserApprovalCenterComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ UserApprovalCenterComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(UserApprovalCenterComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
