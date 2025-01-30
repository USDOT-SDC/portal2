import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, Router, RouterStateSnapshot } from '@angular/router';
import { OidcSecurityService } from 'angular-auth-oidc-client';
import { Observable, map, take } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard  {

  constructor(private router: Router, private OICD_Auth: OidcSecurityService) { }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): any {
    return this.OICD_Auth.isAuthenticated$.pipe(take(1), map(({ isAuthenticated }) => {
      // allow navigation if authenticated
      if (isAuthenticated) { return true; }
      // redirect if not authenticated
      return this.router.parseUrl('/');
    }));

  }

}
