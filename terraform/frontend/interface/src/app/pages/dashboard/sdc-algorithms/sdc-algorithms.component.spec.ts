import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SdcAlgorithmsComponent } from './sdc-algorithms.component';

describe('SdcAlgorithmsComponent', () => {
  let component: SdcAlgorithmsComponent;
  let fixture: ComponentFixture<SdcAlgorithmsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ SdcAlgorithmsComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SdcAlgorithmsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
