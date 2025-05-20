import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-footer',
  templateUrl: './footer.component.html',
  styleUrls: ['./footer.component.less']
})
export class FooterComponent implements OnInit {

  public organization: string = 'U.S. Department of Transportation';
  public address: string = "1200 New Jersey Avenue SE";
  public location: string = "Washington, DC 20590";
  public phone: string = "855-368-4200";

  public footer_links: Array<any> = [
    { title: 'Privacy Policy', url: 'https://www.fhwa.dot.gov/privacy.cfm' },
    { title: 'Freedom of Information Act (FOIA)', url: 'https://www.fhwa.dot.gov/foia/' },
    { title: 'Accessibility', url: 'https://www.fhwa.dot.gov/accessibility/' },
    { title: 'Web Policies & Notices', url: 'https://www.fhwa.dot.gov/webpolicies/publishschedule.cfm' },
    { title: 'No Fear Act', url: 'https://www.transportation.gov/civil-rights/civil-rights-awareness-enforcement/no-fear-act' },
    { title: 'Report Waste, Fraud and Abuse', url: 'https://www.oig.dot.gov/Hotline' },
    { title: 'U.S. DOT Home', url: 'https://www.transportation.gov/' },
    { title: 'USA.gov', url: 'https://www.usa.gov/' },
    { title: 'WhiteHouse.gov', url: 'https://www.whitehouse.gov/' }
  ];

  constructor() { }

  ngOnInit(): void {
  }

}
