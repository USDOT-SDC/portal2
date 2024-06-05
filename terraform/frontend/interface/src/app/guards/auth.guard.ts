import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, RouterStateSnapshot, UrlTree } from '@angular/router';
import { Amplify } from "aws-amplify";
import { signInWithRedirect, getCurrentUser, signOut } from "aws-amplify/auth";
import { environment } from 'src/environments/environment';

import { Observable } from 'rxjs';

const AMPLIFY_CONFIG: any = environment.cognito;
Amplify.configure(AMPLIFY_CONFIG);


@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {
    const logged_in = getCurrentUser().then(() => true).catch(() => false);
    return logged_in;
  }

}
