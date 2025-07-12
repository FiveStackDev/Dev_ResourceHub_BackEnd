import ResourceHub.resourcehubservices as resourcehubservices;
import ballerinax/mysql.driver as _;

public function main() returns error? {
    check resourcehubservices:connectDatabase();
    check resourcehubservices:startMealTypeService();
    check resourcehubservices:startMealTimeService();
    check resourcehubservices:startCalendarService();
    check resourcehubservices:startAssetService();
    check resourcehubservices:startUserManagementService();
    check resourcehubservices:startMaintenanceManagementService();
    check resourcehubservices:startDashboardAdminService();
    check resourcehubservices:startDashboardUserService();
    // check resourcehubservices:scheduled();
}