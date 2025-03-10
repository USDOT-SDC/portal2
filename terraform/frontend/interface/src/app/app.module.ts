import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing.module';
import { provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';
import { AppComponent } from './app.component';
import { FormsModule } from '@angular/forms';

// Global Components
import { NavbarComponent } from './components/navbar/navbar.component';
import { FooterComponent } from './components/footer/footer.component';
import { ModalComponent } from './components/modal/modal.component';

// Home Pages
import { HomeComponent } from './pages/home/home.component';
import { AboutComponent } from './pages/about/about.component';
import { AboutDatasetsComponent } from './pages/about-datasets/about-datasets.component';
import { LoginComponent } from './pages/login/login.component';
import { FaqComponent } from './pages/faq/faq.component';

// Dashboard Pages
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { WorkstationsComponent } from './pages/dashboard/user-workstations/workstations.component';
import { DatasetsComponent } from './pages/dashboard/user-datasets/datasets.component';
import { DashboardFaqComponent } from './pages/dashboard/dashboard-faq/dashboard-faq.component';

// Utility Pages
import { ErrorComponent } from './pages/error/error.component';
import { FileUploadComponent } from './components/file-upload/file-upload.component';
import { ElemDragAndDropComponent } from './components/file-upload/elem-drag-and-drop/elem-drag-and-drop.component';
import { ElemFileListComponent } from './components/file-upload/elem-file-list/elem-file-list.component';
import { SdcDatasetsComponent } from './pages/dashboard/sdc-datasets/sdc-datasets.component';
import { SdcAlgorithmsComponent } from './pages/dashboard/sdc-algorithms/sdc-algorithms.component';
import { UserRequestCenterComponent } from './pages/dashboard/user-request-center/user-request-center.component';
import { WorkstationComponent } from './components/workstation/workstation.component';
import { UserDatasetComponent } from './components/user-dataset/user-dataset.component';
import { UserApprovalCenterComponent } from './pages/dashboard/user-approval-center/user-approval-center.component';
import { FilterListPipe } from './pipes/filter-list.pipe';
import { LoginSyncComponent } from './pages/login/login-sync/login-sync.component';
import { ResetPasswordComponent } from './pages/login/reset-password/reset-password.component';
import { LoginRedirectComponent } from './pages/login/login-redirect/login-redirect.component';
import { AuthConfigModule } from './auth/auth-config.module';

@NgModule({ declarations: [
        AppComponent,
        NavbarComponent,
        FooterComponent,
        ModalComponent,
        HomeComponent,
        AboutComponent,
        AboutDatasetsComponent,
        LoginComponent,
        FaqComponent,
        DashboardComponent,
        DashboardFaqComponent,
        WorkstationsComponent,
        DatasetsComponent,
        ErrorComponent,
        FileUploadComponent,
        ElemDragAndDropComponent,
        ElemFileListComponent,
        SdcDatasetsComponent,
        SdcAlgorithmsComponent,
        UserRequestCenterComponent,
        WorkstationComponent,
        UserDatasetComponent,
        UserApprovalCenterComponent,
        FilterListPipe,
        LoginSyncComponent,
        ResetPasswordComponent,
        LoginRedirectComponent
    ],
    bootstrap: [AppComponent], imports: [BrowserModule,
        AppRoutingModule,
        FormsModule,
        AuthConfigModule], providers: [provideHttpClient(withInterceptorsFromDi())] })
export class AppModule { }
