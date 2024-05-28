import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SdcDatasetsComponent } from './sdc-datasets.component';

describe('SdcDatasetsComponent', () => {
  let component: SdcDatasetsComponent;
  let fixture: ComponentFixture<SdcDatasetsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ SdcDatasetsComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SdcDatasetsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
