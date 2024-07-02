import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  private BASE_URI: string = `https://hdvvw7yfy4.execute-api.us-east-1.amazonaws.com/v1/`;

  constructor(private http: HttpClient, private auth: AuthService) { }

  public get auth_header(): HttpHeaders {
    const { token } = this.auth.current_user.getValue();
    // { 'content-type': 'application/json', 'authorization': `Bearer ${token}` };
    return new HttpHeaders({ 'Content-Type': 'application/json', 'authorization': `Bearer ${token}` })
  }

  public get_user() {
    const new_headers = this.auth_header;
    console.log("MY HEADERS: ", new_headers);
    return this.http.get(this.BASE_URI + "get_user_info", { headers: new_headers });
  }


}
