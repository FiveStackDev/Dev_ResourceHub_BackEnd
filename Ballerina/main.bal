import ResourceHub.database;
import ResourceHub.user;
import ResourceHub.asset;
import ResourceHub.meal;
import ResourceHub.dashboard;
import ResourceHub.maintenance;
import ballerinax/mysql.driver as _;
// import ResourceHub.report;

public function main() returns error? {
    check database:connectDatabase();
    check meal:startMealTypeService();
    check meal:startMealTimeService();
    check meal:startCalendarService();
    check asset:startAssetService();
    check user:startUserManagementService();
    check maintenance:startMaintenanceManagementService();
    check dashboard:startDashboardAdminService();
    check dashboard:startDashboardUserService();
    // check report:scheduled();
}