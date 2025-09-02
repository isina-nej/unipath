-- SQL INSERT statements for sections and section_times generated from CSV

-- Max existing section ID from your initial data is 4.
-- New section IDs will start from 5 to avoid conflicts with existing data.

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(5, 701, NULL, 40, 'نامشخص', 'آز نرم افزار');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(5, 'شنبه', '10:00', '12:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(6, 803, NULL, 40, 'نامشخص', 'آز شبکه');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(6, 'شنبه', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(7, 705, NULL, 40, 'نامشخص', 'آز ریزپردازنده');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(7, 'شنبه', '16:00', '18:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(8, 606, '2025-10-23T10:00:00', 40, 'نامشخص', 'مباث ویژه');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(8, 'شنبه', '18:00', '20:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(8, 'یک شنبه', '18:20', '20:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(9, 701, '2025-10-17T10:00:00', 40, 'نامشخص', 'م نرم افزار');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(9, 'یک شنبه', '10:00', '12:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(9, 'سه شنبه', '10:00', '12:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(10, 704, NULL, 40, 'نامشخص', 'آز سیستم عامل');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(10, 'یک شنبه', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(11, 703, '2025-10-21T10:00:00', 40, 'نامشخص', 'شبکه های کامپیوتری');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(11, 'دوشنبه', '16:00', '20:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(12, 706, '2025-10-29T10:00:00', 40, 'نامشخص', 'رباتیکز');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(12, 'سه شنبه', '16:00', '20:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(13, 503, '2025-10-22T10:00:00', 40, 'نامشخص', 'پایگاه');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(13, 'شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(13, 'چهارشنبه', '10:00', '12:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(14, 401, '2025-10-28T10:00:00', 40, 'نامشخص', 'طراحی الگوریتم');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(14, 'شنبه', '10:00', '12:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(14, 'دوشنبه', '10:00', '12:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(15, 501, '2025-10-30T10:00:00', 40, 'نامشخص', 'هوش مصنوعی');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(15, 'یک شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(15, 'سه شنبه', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(16, 506, '2025-10-14T08:00:00', 40, 'نامشخص', 'روش پژوهش');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(16, 'یک شنبه', '10:00', '12:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(17, 502, '2025-10-24T10:00:00', 40, 'نامشخص', 'کامپایلر');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(17, 'یک شنبه', '16:00', '18:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(17, 'سه شنبه', '16:00', '18:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(18, 604, '2025-10-20T10:00:00', 40, 'نامشخص', 'سیستم عامل');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(18, 'یک شنبه', '18:00', '20:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(18, 'سه شنبه', '18:00', '20:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(19, 505, '2025-10-16T10:00:00', 40, 'نامشخص', 'سیگنال و سیستم');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(19, 'دو شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(19, 'سه شنبه', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(20, 504, NULL, 40, 'نامشخص', 'ریز پردازنده');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(20, 'دو شنبه', '14:00', '18:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(21, 303, '2025-10-20T08:00:00', 40, 'نامشخص', 'معادلات');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(21, 'شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(21, 'دوشنبه', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(22, 302, '2025-10-24T10:00:00', 40, 'نامشخص', 'مدار منطقی');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(22, 'شنبه', '10:00', '12:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(22, 'سه شنبه ', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(23, 201, '2025-10-15T10:00:00', 40, 'نامشخص', 'پیشرفته');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(23, 'شنبه', '14:00', '16:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(23, 'دوشنبه', '16:00', '18:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(24, 304, NULL, 40, 'نامشخص', 'آز فیزیک2');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(24, 'شنبه', '16:00', '18:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(24, 'یک شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(24, 'دوشنبه', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(25, 306, '2025-10-22T08:00:00', 40, 'نامشخص', 'زبان تخصصی');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(25, 'شنبه', '18:00', '20:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(26, 301, '2025-10-28T10:00:00', 40, 'نامشخص', 'ساختمان داده');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(26, 'یک شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(26, 'سه شنبه ', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(27, 305, NULL, 40, 'نامشخص', 'آمار و احتمال ');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(27, 'یک شنبه ', '14:00', '16:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(27, 'سه شنبه ', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(28, 205, '2025-10-17T08:00:00', 40, 'نامشخص', 'ریاضی2');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(28, 'یک شنبه', '18:00', '20:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(28, 'سه شنبه ', '18:00', '20:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(29, 107, NULL, 40, 'نامشخص', 'آشنایی با صنعت کامپیوتر');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(29, 'چهارشننبه', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(30, 107, '2025-10-21T10:00:00', 40, 'نامشخص', 'مبانی');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(30, 'شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(30, 'دوشنبه', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(31, 102, '2025-10-14T08:00:00', 40, 'نامشخص', 'ریاضی1');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(31, 'شنبه', '10:00', '12:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(31, 'دوشنبه', '10:00', '12:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(32, 101, NULL, 40, 'نامشخص', 'فیزیک1');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(32, 'یک شنبه', '08:00', '10:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(32, 'سه شنبه', '08:00', '10:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(33, 106, NULL, 40, 'نامشخص', 'تربیت بدنی ب');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(33, 'یک شنبه', '10:00', '12:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(33, 'یک شنبه', '14:00', '16:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(33, 'یک شنبه', '16:00', '18:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(34, 105, '2025-10-24T08:00:00', 40, 'نامشخص', 'فارسی');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(34, 'یک شنبه', '14:00', '16:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(34, 'دوشنبه', '14:00', '16:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(34, 'دوشنبه', '16:00', '18:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(34, 'سه شنبه', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(35, 103, NULL, 40, 'نامشخص', 'انقلاب ب');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(35, 'دو شنبه', '14:00', '16:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(35, 'سه شنبه', '14:00', '16:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(36, 103, NULL, 40, 'نامشخص', 'انقلاب خ');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(36, 'دوشنبه', '16:00', '18:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(36, 'سه شنبه', '16:00', '18:00', 'نامشخص');

INSERT INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
(37, 106, NULL, 40, 'نامشخص', 'تربیت بدنی خ');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(37, 'دوشنبه', '16:00', '18:00', 'نامشخص');
INSERT INTO section_times (section_id, day, start_time, end_time, location) VALUES
(37, 'سه شنبه', '17:00', '19:00', 'نامشخص');
