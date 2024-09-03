import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LoginSyncComponent } from './login-sync.component';

describe('LoginSyncComponent', () => {
  let component: LoginSyncComponent;
  let fixture: ComponentFixture<LoginSyncComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ LoginSyncComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LoginSyncComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
