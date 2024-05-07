import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

// HOME PAGE COMPONENTS
import { HomeComponent } from './pages/home/home.component';
import { AboutComponent } from './pages/about/about.component';
import { LoginComponent } from './pages/login/login.component';
import { FaqComponent } from './pages/faq/faq.component';

// DASHBOARD COMPONENTS
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { DatasetsComponent } from './pages/dashboard/datasets/datasets.component';
import { WorkstationsComponent } from './pages/dashboard/workstations/workstations.component';

import { ErrorComponent } from './pages/error/error.component';
import { AboutDatasetsComponent } from './pages/about-datasets/about-datasets.component';
import { DashboardFaqComponent } from './pages/dashboard/dashboard-faq/dashboard-faq.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'about', component: AboutComponent },
  { path: 'datasets', component: AboutDatasetsComponent },
  { path: 'login', component: LoginComponent },
  { path: 'faqs', component: FaqComponent },
  {
    path: 'dashboard',
    component: DashboardComponent,
    children: [
      { path: 'datasets', component: DatasetsComponent },
      { path: 'workstations', component: WorkstationsComponent },
      { path: 'faqs', component: DashboardFaqComponent },
    ]
  },
  { path: '**', component: ErrorComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
