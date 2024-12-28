## Database Schema for Ride-Sharing Service

### **1. Passenger Data Table**

**Table Name:** `passengers`

| Column Name     | Data Type    | Constraints                 | Description                                     |
| --------------- | ------------ | --------------------------- | ----------------------------------------------- |
| `passenger_id`  | INT          | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each passenger.           |
| `phone_number`  | VARCHAR(15)  | UNIQUE, NOT NULL            | Primary identifier for login and communication. |
| `first_name`    | VARCHAR(50)  | NOT NULL                    | Passenger's first name.                         |
| `last_name`     | VARCHAR(50)  | NOT NULL                    | Passenger's last name.                          |
| `email`         | VARCHAR(100) | UNIQUE                      | Optional email for receipts and recovery.       |
| `profile_photo` | BLOB         | NULL                        | Optional photo for trust and identification.    |
| `created_at`    | DATETIME     | DEFAULT CURRENT_TIMESTAMP   | Account creation timestamp.                     |

**Additional Information:**

**Table Name:** `passenger_preferences`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`preference_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for preference entry.|
|`passenger_id`|INT|FOREIGN KEY (passengers)|Reference to passenger account.|
|`ride_preference`|VARCHAR(50)|NULL|Preferences like Economy, Luxury, AC/Non-AC.|
|`emergency_contact`|VARCHAR(50)|NULL|Optional contact number for emergencies.|
|`saved_location_name`|VARCHAR(50)|NULL|Name for saved locations (e.g., Home, Work).|
|`saved_location_lat`|FLOAT|NULL|Latitude of saved location.|
|`saved_location_long`|FLOAT|NULL|Longitude of saved location.|

**Table Name:** `passenger_feedback`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`feedback_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for feedback.|
|`passenger_id`|INT|FOREIGN KEY (passengers)|Reference to passenger account.|
|`driver_id`|INT|FOREIGN KEY (drivers)|Reference to driver.|
|`ride_id`|INT|FOREIGN KEY (rides)|Reference to specific ride.|
|`rating`|FLOAT|CHECK (rating BETWEEN 1-5)|Passenger rating for the driver.|
|`comments`|TEXT|NULL|Optional feedback comments.|
|`created_at`|DATETIME|DEFAULT CURRENT_TIMESTAMP|Feedback timestamp.|

---

### **2. Driver Data Table**

**Table Name:** `drivers`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`driver_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for each driver.|
|`phone_number`|VARCHAR(15)|UNIQUE, NOT NULL|Primary identifier for login and communication.|
|`city`|VARCHAR(50)|NOT NULL|City of service.|
|`first_name`|VARCHAR(50)|NOT NULL|Driver's first name.|
|`last_name`|VARCHAR(50)|NOT NULL|Driver's last name.|
|`profile_photo`|BLOB|NOT NULL|Photo taken via camera for identification.|
|`vehicle_make`|VARCHAR(50)|NOT NULL|Vehicle's make (e.g., Toyota, Ford).|
|`vehicle_model`|VARCHAR(50)|NOT NULL|Model of the vehicle.|
|`vehicle_color`|VARCHAR(30)|NOT NULL|Vehicle color.|
|`vehicle_year`|INT|NOT NULL|Vehicle manufacture year.|
|`license_plate`|VARCHAR(20)|NOT NULL, UNIQUE|Vehicle's license plate.|
|`license_number`|VARCHAR(30)|NOT NULL|Driver's license number.|
|`license_country`|VARCHAR(50)|NOT NULL|Country of license issuance.|
|`license_issue_date`|DATE|NOT NULL|License issue date.|
|`license_expiry_date`|DATE|NOT NULL|License expiration date.|
|`created_at`|DATETIME|DEFAULT CURRENT_TIMESTAMP|Account creation timestamp.|

**Additional Information:**

**Table Name:** `driver_documents`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`document_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for documents.|
|`driver_id`|INT|FOREIGN KEY (drivers)|Reference to driver.|
|`document_type`|VARCHAR(50)|NOT NULL|Type of document (e.g., VRC, Insurance).|
|`document_number`|VARCHAR(50)|NULL|Document policy or registration number.|
|`document_provider`|VARCHAR(50)|NULL|Provider of document (e.g., insurance company).|
|`expiry_date`|DATE|NULL|Document expiration date.|
|`uploaded_at`|DATETIME|DEFAULT CURRENT_TIMESTAMP|Document upload timestamp.|

**Table Name:** `driver_status`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`status_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for status entry.|
|`driver_id`|INT|FOREIGN KEY (drivers)|Reference to driver.|
|`status`|ENUM|NOT NULL|Driver's status (Available, Offline, On Trip).|
|`last_updated`|DATETIME|DEFAULT CURRENT_TIMESTAMP|Timestamp of status update.|

**Table Name:** `driver_feedback`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`feedback_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for feedback.|
|`driver_id`|INT|FOREIGN KEY (drivers)|Reference to driver account.|
|`ride_id`|INT|FOREIGN KEY (rides)|Reference to specific ride.|
|`rating`|FLOAT|CHECK (rating BETWEEN 1-5)|Driver rating from the passenger.|
|`comments`|TEXT|NULL|Optional feedback comments.|
|`created_at`|DATETIME|DEFAULT CURRENT_TIMESTAMP|Feedback timestamp.|

---

### **3. Ride Information Table**

**Table Name:** `rides`

|Column Name|Data Type|Constraints|Description|
|---|---|---|---|
|`ride_id`|INT|PRIMARY KEY, AUTO_INCREMENT|Unique identifier for each ride.|
|`passenger_id`|INT|FOREIGN KEY (passengers)|Reference to passenger.|
|`driver_id`|INT|FOREIGN KEY (drivers)|Reference to driver.|
|`pickup_lat`|FLOAT|NOT NULL|Pickup location latitude.|
|`pickup_long`|FLOAT|NOT NULL|Pickup location longitude.|
|`pickup_address`|VARCHAR(255)|NULL|Optional address for pickup.|
|`dropoff_lat`|FLOAT|NOT NULL|Drop-off location latitude.|
|`dropoff_long`|FLOAT|NOT NULL|Drop-off location longitude.|
|`dropoff_address`|VARCHAR(255)|NULL|Optional address for drop-off.|
|`ride_status`|ENUM|NOT NULL|Status (Requested, Accepted, Completed, etc.).|
|`fare_base`|FLOAT|NOT NULL|Base fare.|
|`fare_distance`|FLOAT|NOT NULL|Distance-based fare.|
|`fare_total`|FLOAT|NOT NULL|Final total fare.|
|`payment_method`|ENUM|NOT NULL|Cash, Card, Payment Gateway, etc.|
|`ride_duration_minutes`|INT|NULL|Ride duration in minutes.|
|`distance_km`|FLOAT|NULL|Distance traveled in kilometers.|
|`ride_start_time`|DATETIME|NULL|Ride start timestamp.|
|`ride_end_time`|DATETIME|NULL|Ride end timestamp.|

---
