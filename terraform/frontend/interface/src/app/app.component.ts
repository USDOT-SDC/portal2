import { Component } from '@angular/core';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.less']
})
export class AppComponent {

  title = 'interface';
  stage: string = environment.stage;
  version: string = environment.build;
  buildDateTime = environment.buildDateTime;

}
