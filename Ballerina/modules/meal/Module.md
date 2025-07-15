# Meal Module

Comprehensive meal management system for planning, scheduling, and tracking organizational meal services in ResourceHub.

## 🍽️ Overview

This module provides complete meal management functionality including meal type management, time slot configuration, calendar planning, and request handling for organizational dining services.

## ✨ Features

### Meal Type Management
- **Meal Type CRUD**: Create, read, update, and delete meal types
- **Category Management**: Organize meals by breakfast, lunch, dinner, snacks
- **Image Management**: Store and manage meal type images
- **Menu Planning**: Structure meal offerings and options

### Meal Time Management
- **Time Slot Configuration**: Define meal serving times and schedules
- **Scheduling**: Manage when different meal types are available
- **Time-based Restrictions**: Control meal availability by time slots

### Meal Calendar System
- **Calendar Planning**: View and manage meal schedules across dates
- **Event Tracking**: Track meal requests and reservations
- **User-Specific Views**: Personal meal calendars for individual users
- **Organization-wide Planning**: Admin view of all meal activities

### Meal Request System
- **Request Submission**: Users can request specific meals for dates
- **Calendar Integration**: Requests appear in calendar views
- **Tracking**: Monitor meal request status and fulfillment

## 🛠️ API Endpoints

### Meal Type Service (`/mealtype`)

#### GET `/mealtype/details`
Retrieves all available meal types.

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
[
  {
    "mealtype_id": 1,
    "mealtype_name": "Grilled Chicken",
    "mealtype_image_url": "https://example.com/chicken.jpg"
  },
  {
    "mealtype_id": 2,
    "mealtype_name": "Vegetarian Pasta",
    "mealtype_image_url": "https://example.com/pasta.jpg"
  }
]
```

#### POST `/mealtype/add`
Adds a new meal type (Admin/SuperAdmin only).

**Request Body:**
```json
{
  "mealtype_name": "Caesar Salad",
  "mealtype_image_url": "https://example.com/salad.jpg"
}
```

#### PUT `/mealtype/update/{mealtypeId}`
Updates existing meal type information.

#### DELETE `/mealtype/delete/{mealtypeId}`
Removes a meal type (Admin only).

### Meal Time Service (`/mealtime`)

#### GET `/mealtime/details`
Retrieves all meal time slots.

**Response:**
```json
[
  {
    "mealtime_id": 1,
    "mealtime_name": "Breakfast",
    "start_time": "07:00",
    "end_time": "09:00"
  },
  {
    "mealtime_id": 2,
    "mealtime_name": "Lunch",
    "start_time": "12:00",
    "end_time": "14:00"
  }
]
```

#### POST `/mealtime/add`
Adds a new meal time slot (Admin only).

### Meal Calendar Service (`/calendar`)

#### GET `/calendar/mealevents`
Retrieves all meal events across the organization (Admin view).

**Response:**
```json
[
  {
    "requestedmeal_id": 1,
    "mealtime_id": 2,
    "mealtype_id": 5,
    "mealtype_name": "Grilled Chicken",
    "mealtime_name": "Lunch",
    "username": "john_doe",
    "user_id": 123,
    "submitted_date": "2024-01-10",
    "meal_request_date": "2024-01-15"
  }
]
```

#### GET `/calendar/mealevents/{userid}`
Retrieves meal events for a specific user.

#### POST `/calendar/request`
Submits a new meal request.

**Request Body:**
```json
{
  "user_id": 123,
  "mealtime_id": 2,
  "mealtype_id": 5,
  "meal_request_date": "2024-01-20",
  "submitted_date": "2024-01-15"
}
```

## 🏗️ Data Models

### MealType Record
```ballerina
public type MealType record {|
    int mealtype_id?;
    string mealtype_name;
    string mealtype_image_url;
|};
```

### MealEvent Record
```ballerina
public type MealEvent record {|
    int requestedmeal_id?;
    int mealtime_id;
    int mealtype_id;
    string mealtype_name?;
    string mealtime_name?;
    string username?;
    int user_id;
    string submitted_date;
    string meal_request_date;
|};
```

## 🔒 Security & Authorization

### Role-Based Access
- **Admin/SuperAdmin**: Full meal management, type creation, and time configuration
- **User**: View meal options, submit requests, and view personal calendar
- **Manager**: Enhanced access to meal planning and user requests

### Security Features
- JWT token validation for all operations
- Role-based endpoint protection
- User-specific data filtering
- Request ownership validation

## 📅 Meal Planning Features

### Calendar Integration
- **Daily View**: See all meals planned for specific dates
- **Weekly/Monthly Planning**: Extended calendar views
- **User Filtering**: Filter by specific users or departments
- **Meal Type Filtering**: Filter by breakfast, lunch, dinner

### Request Management
- **Advanced Scheduling**: Request meals in advance
- **Conflict Resolution**: Handle overlapping requests
- **Capacity Management**: Track meal serving capacity
- **Cancellation Handling**: Allow request modifications

## 🏗️ Implementation Details

### Files
- `meal_type_service.bal`: Meal type management and CRUD operations
- `meal_time_service.bal`: Time slot configuration and management
- `meal_calendar_service.bal`: Calendar functionality and event handling

### Dependencies
- `ballerina/jwt`: Authentication and authorization
- `ballerina/sql`: Database operations
- `ResourceHub.database`: Database connectivity
- `ResourceHub.common`: Shared utilities and validation

## 📊 Database Integration

The module interacts with multiple database tables:
- `mealtypes`: Meal type definitions and images
- `mealtimes`: Time slot configurations
- `requestedmeals`: Meal requests and reservations
- `users`: User information for meal requests

## 🔄 Error Handling

- **403 Forbidden**: Insufficient permissions for operations
- **401 Unauthorized**: Invalid or missing JWT tokens
- **404 Not Found**: Meal type or request not found
- **409 Conflict**: Scheduling conflicts or capacity issues
- **400 Bad Request**: Invalid meal request data

## 📝 Usage Example

```ballerina
import ResourceHub.meal;

// Start meal management services
check meal:startMealTypeService();
check meal:startMealTimeService();
check meal:startCalendarService();

// Services are automatically available at:
// - /mealtype/* for meal type management
// - /mealtime/* for time slot management
// - /calendar/* for calendar and requests
```

## 🔧 Configuration

The module uses:
- JWT validation from `ResourceHub.common`
- Database connections from `ResourceHub.database`
- CORS configuration for web client access
- Role-based authorization for secure operations

## 🎯 Use Cases

- **Corporate Dining**: Manage company cafeteria services
- **Event Catering**: Plan meals for corporate events
- **Dietary Management**: Track individual meal preferences
- **Capacity Planning**: Ensure adequate meal preparation
- **Cost Tracking**: Monitor meal service expenses
