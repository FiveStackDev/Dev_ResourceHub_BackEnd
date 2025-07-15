# Notification Module

This module handles notification-related functionality for the Resource Hub application.

## Features

- View notifications (pending maintenance requests)
- Add custom notifications (Admin/SuperAdmin only)
- Notification management for system alerts

## Services

- `/notification` - Main notification service endpoint

## Endpoints

- `GET /notification/details` - Retrieve all notifications
- `POST /notification/add` - Add new notification (Admin/SuperAdmin only)

## Types

- `Notification` - Record type for notification data
