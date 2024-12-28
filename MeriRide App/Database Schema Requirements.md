## **1. Passenger Data**

### **During Sign-Up**

- **Phone Number** (Primary identifier for login and communication).
- **First & Last Name** (For personalization and communication).
- **Email Address** (Optional for ride receipts, communication, and account recovery).
- **Profile Photo** (Optional but builds trust when drivers can see who they are picking up).

### **Additional Information (Post-Sign-Up)**

- **Location Permissions**
    
    - Required to fetch current location and set pick-up/drop-off points.
- **Saved Pickup & Drop-off Locations**
    
    - Passengers may save frequently used locations like "Home," "Work," or "Favorite Places" for ease of booking.
- **Emergency Contact**
    
    - Optional, for added safety features (e.g., ride-sharing status).
- **Ride Preferences**
    
    - E.g., vehicle type preferences (Economy, Luxury, etc.), quiet rides, AC/non-AC options.
- **Feedback and Ratings**
    
    - Collect passenger ratings for drivers post-ride to ensure service quality.
- **Ride History**
    
    - Include pick-up and drop-off locations, fare, duration, driver details, payment method, and ride feedback.

---

## **2. Driver Data**

### **During Sign-Up**

- **Phone Number** (Primary identifier and communication).
    
- **City** (Service city to match rides effectively).
    
- **Vehicle Details**
    
    - Make, model, color, manufacture year, and license plate number.
- **Driver's License Information**
    
    - First & last name, country of issue, license number, issue date, and expiry date.
- **Profile Photo**
    > Images can only be taken through camera. We shouldn't let the driver select from gallery as they might select pictures of another person.
    - Visible to passengers for trust and identification.

---

### **Additional Information (Post-Sign-Up)**

- **Vehicle Documents**
    
    - Vehicle registration certificate (VRC).
    - Vehicle insurance policy (policy number, provider, expiry date).
- **Driver’s National ID or Passport**
    
    - For identity verification purposes.
- **Device Permissions**
    
    - Location services (mandatory for tracking rides).
    - Call permissions (for contacting passengers).
    - Notifications (for ride requests, updates, etc.).
- **Driver Status**
    
    - Available, Offline, On Trip, or Busy.
- **Driver Ratings and Feedback**
    
    - Collect passenger ratings for ongoing quality assurance.
- **Total Completed Rides & Earnings**
    
    - Historical metrics for performance tracking and reporting.
- **Emergency Contact**
    
    - For safety incidents involving the driver.

---

## **3. Ride Information (for the Database Schema)**

Both **passenger** and **driver** data will connect through ride-specific tables to track activity:

- **Ride ID** (Primary key).
- **Passenger ID** (Foreign key).
- **Driver ID** (Foreign key).
- **Pickup Location** (Latitude, Longitude, Address).
- **Drop-off Location** (Latitude, Longitude, Address).
- **Ride Status** (Requested, Accepted, In Progress, Completed, Cancelled).
- **Fare** (Base fare, distance-based fare, and final total).
- **Payment Method** (Cash, Credit/Debit, In-App Wallet).
- **Ride Duration** (Time and distance metrics).
- **Ride Timestamp** (Start time, end time).
- **Driver Feedback** (Rating from the passenger).
- **Passenger Feedback** (Rating for the driver).

---
