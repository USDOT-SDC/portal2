import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';
import { environment } from 'src/environments/environment';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ApiService {

  private BASE_URI: string = `https://${environment.resource_urls.portal_api}`;

  public get auth_header(): HttpHeaders {
    const CurrentUserData = this.auth.current_user.getValue()
    // console.log("[auth_header]: ", CurrentUserData)
    const newHeader = new HttpHeaders({ 'Authorization': `Bearer ${CurrentUserData?.id_token}` })
    // console.log("[auth_header]: ", newHeader.keys(), newHeader.get('Authorization'))
    return newHeader;
  }

  constructor(private http: HttpClient, private auth: AuthService) { }

  public get_user(): Observable<any> { return this.http.get(`${this.BASE_URI}/get_user_info`, { headers: this.auth_header }); }

  public get_instance_types(cpu: number, memory: number, os: string): Observable<any> { return this.http.get(`${this.BASE_URI}/desired_instance_types?cpu=${cpu}&memory=${memory}&os=${os}`, { headers: this.auth_header }); }

  public get_user_uploaded_data(bucket_name: string, user_name: string): Observable<any> { return this.http.get(`${this.BASE_URI}/export_objects?userBucketName=${bucket_name}&username=${user_name}`, { headers: this.auth_header }); }

  public get_s3_object_metadata(bucket_name: string, file_name: string): Observable<any> { return this.http.get(`${this.BASE_URI}/s3_metadata?bucket_name=${bucket_name}&file_name=${file_name}`, { headers: this.auth_header }); }

  public get_s3_upload_url(bucket_name: string, file_name: string, file_type: string): Observable<any> { return this.http.get(`${this.BASE_URI}/presigned_url?bucket_name=${bucket_name}&file_name=${file_name}&file_type=${file_type}`, { headers: this.auth_header }); }

  public upload_file_to_s3(presigned_url: string, file: any, file_type: string): Observable<any> { return this.http.put(presigned_url, file, { headers: { 'Content-Type': file_type } }); }

  public set_s3_object_as_confidential(): Observable<any> { return this.http.get(`${this.BASE_URI}`); } // Does Not Exist yet

  public get_export_request_approval_list(user_email: string): Observable<any> { return this.http.post(`${this.BASE_URI}/export_request`, { message: JSON.stringify({ ApprovalForm: { email: user_email } }) }, { headers: this.auth_header }); }

  public workstation_action(id: string, action: string): Observable<any> { return this.http.get(`${this.BASE_URI}/perform_instance_action?instance_id=${id}&action=${action}`, { headers: this.auth_header }); }

  public workstation_status(id: string): Observable<any> { return this.http.get(`${this.BASE_URI}/instance_status?instance_id=${id}`, { headers: this.auth_header }); }

  public send_resize_instance_request(user: { username: string, user_email: string }, workstation: { instance_type: string, instance_id: string, operating_system: string }, instance_params: { requested_instance_type: string, cpu: number, ram: number, start_after_resize: boolean }): Observable<any> {
    const payload: any = { manageWorkstation: true, username: user.username, user_email: user.user_email, default_instance_type: workstation.instance_type, instance_id: workstation.instance_id, operating_system: workstation.operating_system, startAfterResize: instance_params.start_after_resize, requested_instance_type: instance_params.requested_instance_type, vcpu: instance_params.cpu, memory: instance_params.ram, workstation_schedule_from_date: new Date(), workstation_schedule_to_date: null, };
    return this.http.get(`${this.BASE_URI}/manage_workstation_size?wsrequest=${JSON.stringify(payload)}`, { headers: this.auth_header });
  }

  public send_email_request(sender: string, message: any): Observable<any> { return this.http.get(`${this.BASE_URI}/send_email?sender=${sender}&message=${JSON.stringify(message)}`, { headers: this.auth_header }); }

  public send_export_table_request(message: any): Observable<any> { return this.http.post(`${this.BASE_URI}/export_table`, { message: JSON.stringify(message) }, { headers: this.auth_header }); }

  public send_trusted_user_request(message: any): Observable<any> { return this.http.post(`${this.BASE_URI}/request_export`, { message: JSON.stringify(message) }, { headers: this.auth_header }); }

  /* ================== :: =============== :: ================== */
  /* ================== :: APPROVAL CENTER :: ================== */

  public send_update_export_table_status(message: any): Observable<any> { return this.http.post(`${this.BASE_URI}/update_autoexport_status`, { message: JSON.stringify(message) }, { headers: this.auth_header }); }

  public send_update_trusted_status(message: any): Observable<any> { return this.http.post(`${this.BASE_URI}/update_trusted_status`, { message: JSON.stringify(message) }, { headers: this.auth_header }); }

  public send_update_file_status(message: any): Observable<any> { return this.http.post(`${this.BASE_URI}/update_file_status`, { message: JSON.stringify(message) }, { headers: this.auth_header }); }

  /* ================== :: APPROVAL CENTER :: ================== */
  /* ================== :: =============== :: ================== */


  /* ================== :: =================== :: ================== */
  /* ================== :: LOGIN SYNC SERVICES :: ================== */

  // Headers specific for Login Sync (No Bearer Auth Token)
  public get login_sync_headers(): HttpHeaders { return new HttpHeaders({ 'Authorization': this.auth.current_user.getValue().token }); }

  // Verify if Account is Linked
  public verify_account_linked(token: any): Observable<any> {
    return this.http.get(`${this.BASE_URI}/account_linked`, { headers: new HttpHeaders({ 'Authorization': token }) })
  }
  // Link an Account
  public link_an_account(username: string, password: string): Observable<any> {
    return this.http.post(`${this.BASE_URI}/link_account`, { username, password }, { headers: this.login_sync_headers })
  }
  // Reset a Users Temporary Password
  public reset_temporary_password(username: string, password: string, new_password: string, new_password_confirmation: string): Observable<any> {
    return this.http.post(`${this.BASE_URI}/reset_temporary_password`, { username: username, currentPassword: password, newPassword: new_password, newPasswordConfirmation: new_password_confirmation, }, { headers: this.login_sync_headers })
  }
  /* ================== :: LOGIN SYNC SERVICES :: ================== */
  /* ================== :: =================== :: ================== */
}
