import { Injectable } from '@angular/core';
import { Amplify } from "aws-amplify";
import { signInWithRedirect, getCurrentUser, fetchAuthSession, signOut } from "aws-amplify/auth";
import { BehaviorSubject } from 'rxjs';
import { environment } from 'src/environments/environment';

const AMPLIFY_CONFIG: any = environment.cognito;

Amplify.configure(AMPLIFY_CONFIG);

@Injectable({ providedIn: 'root' })
export class AuthService {

  public current_user: BehaviorSubject<any> = new BehaviorSubject(undefined);
  public user_info: BehaviorSubject<any> = new BehaviorSubject(undefined);

  constructor() { }

  public async isLoggedIn(): Promise<boolean> {
    try {
      const { username, userId } = await getCurrentUser();
      const { tokens } = await fetchAuthSession();
      this.current_user.next({ username, userId, token: tokens?.idToken?.toString() });
      return true;
    } catch (err) {
      return false;
    }
  }

  public async login(): Promise<void> {
    try {
      const logged_in = await this.isLoggedIn();
      if (logged_in) location.href = '/dashboard';
      else await signInWithRedirect({ provider: { custom: "dev-dot-ad" } });
    } catch (error) {
      console.log('error logging in: ', error);
    }
  }

  public async logout(): Promise<void> {
    try {
      await signOut();
      this.current_user.next(undefined);
    } catch (error) {
      console.log('error logging out: ', error);
    }
  }

}
