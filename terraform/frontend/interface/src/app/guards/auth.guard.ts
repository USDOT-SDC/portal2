import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot, UrlTree } from '@angular/router';
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

  constructor(private router: Router) { }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {
    const logged_in = getCurrentUser().then(() => {
      return true
    }).catch(() => {
      this.router.navigate(['/'])
      return false
    });

    return logged_in;
  }

}
