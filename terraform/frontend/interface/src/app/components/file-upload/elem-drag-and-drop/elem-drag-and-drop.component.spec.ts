import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ElemDragAndDropComponent } from './elem-drag-and-drop.component';

describe('ElemDragAndDropComponent', () => {
  let component: ElemDragAndDropComponent;
  let fixture: ComponentFixture<ElemDragAndDropComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ElemDragAndDropComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ElemDragAndDropComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
