import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserRequestCenterComponent } from './user-request-center.component';

describe('UserRequestCenterComponent', () => {
  let component: UserRequestCenterComponent;
  let fixture: ComponentFixture<UserRequestCenterComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ UserRequestCenterComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(UserRequestCenterComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
