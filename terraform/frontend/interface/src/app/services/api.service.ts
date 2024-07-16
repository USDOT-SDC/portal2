import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  private BASE_URI: string = `https://${environment.resource_urls.portal_api}`;

  constructor(private http: HttpClient, private auth: AuthService) { }

  public get auth_header(): HttpHeaders {
    const { token } = this.auth.current_user.getValue();
    // { 'content-type': 'application/json', 'authorization': `Bearer ${token}` };
    return new HttpHeaders({ 'authorization': `Bearer ${token}` })
  }

  public get_user(): Observable<any> { return this.http.get(`${this.BASE_URI}/get_user_info`, { headers: this.auth_header }); }

  public workstation_action(id: string, action: string): Observable<any> { return this.http.get(`${this.BASE_URI}/perform_instance_action?instance_id=${id}&action=${action}`, { headers: this.auth_header }); }

  public workstation_status(id: string): Observable<any> { return this.http.get(`${this.BASE_URI}/instance_status?instance_id=${id}`, { headers: this.auth_header }); }

  public workstation_launch(stack: string) { }

}
