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

  public get_instance_types(cpu: number, memory: number, os: string): Observable<any> { return this.http.get(`${this.BASE_URI}/desired_instance_types?cpu=${cpu}&memory=${memory}&os=${os}`, { headers: this.auth_header }); }

  public workstation_action(id: string, action: string): Observable<any> { return this.http.get(`${this.BASE_URI}/perform_instance_action?instance_id=${id}&action=${action}`, { headers: this.auth_header }); }

  public workstation_status(id: string): Observable<any> { return this.http.get(`${this.BASE_URI}/instance_status?instance_id=${id}`, { headers: this.auth_header }); }

  public send_resize_instance_request(user: { username: string, user_email: string }, workstation: { instance_type: string, instance_id: string, operating_system: string }, instance_params: { requested_instance_type: string, cpu: number, ram: number, start_after_resize: boolean }): Observable<any> { const payload: any = { manageWorkstation: true, username: user.username, user_email: user.user_email, default_instance_type: workstation.instance_type, instance_id: workstation.instance_id, operating_system: workstation.operating_system, startAfterResize: instance_params.start_after_resize, requested_instance_type: instance_params.requested_instance_type, vcpu: instance_params.cpu, memory: instance_params.ram, workstation_schedule_from_date: new Date(), workstation_schedule_to_date: null, }; return this.http.get(`${this.BASE_URI}/manage_workstation_size?wsrequest=${JSON.stringify(payload)}`); }

  public send_email_request(sender: string, message: any): Observable<any> { return this.http.get(`${this.BASE_URI}/send_email?sender=${sender}&message=${JSON.stringify(message)}`); }

  public send_export_table_request(message: any): Observable<any> { return this.http.get(`${this.BASE_URI}/portal2_export_table&message=${JSON.stringify(message)}`); }

  public send_trusted_user_request(message: any): Observable<any> { return this.http.get(`${this.BASE_URI}/portal2_export_table&message=${JSON.stringify(message)}`); }
}
