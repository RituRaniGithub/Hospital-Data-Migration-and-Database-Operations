# Hospital Data Migration and Operation System using MySQL

## Project Overview
The goal of this project was to convert hospital data maintained in spreadsheets into a structured SQL database and fix common operational issues such as duplicate doctor appointments, missing data links, and limited reporting capability.


## Problem Statement
Hospitals often begin by storing operational data such as patient records, doctor schedules, appointments, and billing information in spreadsheets.
While this approach works initially, it quickly leads to critical issues as data volume grows.
1. In the given scenario, hospital data was maintained in a single Excel-style table, which resulted in:
2. Duplicate doctor appointments with no conflict validation
3. No enforced relationship between patients, doctors, departments, and billing records
4. High risk of inconsistent or invalid data (e.g., past appointments, missing links)
5. Limited ability to generate operational or financial insights, such as department-wise revenue

Due to the lack of structure and automated checks, the system was inefficient for both daily operations and management-level decision-making. This project addresses these issues by enforcing data integrity and business rules directly within the database.

## Solution Approach
1. Designed a normalized relational schema covering patients, doctors, appointments, billing, prescriptions, and reports.
2. Migrated spreadsheet-based hospital data into a structured relational database.
3. Implemented triggers to prevent invalid and conflicting appointments.
4. Built role-based stored procedures for controlled data access.
5. Created analytical SQL queries for department-wise revenue reporting.

By moving from spreadsheets to a relational database system:
1. Appointment conflicts are prevented at the source.
2. Data integrity is maintained automatically without manual checks.
3. Hospital staff gain reliable access to accurate operational data.
4. Management can make informed decisions using structured financial insights.

## Database Design
**Core Entities:**
- Department
- Doctor
- Patients
- Appointments
- Prescriptions
- Bills
- Lab Reports

Foreign key constraints ensure referential integrity across the system.
<img width="1192" height="691" alt="ER_Diagram" src="https://github.com/user-attachments/assets/99b22c5d-cb6e-451b-a484-ec8ad3c9a288" />


