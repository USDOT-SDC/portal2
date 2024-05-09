import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ElemFileListComponent } from './elem-file-list.component';

describe('ElemFileListComponent', () => {
  let component: ElemFileListComponent;
  let fixture: ComponentFixture<ElemFileListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ElemFileListComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ElemFileListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
