-- =========================================================
-- SCRO DATABASE
-- Smart Classroom Resource Optimizer
-- =========================================================

CREATE DATABASE IF NOT EXISTS scro;

USE scro;

-- =========================================================
-- 1. DEPARTMENTS
-- =========================================================

CREATE TABLE departments (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    department_name VARCHAR(100)
    UNIQUE NOT NULL
);

-- =========================================================
-- 2. USERS
-- =========================================================

CREATE TABLE users (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    name VARCHAR(100) NOT NULL,

    email VARCHAR(100)
    UNIQUE NOT NULL,

    password VARCHAR(255) NOT NULL,

    role ENUM(
        'ADMIN',
        'FACULTY',
        'COORDINATOR'
    ) NOT NULL,

    department_id BIGINT,

    created_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE SET NULL
);

-- =========================================================
-- 3. FACULTY WORKLOAD
-- =========================================================

CREATE TABLE faculty_workload (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    faculty_id BIGINT UNIQUE NOT NULL,

    max_work_hours INT DEFAULT 40,

    assigned_hours INT DEFAULT 0,

    remaining_hours INT DEFAULT 40,

    semester VARCHAR(20),

    academic_year VARCHAR(20),

    updated_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_workload_faculty
    FOREIGN KEY (faculty_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

-- =========================================================
-- 4. CLASSROOMS
-- =========================================================

CREATE TABLE classrooms (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    room_number VARCHAR(20)
    UNIQUE NOT NULL,

    capacity INT NOT NULL
    CHECK (capacity > 0),

    has_blackboard BOOLEAN DEFAULT TRUE,

    has_whiteboard BOOLEAN DEFAULT FALSE,

    has_smartboard BOOLEAN DEFAULT FALSE,

    has_projector BOOLEAN DEFAULT FALSE,

    room_type ENUM(
        'CLASSROOM',
        'LAB',
        'SEMINAR_HALL'
    ) DEFAULT 'CLASSROOM',

    floor_no INT,

    building_name VARCHAR(100),

    is_active BOOLEAN DEFAULT TRUE
);

-- =========================================================
-- 5. SUBJECTS
-- =========================================================

CREATE TABLE subjects (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    subject_name VARCHAR(100) NOT NULL,

    subject_code VARCHAR(20)
    UNIQUE NOT NULL,

    department_id BIGINT NOT NULL,

    semester INT NOT NULL,

    credits INT DEFAULT 3,

    weekly_hours INT NOT NULL,

    CONSTRAINT fk_subject_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE CASCADE
);

-- =========================================================
-- 6. SCHEDULES
-- =========================================================

CREATE TABLE schedules (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    subject_id BIGINT NOT NULL,

    faculty_id BIGINT NOT NULL,

    department_id BIGINT NOT NULL,

    section_name VARCHAR(20) NOT NULL,

    student_count INT NOT NULL,

    day_of_week ENUM(
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY'
    ) NOT NULL,

    start_time TIME NOT NULL,

    end_time TIME NOT NULL,

    requires_blackboard BOOLEAN DEFAULT FALSE,

    requires_whiteboard BOOLEAN DEFAULT FALSE,

    requires_smartboard BOOLEAN DEFAULT FALSE,

    requires_projector BOOLEAN DEFAULT FALSE,

    priority_level ENUM(
        'HIGH',
        'MEDIUM',
        'LOW'
    ) DEFAULT 'LOW',

    status ENUM(
        'PENDING',
        'ALLOCATED',
        'REJECTED'
    ) DEFAULT 'PENDING',

    created_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_schedule_subject
    FOREIGN KEY (subject_id)
    REFERENCES subjects(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_schedule_faculty
    FOREIGN KEY (faculty_id)
    REFERENCES users(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_schedule_department
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE CASCADE
);

-- =========================================================
-- 7. ALLOCATIONS
-- =========================================================

CREATE TABLE allocations (

    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    schedule_id BIGINT UNIQUE NOT NULL,

    classroom_id BIGINT NOT NULL,

    allocation_score INT DEFAULT 0,

    access_status ENUM(
        'GRANTED',
        'DENIED'
    ) DEFAULT 'GRANTED',

    camera_access ENUM(
        'GRANTED',
        'DENIED'
    ) DEFAULT 'GRANTED',

    allocation_status ENUM(
        'SUCCESS',
        'FAILED'
    ) DEFAULT 'SUCCESS',

    allocated_at TIMESTAMP
    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_allocation_schedule
    FOREIGN KEY (schedule_id)
    REFERENCES schedules(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_allocation_classroom
    FOREIGN KEY (classroom_id)
    REFERENCES classrooms(id)
    ON DELETE CASCADE
);

-- =========================================================
-- INDEXES
-- =========================================================

CREATE INDEX idx_user_department
ON users(department_id);

CREATE INDEX idx_subject_department
ON subjects(department_id);

CREATE INDEX idx_schedule_faculty
ON schedules(faculty_id);

CREATE INDEX idx_schedule_day
ON schedules(day_of_week);

CREATE INDEX idx_allocation_classroom
ON allocations(classroom_id);

-- =========================================================
-- SAMPLE DATA
-- =========================================================

-- DEPARTMENTS

INSERT INTO departments(department_name)
VALUES
('CSE'),
('ECE'),
('MECH');

-- USERS

INSERT INTO users(
    name,
    email,
    password,
    role,
    department_id
)
VALUES
(
    'Admin User',
    'admin@scro.com',
    'admin123',
    'ADMIN',
    1
),

(
    'Dr Smith',
    'smith@scro.com',
    'pass123',
    'FACULTY',
    1
),

(
    'Dr Kumar',
    'kumar@scro.com',
    'pass123',
    'FACULTY',
    2
),

(
    'Coordinator Ravi',
    'ravi@scro.com',
    'pass123',
    'COORDINATOR',
    1
);

-- FACULTY WORKLOAD

INSERT INTO faculty_workload(
    faculty_id,
    max_work_hours,
    assigned_hours,
    remaining_hours,
    semester,
    academic_year
)
VALUES
(
    2,
    30,
    12,
    18,
    '5',
    '2025-2026'
),

(
    3,
    32,
    10,
    22,
    '5',
    '2025-2026'
);

-- CLASSROOMS

INSERT INTO classrooms(
    room_number,
    capacity,
    has_blackboard,
    has_whiteboard,
    has_smartboard,
    has_projector,
    room_type,
    floor_no,
    building_name
)
VALUES
(
    'A101',
    60,
    TRUE,
    TRUE,
    FALSE,
    TRUE,
    'CLASSROOM',
    1,
    'Main Block'
),

(
    'LAB201',
    40,
    TRUE,
    FALSE,
    TRUE,
    TRUE,
    'LAB',
    2,
    'Tech Block'
);

-- SUBJECTS

INSERT INTO subjects(
    subject_name,
    subject_code,
    department_id,
    semester,
    credits,
    weekly_hours
)
VALUES
(
    'Data Structures',
    'CS201',
    1,
    3,
    4,
    5
),

(
    'Microprocessors',
    'EC301',
    2,
    5,
    4,
    4
);

-- SCHEDULES

INSERT INTO schedules(
    subject_id,
    faculty_id,
    department_id,
    section_name,
    student_count,
    day_of_week,
    start_time,
    end_time,
    requires_projector,
    requires_smartboard,
    priority_level
)
VALUES
(
    1,
    2,
    1,
    'CSE-A',
    55,
    'MONDAY',
    '09:00:00',
    '10:00:00',
    TRUE,
    FALSE,
    'HIGH'
);

-- ALLOCATIONS

INSERT INTO allocations(
    schedule_id,
    classroom_id,
    allocation_score
)
VALUES
(
    1,
    1,
    95
);

-- =========================================================
-- TESTING
-- =========================================================

SELECT * FROM departments;

SELECT * FROM users;

SELECT * FROM faculty_workload;

SELECT * FROM classrooms;

SELECT * FROM subjects;

SELECT * FROM schedules;

SELECT * FROM allocations;
