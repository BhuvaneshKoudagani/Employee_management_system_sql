CREATE DATABASE EmployeeManagement;

USE EmployeeManagement;

CREATE TABLE Departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

CREATE TABLE Roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(100) NOT NULL,
    salary_scale DECIMAL(10,2)
);

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender ENUM('M', 'F', 'O'),
    dob DATE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    hire_date DATE,
    dept_id INT,
    role_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id),
    FOREIGN KEY (manager_id) REFERENCES Employees(emp_id)
);

CREATE TABLE Salaries (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    base_salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    deductions DECIMAL(10,2),
    pay_date DATE,
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

CREATE TABLE Attendance (
    att_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    date DATE,
    check_in TIME,
    check_out TIME,
    status ENUM('Present','Absent','Leave'),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

CREATE TABLE Leaves (
    leave_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    leave_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    reason TEXT,
    status ENUM('Pending','Approved','Rejected'),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

CREATE TABLE EmployeeProjects (
    emp_proj_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    project_id INT,
    assigned_date DATE,
    role_in_project VARCHAR(100),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

INSERT INTO Departments (dept_name, location) VALUES
('Engineering','Hyderabad'),
('HR','Bangalore'),
('Finance','Mumbai');

INSERT INTO Roles (role_name, salary_scale) VALUES
('Software Engineer', 60000),
('HR Executive', 45000),
('Finance Analyst', 55000),
('Project Manager', 80000),
('Tech Lead', 75000);

INSERT INTO Employees (first_name, last_name, gender, dob, email, phone, hire_date, dept_id, role_id, manager_id) VALUES
('Bhuvan','Rao','M','1990-06-12','bhuvan@company.com','9876543210','2015-01-10',1,5,NULL),
('Sisir','Das','M','1992-07-21','sisir@company.com','9988776655','2016-03-15',1,1,1),
('Savir','Kumar','M','1989-09-19','savir@company.com','8877665544','2014-11-20',2,2,NULL),
('Rahul','Verma','M','1991-05-14','rahul@company.com','7766554433','2017-07-05',1,1,1),
('Kiran','Shah','F','1993-02-22','kiran@company.com','6655443322','2018-09-13',3,3,NULL),
('Ram','Reddy','M','1990-12-09','ram@company.com','5544332211','2016-05-22',1,1,2),
('Divya','Iyer','F','1994-03-11','divya@company.com','4433221100','2019-01-01',2,2,3),
('Krishna','M','M','1988-10-10','krishna@company.com','9988221122','2013-12-12',1,4,NULL);

INSERT INTO Projects (project_name, start_date, end_date, budget, dept_id) VALUES
('Apollo Migration','2023-01-01','2023-12-31',1000000,1),
('HR Revamp','2023-03-01','2023-10-31',300000,2),
('Finance Tracker','2023-04-15','2023-11-30',500000,3);

INSERT INTO EmployeeProjects (emp_id, project_id, assigned_date, role_in_project) VALUES
(2,1,'2023-01-01','Developer'),
(4,1,'2023-01-01','Developer'),
(6,1,'2023-01-01','Tester'),
(3,2,'2023-03-01','HR Analyst'),
(7,2,'2023-03-01','HR Executive'),
(5,3,'2023-04-15','Financial Expert');

INSERT INTO Salaries (emp_id, base_salary, bonus, deductions, pay_date) VALUES
(1,75000,5000,2000,'2025-04-30'),
(2,60000,3000,1500,'2025-04-30'),
(3,45000,2000,1000,'2025-04-30'),
(4,60000,2500,1300,'2025-04-30'),
(5,55000,2800,1200,'2025-04-30'),
(6,60000,2200,1100,'2025-04-30'),
(7,45000,2400,1000,'2025-04-30'),
(8,80000,6000,2500,'2025-04-30');

CREATE VIEW ActiveEmployees AS
SELECT e.emp_id, CONCAT(e.first_name,' ',e.last_name) AS full_name, d.dept_name, r.role_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
JOIN Roles r ON e.role_id = r.role_id
WHERE e.hire_date <= CURDATE();

CREATE VIEW ProjectDetails AS
SELECT p.project_name, e.first_name, e.last_name, ep.role_in_project
FROM Projects p
JOIN EmployeeProjects ep ON p.project_id = ep.project_id
JOIN Employees e ON ep.emp_id = e.emp_id;

CREATE INDEX idx_attendance_empid ON Attendance(emp_id);
CREATE INDEX idx_salary_date ON Salaries(pay_date);

DELIMITER //
CREATE TRIGGER trg_salary_check BEFORE INSERT ON Salaries
FOR EACH ROW
BEGIN
    IF NEW.base_salary < 30000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Base salary too low!';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetEmployeeSalary(IN eid INT)
BEGIN
    SELECT e.first_name, e.last_name, s.base_salary, s.bonus, s.deductions,
           (s.base_salary + s.bonus - s.deductions) AS net_salary
    FROM Employees e
    JOIN Salaries s ON e.emp_id = s.emp_id
    WHERE e.emp_id = eid;
END;
//
DELIMITER ;

CALL GetEmployeeSalary(1);

SELECT e.first_name, e.last_name, r.role_name, d.dept_name
FROM Employees e
JOIN Roles r ON e.role_id = r.role_id
JOIN Departments d ON e.dept_id = d.dept_id
WHERE r.salary_scale > 50000;

SELECT emp_id, COUNT(*) AS total_attendance
FROM Attendance
WHERE status = 'Present'
GROUP BY emp_id;

SELECT e.first_name, e.last_name, p.project_name
FROM Employees e
JOIN EmployeeProjects ep ON e.emp_id = ep.emp_id
JOIN Projects p ON p.project_id = ep.project_id
WHERE e.dept_id = 1;

SELECT e.first_name, e.last_name
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1 FROM Leaves l WHERE l.emp_id = e.emp_id AND l.status = 'Approved'
);