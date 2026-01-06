CREATE DATABASE hospitalRecords;
USE hospitalRecords;

/* TABLE 1 DEPARTMENT */
CREATE TABLE department(
	departID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL);

/* TABLE 2 DOCTOR */
CREATE TABLE doctor(
doctorID INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100),
specialisation VARCHAR(50),
role VARCHAR(50),
departID INT,
FOREIGN KEY(departID) REFERENCES department(departID));

/* TABLE 3 PATIENTS */
CREATE TABLE patients(
pateintID INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100),
dob DATE,
gender VARCHAR(1) CHECK(gender IN ("M","F","O")),
phone VARCHAR(20));
;

/* TABLE 4 APPOINTMENTS */
CREATE TABLE appointments(
appointID INT AUTO_INCREMENT PRIMARY KEY,
pateintID INT,
doctorID INT,
appoint_time DATETIME NOT NULL,
status VARCHAR(50) NOT NULL CHECK(status IN ("Scheduled","Cancelled","Completed")),
FOREIGN KEY(pateintID) REFERENCES patients(pateintID),
FOREIGN KEY(doctorID) REFERENCES doctor(doctorID));

/* TABLE 5 PRESCRIPTIONS */
CREATE TABLE prescriptions(
prescripID INT AUTO_INCREMENT PRIMARY KEY,
appointID INT,
medication VARCHAR(255),
dosage VARCHAR(255),
FOREIGN KEY(appointID) REFERENCES appointments(appointID));

/* TABLE 6 BILLS */
CREATE TABLE bills(
billID INT AUTO_INCREMENT PRIMARY KEY,
appointID INT,
amount DECIMAL(10,2),
paid BOOLEAN DEFAULT 0,
billdate DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY(appointID) REFERENCES appointments(appointID));

/* TABLE 7 LAB REPORTS */
CREATE TABLE reports(
reportID INT AUTO_INCREMENT PRIMARY KEY,
appointID INT,
reportdata TEXT,
reportdate DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY(appointID) REFERENCES appointments(appointID));

-- INSERTING DATA --

/* SELECT * FROM hospital_data;
SELECT `Departments.DepartmentID` FROM hospital_data;   want data like this*/

/* INSERTING VALUES INTO TABLE 1 DEPARTMENT */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "Departments.%";

INSERT INTO department(departID,name)
SELECT`Departments.DepartmentID`,`Departments.Name`FROM hospital_data
WHERE `Departments.DepartmentID` <> "";

SELECT * FROM department;

/* INSERTING VALUES INTO TABLE 2 DOCTOR */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "Doctors.%";

INSERT INTO doctor(departID,doctorID,name,role,specialisation)
SELECT`Doctors.DepartmentID`,`Doctors.DoctorID`,`Doctors.Name`,`Doctors.Role`,`Doctors.Specialization`FROM hospital_data
WHERE `Doctors.DepartmentID` <> "";

SELECT * FROM doctor;

/* INSERTING VALUES INTO TABLE 3 PATIENTS */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "Patients.%";

INSERT INTO patients(dob,gender,name,pateintID,phone)
SELECT STR_TO_DATE(`Patients.DateOfBirth`,"%d-%m-%Y"),`Patients.Gender`,`Patients.Name`,`Patients.PatientID`,`Patients.Phone`FROM hospital_data
WHERE `Patients.PatientID` <> "";

select * from patients;

/* INSERTING VALUES INTO TABLE 4 APPOINTMENTS */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "Appointments.%";

INSERT INTO appointments(appointID,appoint_time,doctorID,pateintID,status)
SELECT`Appointments.AppointmentID`, STR_TO_DATE(`Appointments.AppointmentTime`,"%d-%m-%Y %H:%i"),`Appointments.DoctorID`,
`Appointments.PatientID`,`Appointments.Status`FROM hospital_data
WHERE `Appointments.AppointmentID` <> "";

select * from appointments;

/* INSERTING VALUES INTO TABLE 5 PRESCRIPTIONS */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "Prescriptions.%";

INSERT INTO prescriptions(appointID,dosage,medication,prescripID)
SELECT`Prescriptions.AppointmentID`,`Prescriptions.Dosage`,`Prescriptions.Medication`,`Prescriptions.PrescriptionID`FROM hospital_data
WHERE `Prescriptions.PrescriptionID` <> "";

select * from prescriptions;

/* INSERTING VALUES INTO TABLE 6 BILLS */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "Bills.%";

INSERT INTO bills(amount,appointID,billdate,billID,paid)
SELECT`Bills.Amount`,`Bills.AppointmentID`,`Bills.BillDate`,`Bills.BillID`,`Bills.Paid`FROM hospital_data
WHERE `Bills.BillID` <> "";

select * from bills;

/* INSERTING VALUES INTO TABLE 7 LABREPORTS */
SELECT concat("SELECT",group_concat(concat("`",COLUMN_NAME,"`")),"FROM hospital_data;") FROM INFORMATION_SCHEMA.COLUMNS
WHERE
TABLE_SCHEMA="hospitalrecords"
AND TABLE_NAME="hospital_data"
AND COLUMN_NAME LIKE "LabReports.%";

INSERT INTO reports(appointID,reportdate,reportdata,reportID)
SELECT`LabReports.AppointmentID`,`LabReports.CreatedAt`,`LabReports.ReportData`,`LabReports.ReportID`FROM hospital_data
WHERE `LabReports.ReportID` <> "";

select * from reports;

/* DEALING WITH INVALID APPOINTMENTS WITH DOCTOR */

DELIMITER $$
CREATE TRIGGER check_appoint
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
	IF NEW.appoint_time < NOW() THEN
    SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Error: Please set a valid time.";
    END IF;
    
    IF EXISTS (
    SELECT * FROM appointments WHERE
    doctorID = NEW.doctorID AND
    appoint_time = NEW.appoint_time AND
    status = "Scheduled")  
    THEN
    SIGNAL SQLSTATE "45000"
    SET MESSAGE_TEXT = "Error: Doctor is already appointed.";
    END IF;
    
END $$
DELIMITER ;

-- Checking if trigger works --
INSERT INTO appointments(appointID,pateintID,doctorID,appoint_time,status) 
VALUES(4001,5,8,"2026-02-21 7:00:00","Scheduled");

INSERT INTO appointments(appointID,pateintID,doctorID,appoint_time,status) 
VALUES(4002,5,8,"2026-02-21 7:00:00","Scheduled");

/* DATA BASED OWN CREDENTIALS */

DELIMITER $$
CREATE PROCEDURE show_data(IN username VARCHAR(100), IN passw VARCHAR(100))
BEGIN
	DECLARE doc_dept INT;
    DECLARE doc_role VARCHAR(50);
    DECLARE docID INT;
    
    SELECT doctor_id INTO docID  -- getting the doctor ID --
    FROM doctor_credentials
    WHERE user_name=username 
    AND password=passw;
    
    SELECT departID,role INTO doc_dept,doc_role  -- getting the doctor role and department --
    FROM doctor
    WHERE doctorID=docID;
    
    IF doc_role = "Senior" THEN
		SELECT d.doctorID,p.pateintID, p.name,p.gender,a.appoint_time,a.status,pr.medication,pr.dosage,r.reportdata FROM patients AS p
		LEFT JOIN appointments AS a 
		ON p.pateintID = a.pateintID
		JOIN doctor AS d 
		ON a.doctorID=d.doctorID
		LEFT JOIN prescriptions AS pr
		ON pr.appointID=a.appointID
		LEFT JOIN reports AS r
		ON r.appointID=a.appointID
		WHERE departID = doc_dept;
    
    ELSE
		SELECT a.doctorID,p.pateintID, p.name,p.gender,a.appoint_time,a.status,pr.medication,pr.dosage,r.reportdata FROM patients AS p
		LEFT JOIN appointments AS a 
		ON p.pateintID = a.pateintID
		LEFT JOIN prescriptions AS pr
		ON pr.appointID=a.appointID
		LEFT JOIN reports AS r
		ON r.appointID=a.appointID
		WHERE a.doctorID = docID;
    END IF;
END $$
DELIMITER ;

CALL show_data('doctor8','LFNsHx7f');

/* MONTHLY REPORT */

DELIMITER $$
CREATE PROCEDURE monthly_total(IN month INT, IN year INT)
BEGIN
SELECT dp.name AS Department , SUM(b.amount) AS Total_revenue FROM bills AS b
JOIN appointments AS a ON b.appointID = a.appointID 
JOIN doctor AS d ON d.doctorID = a.doctorID
JOIN department AS dp ON dp.departID = d.departID
WHERE MONTH(b.billdate) = month AND year(b.billdate) = year
Group by dp.name;

END $$
DELIMITER ;

CALL monthly_total(4,2025);




