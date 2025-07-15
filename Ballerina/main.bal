import ResourceHub.database;
import ResourceHub.user;
import ResourceHub.asset;
import ResourceHub.meal;
import ResourceHub.dashboard;
import ResourceHub.maintenance;
import ResourceHub.notification;
import ResourceHub.auth;
import ResourceHub.organizations;
import ResourceHub.report;
import ballerinax/mysql.driver as _;

public function main() returns error? {
    check database:connectDatabase();
    check auth:startAuthService();
    check meal:startMealTypeService();
    check meal:startMealTimeService();
    check meal:startCalendarService();
    check asset:startAssetService();
    check asset:startAssetRequestService();
    check user:startUserManagementService();
    check user:startAccountSettingsService();
    check maintenance:startMaintenanceManagementService();
    check notification:startNotificationService();
    check dashboard:startDashboardAdminService();
    check dashboard:startDashboardUserService();
    check organizations:startOrganizationSettingsService();
    check report:startReportDetailsService();
    // check report:scheduled();
}
