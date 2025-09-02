DROP TABLE IF EXISTS courses_computer;
CREATE TABLE courses_computer (
    id INT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    number_unit INT
);

DROP TABLE IF EXISTS course_computer_prerequisites;
CREATE TABLE course_computer_prerequisites (
    course_id INT PRIMARY KEY,
    prerequisite_1 INT,
    prerequisite_2 INT,
    prerequisite_3 INT
);

DROP TABLE IF EXISTS course_computer_corequisites;
CREATE TABLE course_computer_corequisites (
    course_id INT PRIMARY KEY,
    corequisites_1 INT,
    corequisites_2 INT,
    corequisites_3 INT
);

DROP TABLE IF EXISTS course_requirements;
CREATE TABLE course_requirements (
    course_id INT PRIMARY KEY,
    min_passed_units INT
);

DROP TABLE IF EXISTS next_semester_courses;
DROP TABLE IF EXISTS course_sections;

DROP TABLE IF EXISTS sections;
CREATE TABLE sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INT NOT NULL,
    exam_datetime DATETIME NOT NULL,
    capacity INT NOT NULL,
    instructor_name VARCHAR(255) NOT NULL,
    description TEXT,
    FOREIGN KEY(course_id) REFERENCES courses_computer(id)
);

DROP TABLE IF EXISTS section_times;
CREATE TABLE section_times (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id INT NOT NULL,
    day VARCHAR(20) NOT NULL,
    start_time VARCHAR(5) NOT NULL,
    end_time VARCHAR(5) NOT NULL,
    location VARCHAR(255),
    FOREIGN KEY(section_id) REFERENCES sections(id)
);

INSERT INTO courses_computer (id, course_name, number_unit) VALUES
    (101, 'فیزیک 1', 3),
    (102, 'ریاضی عمومی 1', 3),
    (103, 'دروس گروه معارف اسلامی', 2),
    (104, 'دانش خانواده', 2),
    (105, 'فارسی', 3),
    (107, 'کامپیوتر و برنامه سازی مبانی ', 3),
    (106, 'تربیت بدنی', 1),
    (201, 'برنامه سازی پیشرفته', 3),
    (202, 'کارگاه کامپیوتر', 1),
    (203, 'ریاضیات گسسته', 3),
    (204, 'فیزیک 2', 3),
    (205, 'ریاضی عمومی 2', 3),
    (206, 'زبان انگلیسی', 3),
    (207, 'ورزش', 1),
    (208, 'دروس گروه معارف اسلامی', 2),
    (301, 'ساختمان های داده', 3),
    (302, 'مدار منطقی', 3),
    (303, 'معادلات دیفرانسیل', 3),
    (304, 'آزمایشگاه فیزیک 2', 1),
    (305, 'آمار و احتمالات مهندسی', 3),
    (306, 'زبان تخصصی', 2),
    (307, 'درس گروه معارف اسلامی', 2),
    (401, 'طراحی الگوریتم‌ها', 3),
    (402, 'نظریه زبان‌ها و ماشین‌ها', 3),
    (403, 'آزمایشگاه مدار منطقی و معماری کامپیوتر', 1),
    (404, 'معماری کامپیوتر', 3),
    (405, 'ریاضیات مهندسی', 3),
    (406, 'مدار الکتریکی', 3),
    (407, 'دروس گروه معارف اسلامی', 2),
    (501, 'هوش مصنوعی و سیستم‌های خبره', 3),
    (502, 'طراحی کامپایلر', 3),
    (503, 'پایگاه داده‌ها', 3),
    (504, 'ریزپردازنده و زبان اسمبلی', 3),
    (505, 'سیگنال‌ها و سیستم‌ها', 3),
    (506, 'روش پژوهش و ارائه', 2),
    (507, 'دروس گروه معارف اسلامی', 2),
    (601, 'تحلیل و طراحی سیستم', 3),
    (602, 'مبانی هوش محاسباتی', 3),
    (603, 'طراحی زبان‌های برنامه‌سازی', 3),
    (604, 'سیستم‌های عامل', 3),
    (605, 'طراحی سیستم‌های دیجیتالی', 3),
    (606, 'درس اختیاری', 1),
    (607, 'دروس گروه معارف اسلامی', 2),
    (701, 'مهندسی نرم افزار', 3),
    (702, 'درس اختیاری', 1),
    (703, 'شبکه‌های کامپیوتری', 3),
    (704, 'آزمایشگاه سیستم‌های عامل', 1),
    (705, 'آزمایشگاه ریزپردازنده', 1),
    (706, 'اصول رباتیک', 3),
    (707, 'درس اختیاری', 3),
    (801, 'پروژه نرم افزار (بعد از 100 واحد)', 3),
    (802, 'مهندسی اینترنت', 3),
    (803, 'آزمایشگاه شبکه‌های کامپیوتری', 1),
    (804, 'مبانی بینایی ماشین', 3),
    (805, 'مبانی پردازش گفتار', 3),
    (806, 'درس اختیاری', 3),
    (807, 'کاراموزی', 1);

INSERT INTO course_computer_prerequisites (course_id, prerequisite_1, prerequisite_2, prerequisite_3) VALUES
    (201, 107, NULL, NULL),
    (202, 107, NULL, NULL),
    (204, 102, NULL, NULL),
    (205, 102, NULL, NULL),
    (207, 106, NULL, NULL),
    (301, 203, 201, NULL),
    (303, 102, NULL, NULL),
    (304, 204, NULL, NULL),
    (305, 205, NULL, NULL),
    (306, 206, NULL, NULL),
    (401, 301, NULL, NULL),
    (402, 301, NULL, NULL),
    (403, 302, NULL, NULL),
    (404, 302, NULL, NULL),
    (405, 303, 205, NULL),
    (406, 303, NULL, NULL),
    (501, 301, NULL, NULL),
    (502, 301, NULL, NULL),
    (503, 301, NULL, NULL),
    (504, 404, NULL, NULL),
    (505, 405, NULL, NULL),
    (506, 306, NULL, NULL),
    (601, 201, NULL, NULL),
    (602, 201, NULL, NULL),
    (603, 502, NULL, NULL),
    (604, 301, 404, NULL),
    (605, 404, NULL, NULL),
    (701, 601, NULL, NULL),
    (703, 604, NULL, NULL),
    (706, 505, NULL, NULL),
    (804, 602, NULL, NULL),
    (802, 703, NULL, NULL),
    (805, 505, NULL, NULL);

INSERT INTO course_computer_corequisites (course_id, corequisites_1, corequisites_2, corequisites_3) VALUES
    (101, 102, NULL, NULL),
    (203, 107, 102, NULL),
    (302, 203, NULL, NULL),
    (403, 404, NULL, NULL),
    (704, 604, NULL, NULL),
    (705, 504, NULL, NULL),
    (803, 703, NULL, NULL);

INSERT INTO course_requirements (course_id, min_passed_units) VALUES
    (801, 100),
    (807, 85);

-- داده تستی برای sections
INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(1, 101, '2025-06-01T09:00:00', 40, 'دکتر احمدی', 'سکشن ویژه دانشجویان ممتاز'),
(2, 101, '2025-06-10T14:00:00', 40, 'دکتر احمدی', 'سکشن عادی'),
(3, 102, '2025-06-02T11:00:00', 35, 'دکتر رضایی', NULL),
(4, 201, '2025-06-03T15:00:00', 30, 'مهندس محمدی', 'سکشن با ظرفیت محدود');

-- داده تستی برای section_times
INSERT INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
(1, 1, 'شنبه', '08:00', '10:00', 'کلاس 101'),
(2, 2, 'چهارشنبه', '14:00', '16:00', 'کلاس 102'),
(3, 3, 'یکشنبه', '10:00', '12:00', 'کلاس 201'),
(4, 4, 'دوشنبه', '14:00', '16:00', 'کلاس 301'),
(5, 4, 'سه‌شنبه', '08:00', '10:00', 'کلاس 302');
