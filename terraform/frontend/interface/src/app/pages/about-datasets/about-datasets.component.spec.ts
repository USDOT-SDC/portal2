import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AboutDatasetsComponent } from './about-datasets.component';

describe('AboutDatasetsComponent', () => {
  let component: AboutDatasetsComponent;
  let fixture: ComponentFixture<AboutDatasetsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ AboutDatasetsComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AboutDatasetsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
