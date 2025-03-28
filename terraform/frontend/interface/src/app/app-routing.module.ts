import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

// ROUTE GUARDS
import { AuthGuard } from './guards/auth.guard';

// HOME PAGE COMPONENTS
import { HomeComponent } from './pages/home/home.component';
import { AboutComponent } from './pages/about/about.component';
import { LoginComponent } from './pages/login/login.component';
import { FaqComponent } from './pages/faq/faq.component';

// DASHBOARD COMPONENTS
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { ErrorComponent } from './pages/error/error.component';
import { AboutDatasetsComponent } from './pages/about-datasets/about-datasets.component';
import { DashboardFaqComponent } from './pages/dashboard/dashboard-faq/dashboard-faq.component';
import { LoginSyncComponent } from './pages/login/login-sync/login-sync.component';
import { ResetPasswordComponent } from './pages/login/reset-password/reset-password.component';
import { LoginRedirectComponent } from './pages/login/login-redirect/login-redirect.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'dashboard', /* canActivate: [AuthGuard], */ component: DashboardComponent },
  { path: 'dashboard/faqs', /* canActivate: [AuthGuard], */ component: DashboardFaqComponent },
  { path: 'about', component: AboutComponent },
  { path: 'datasets', component: AboutDatasetsComponent },

  { path: 'login', component: LoginComponent },
  { path: 'login:access_token', component: LoginComponent },
  { path: 'login/sync', component: LoginSyncComponent },
  { path: 'login/reset', component: ResetPasswordComponent },
  { path: 'login/redirect', component: LoginRedirectComponent },

  { path: 'faqs', component: FaqComponent },
  { path: '**', component: ErrorComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
