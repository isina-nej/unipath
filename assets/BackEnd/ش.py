import requests
from persiantools.jdatetime import JalaliDateTime

API_URL = "http://isinanej.pythonanywhere.com/sections"  # آدرس سرور خود را اینجا قرار دهید

def to_jalali_str(dt_str):
    if not dt_str:
        return ""
    try:
        # dt_str: '2025-10-23T10:00:00'
        date_part, time_part = dt_str.split('T')
        y, m, d = map(int, date_part.split('-'))
        jalali = JalaliDateTime.to_jalali(y, m, d)
        return f"{jalali:%Y/%m/%d}T{time_part}"
    except Exception:
        return dt_str

def main():
    # لیست سکشن‌ها و تایم‌ها (داده‌ها را کامل وارد کنید)
    sections = [
        {"id": 5, "course_id": 701, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آز نرم افزار"},
        {"id": 6, "course_id": 803, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آز شبکه"},
        {"id": 7, "course_id": 705, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آز ریزپردازنده"},
        {"id": 8, "course_id": 606, "exam_datetime": "2025-10-23T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "مباث ویژه"},
        {"id": 9, "course_id": 701, "exam_datetime": "2025-10-17T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "م نرم افزار"},
        {"id": 10, "course_id": 704, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آز سیستم عامل"},
        {"id": 11, "course_id": 703, "exam_datetime": "2025-10-21T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "شبکه های کامپیوتری"},
        {"id": 12, "course_id": 706, "exam_datetime": "2025-10-29T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "رباتیکز"},
        {"id": 13, "course_id": 503, "exam_datetime": "2025-10-22T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "پایگاه"},
        {"id": 14, "course_id": 401, "exam_datetime": "2025-10-28T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "طراحی الگوریتم"},
        {"id": 15, "course_id": 501, "exam_datetime": "2025-10-30T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "هوش مصنوعی"},
        {"id": 16, "course_id": 506, "exam_datetime": "2025-10-14T08:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "روش پژوهش"},
        {"id": 17, "course_id": 502, "exam_datetime": "2025-10-24T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "کامپایلر"},
        {"id": 18, "course_id": 604, "exam_datetime": "2025-10-20T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "سیستم عامل"},
        {"id": 19, "course_id": 505, "exam_datetime": "2025-10-16T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "سیگنال و سیستم"},
        {"id": 20, "course_id": 504, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "ریز پردازنده"},
        {"id": 21, "course_id": 303, "exam_datetime": "2025-10-20T08:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "معادلات"},
        {"id": 22, "course_id": 302, "exam_datetime": "2025-10-24T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "مدار منطقی"},
        {"id": 23, "course_id": 201, "exam_datetime": "2025-10-15T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "پیشرفته"},
        {"id": 24, "course_id": 304, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آز فیزیک2"},
        {"id": 25, "course_id": 306, "exam_datetime": "2025-10-22T08:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "زبان تخصصی"},
        {"id": 26, "course_id": 301, "exam_datetime": "2025-10-28T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "ساختمان داده"},
        {"id": 27, "course_id": 305, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آمار و احتمال "},
        {"id": 28, "course_id": 205, "exam_datetime": "2025-10-17T08:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "ریاضی2"},
        {"id": 29, "course_id": 107, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "آشنایی با صنعت کامپیوتر"},
        {"id": 30, "course_id": 107, "exam_datetime": "2025-10-21T10:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "مبانی"},
        {"id": 31, "course_id": 102, "exam_datetime": "2025-10-14T08:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "ریاضی1"},
        {"id": 32, "course_id": 101, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "فیزیک1"},
        {"id": 33, "course_id": 106, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "تربیت بدنی ب"},
        {"id": 34, "course_id": 105, "exam_datetime": "2025-10-24T08:00:00", "capacity": 40, "instructor_name": "نامشخص", "description": "فارسی"},
        {"id": 35, "course_id": 103, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "انقلاب ب"},
        {"id": 36, "course_id": 103, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "انقلاب خ"},
        {"id": 37, "course_id": 106, "exam_datetime": None, "capacity": 40, "instructor_name": "نامشخص", "description": "تربیت بدنی خ"}
    ]
    section_times = [
        {"id": 6, "section_id": 5, "day": "شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 7, "section_id": 6, "day": "شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 8, "section_id": 7, "day": "شنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 9, "section_id": 8, "day": "شنبه", "start_time": "18:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 10, "section_id": 8, "day": "یک شنبه", "start_time": "18:20", "end_time": "20:00", "location": "نامشخص"},
        {"id": 11, "section_id": 9, "day": "یک شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 12, "section_id": 9, "day": "سه شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 13, "section_id": 10, "day": "یک شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 14, "section_id": 11, "day": "دوشنبه", "start_time": "16:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 15, "section_id": 12, "day": "سه شنبه", "start_time": "16:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 16, "section_id": 13, "day": "شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 17, "section_id": 13, "day": "چهارشنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 18, "section_id": 14, "day": "شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 19, "section_id": 14, "day": "دوشنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 20, "section_id": 15, "day": "یک شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 21, "section_id": 15, "day": "سه شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 22, "section_id": 16, "day": "یک شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 23, "section_id": 17, "day": "یک شنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 24, "section_id": 17, "day": "سه شنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 25, "section_id": 18, "day": "یک شنبه", "start_time": "18:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 26, "section_id": 18, "day": "سه شنبه", "start_time": "18:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 27, "section_id": 19, "day": "دو شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 28, "section_id": 19, "day": "سه شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 29, "section_id": 20, "day": "دو شنبه", "start_time": "14:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 30, "section_id": 21, "day": "شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 31, "section_id": 21, "day": "دوشنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 32, "section_id": 22, "day": "شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 33, "section_id": 22, "day": "سه شنبه ", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 34, "section_id": 23, "day": "شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 35, "section_id": 23, "day": "دوشنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 36, "section_id": 24, "day": "شنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 37, "section_id": 24, "day": "یک شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 38, "section_id": 24, "day": "دوشنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 39, "section_id": 25, "day": "شنبه", "start_time": "18:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 40, "section_id": 26, "day": "یک شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 41, "section_id": 26, "day": "سه شنبه ", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 42, "section_id": 27, "day": "یک شنبه ", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 43, "section_id": 27, "day": "سه شنبه ", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 44, "section_id": 28, "day": "یک شنبه", "start_time": "18:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 45, "section_id": 28, "day": "سه شنبه ", "start_time": "18:00", "end_time": "20:00", "location": "نامشخص"},
        {"id": 46, "section_id": 29, "day": "چهارشننبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 47, "section_id": 30, "day": "شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 48, "section_id": 30, "day": "دوشنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 49, "section_id": 31, "day": "شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 50, "section_id": 31, "day": "دوشنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 51, "section_id": 32, "day": "یک شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 52, "section_id": 32, "day": "سه شنبه", "start_time": "08:00", "end_time": "10:00", "location": "نامشخص"},
        {"id": 53, "section_id": 33, "day": "یک شنبه", "start_time": "10:00", "end_time": "12:00", "location": "نامشخص"},
        {"id": 54, "section_id": 33, "day": "یک شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 55, "section_id": 33, "day": "یک شنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 56, "section_id": 34, "day": "یک شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 57, "section_id": 34, "day": "دوشنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 58, "section_id": 34, "day": "دوشنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 59, "section_id": 34, "day": "سه شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 60, "section_id": 35, "day": "دو شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 61, "section_id": 35, "day": "سه شنبه", "start_time": "14:00", "end_time": "16:00", "location": "نامشخص"},
        {"id": 62, "section_id": 36, "day": "دوشنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 63, "section_id": 36, "day": "سه شنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 64, "section_id": 37, "day": "دوشنبه", "start_time": "16:00", "end_time": "18:00", "location": "نامشخص"},
        {"id": 65, "section_id": 37, "day": "سه شنبه", "start_time": "17:00", "end_time": "19:00", "location": "نامشخص"}
    ]

    # ساخت دیکشنری section_id به لیست تایم‌ها
    times_map = {}
    for t in section_times:
        sid = t['section_id']
        if sid not in times_map:
            times_map[sid] = []
        # حذف id از هر تایم
        t_copy = t.copy()
        t_copy.pop('id', None)
        t_copy.pop('section_id', None)
        times_map[sid].append(t_copy)

    # ارسال هر سکشن با تایم‌هایش به API
    for s in sections:
        section_data = {
            "course_id": s["course_id"],
            "exam_datetime": to_jalali_str(s["exam_datetime"]),
            "capacity": s["capacity"],
            "instructor_name": s["instructor_name"],
            "description": s["description"],
            "times": times_map.get(s["id"], [])
        }
        resp = requests.post(API_URL, json=section_data)
        print(f"Section {s['id']} status: {resp.status_code}", resp.json())

if __name__ == "__main__":
    main()