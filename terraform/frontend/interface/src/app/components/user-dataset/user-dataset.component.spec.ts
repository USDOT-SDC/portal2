import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserDatasetComponent } from './user-dataset.component';

describe('UserDatasetComponent', () => {
  let component: UserDatasetComponent;
  let fixture: ComponentFixture<UserDatasetComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ UserDatasetComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(UserDatasetComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
