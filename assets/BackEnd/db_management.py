from flask import Blueprint, request, jsonify, render_template_string
from datetime import datetime
import sqlite3
import os
import pandas as pd
from functools import wraps # Import wraps explicitly for db_transaction decorator

# HTML template for the dashboard
HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>داشبورد کاربران</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { font-family: 'Vazirmatn', 'Tahoma', sans-serif; }
        .stats-card { transition: all 0.3s; }
        .stats-card:hover { transform: translateY(-5px); }
    </style>
</head>
<body class="bg-light">
    <div class="container py-4">
        <h1 class="text-center mb-4">داشبورد اطلاعات کاربران</h1>
        
        <div class="row mb-4" id="stats">
            <!-- آمار کلی اینجا قرار می‌گیرد -->
        </div>

        <div class="card shadow">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">لیست بازدیدها</h5>
                <button class="btn btn-primary" onclick="refreshData()">بروزرسانی</button>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped">
                        <thead>                                <tr>
                                <th>شناسه</th>
                                <th>آدرس IP</th>
                                <th>سیستم عامل</th>
                                <th>نوع دستگاه</th>
                                <th>رزولوشن</th>
                                <th>زبان</th>
                                <th>نسخه برنامه</th>
                                <th>نوع اتصال</th>
                                <th>مسیر</th>
                                <th>تاریخ و زمان</th>
                            </tr>
                        </thead>
                        <tbody id="userTable">
                            <!-- داده‌های جدول اینجا قرار می‌گیرد -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function updateStats(data) {
            const uniqueIPs = new Set(data.map(item => item.ip_address)).size;
            const uniquePlatforms = new Set(data.map(item => item.platform)).size;
            
            const stats = `
                <div class="col-md-4">
                    <div class="card bg-primary text-white stats-card">
                        <div class="card-body text-center">
                            <h3>${data.length}</h3>
                            <p class="mb-0">تعداد کل بازدیدها</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-success text-white stats-card">
                        <div class="card-body text-center">
                            <h3>${uniqueIPs}</h3>
                            <p class="mb-0">تعداد IP های یکتا</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-info text-white stats-card">
                        <div class="card-body text-center">                                <h3>${uniquePlatforms}</h3>
                            <p class="mb-0">تعداد دستگاه‌های مختلف</p>
                        </div>
                    </div>
                </div>
            `;
            document.getElementById('stats').innerHTML = stats;
        }

        function updateTable(data) {                         const rows = data.map(item => `
                <tr>
                    <td>${item.id}</td>
                    <td>${item.ip_address}</td>
                    <td>${item.platform}</td>
                    <td>${item.device_type}</td>
                    <td>${item.screen_resolution}</td>
                    <td>${item.language}</td>
                    <td>${item.app_version}</td>
                    <td>${item.connection_type}</td>
                    <td>${item.route_accessed}</td>
                    <td>${item.timestamp}</td>
                </tr>
            `).join('');
            document.getElementById('userTable').innerHTML = rows;
        }         function refreshData() {
            fetch('/db/all_users_info')
                .then(response => response.json())
                .then(data => {
                    updateStats(data);
                    updateTable(data);
                });
        }

        // بروزرسانی اولیه
        refreshData();

        // بروزرسانی خودکار هر 30 ثانیه
        setInterval(refreshData, 30000);
    </script>
</body>
</html>
"""

db_management_app = Blueprint('db_management', __name__)

# Update path to be environment-independent
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'unipath.db')

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def _execute_sql_script(conn, sql_script):
    """Helper function to execute a multi-line SQL script."""
    cur = conn.cursor()
    cur.executescript(sql_script)
    conn.commit()

@db_management_app.route('/add_table', methods=['POST'])
def add_table():
    data = request.json
    if not data or 'table_name' not in data or 'columns' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']
    columns = data['columns']  # Example: "id INTEGER PRIMARY KEY, name TEXT"

    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(f"CREATE TABLE {table_name} ({columns})")
        conn.commit()
        return jsonify({'status': 'Table created successfully'})
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/edit_table', methods=['POST'])
def edit_table():
    data = request.json
    if not data or 'table_name' not in data or 'alter_query' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']
    alter_query = data['alter_query']  # Example: "ADD COLUMN age INTEGER"

    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(f"ALTER TABLE {table_name} {alter_query}")
        conn.commit()
        return jsonify({'status': 'Table altered successfully'})
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/add_data', methods=['POST'])
def add_data():
    data = request.json
    if not data or 'table_name' not in data or 'values' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']
    values = data['values']  # Example: {"name": "John", "age": 30}

    columns = ', '.join(values.keys())
    placeholders = ', '.join(['?' for _ in values])
    values_list = list(values.values())

    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})", values_list)
        conn.commit()
        return jsonify({'status': 'Data added successfully'})
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/edit_data', methods=['POST'])
def edit_data():
    data = request.json
    if not data or 'table_name' not in data or 'update_query' not in data or 'conditions' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']
    update_query = data['update_query']  # Example: "name = 'Jane', age = 25"
    conditions = data['conditions']  # Example: "id = 1"

    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(f"UPDATE {table_name} SET {update_query} WHERE {conditions}")
        conn.commit()
        return jsonify({'status': 'Data updated successfully'})
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/delete', methods=['POST'])
def delete():
    data = request.json
    if not data or 'table_name' not in data or 'conditions' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']
    conditions = data['conditions']  # Example: "id = 1"

    conn = get_db()
    cur = conn.cursor()
    try:
        if table_name == 'sections':
            # Extract section_id from conditions
            # This is a simplistic parse; a more robust solution would use parameterized queries
            # or ensure conditions are passed as dicts for safety.
            try:
                section_id = conditions.split('=')[1].strip()
                # Delete related section_times
                cur.execute("DELETE FROM section_times WHERE section_id = ?", (section_id,))
            except IndexError:
                # If conditions are not in 'id = X' format, just proceed with main delete
                pass
        
        # Delete from the main table
        cur.execute(f"DELETE FROM {table_name} WHERE {conditions}")
        conn.commit()
        return jsonify({'status': 'Data deleted successfully'})
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/list_tables', methods=['GET'])
def list_tables():
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row['name'] for row in cur.fetchall()]
        return jsonify(tables)
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/get_table_data', methods=['POST'])
def get_table_data():
    data = request.json
    if not data or 'table_name' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']

    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(f"SELECT * FROM {table_name}")
        rows = [dict(row) for row in cur.fetchall()]
        return jsonify(rows)
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/update_table_data', methods=['POST'])
def update_table_data():
    data = request.json
    if not data or 'table_name' not in data or 'data' not in data:
        return jsonify({'error': 'Invalid input'}), 400

    table_name = data['table_name']
    rows = data['data']

    conn = get_db()
    cur = conn.cursor()
    try:
        for row in rows:
            keys = ', '.join([f"{key} = ?" for key in row.keys() if key != 'id'])
            values = [value for key, value in row.items() if key != 'id']
            values.append(row['id'])
            cur.execute(f"UPDATE {table_name} SET {keys} WHERE id = ?", values)
        conn.commit()
        return jsonify({'status': 'Table data updated successfully'})
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

# Create users_info table if not exists
def create_users_info_table():
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute('''
            CREATE TABLE IF NOT EXISTS users_info (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ip_address TEXT,
                platform TEXT,
                device_type TEXT,
                screen_resolution TEXT,
                language TEXT,
                app_version TEXT,
                user_agent TEXT,
                connection_type TEXT,
                timestamp TEXT,
                route_accessed TEXT
            )
        ''')
        conn.commit()
    except sqlite3.Error as e:
        print(f"Error creating users_info table: {e}")
    finally:
        conn.close()

def create_required_tables():
    """
    Ensures all necessary tables for the courses and sections data are present.
    This function creates tables if they don't exist, but does NOT populate initial data.
    Initial data population is handled by init.sql on application startup.
    """
    conn = get_db()
    try:
        schema_sql = """
            CREATE TABLE IF NOT EXISTS courses_computer (
                id INT PRIMARY KEY,
                course_name VARCHAR(255) NOT NULL,
                number_unit INT
            );

            CREATE TABLE IF NOT EXISTS course_computer_prerequisites (
                course_id INT PRIMARY KEY,
                prerequisite_1 INT,
                prerequisite_2 INT,
                prerequisite_3 INT
            );

            CREATE TABLE IF NOT EXISTS course_computer_corequisites (
                course_id INT PRIMARY KEY,
                corequisites_1 INT,
                corequisites_2 INT,
                corequisites_3 INT
            );

            CREATE TABLE IF NOT EXISTS course_requirements (
                course_id INT PRIMARY KEY,
                min_passed_units INT
            );

            CREATE TABLE IF NOT EXISTS sections (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                course_id INT NOT NULL,
                exam_datetime DATETIME,
                capacity INT NOT NULL,
                instructor_name VARCHAR(255) NOT NULL,
                description TEXT,
                FOREIGN KEY(course_id) REFERENCES courses_computer(id)
            );

            CREATE TABLE IF NOT EXISTS section_times (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                section_id INT NOT NULL,
                day VARCHAR(20) NOT NULL,
                start_time VARCHAR(5) NOT NULL,
                end_time VARCHAR(5) NOT NULL,
                location VARCHAR(255),
                FOREIGN KEY(section_id) REFERENCES sections(id)
            );
        """
        _execute_sql_script(conn, schema_sql)
    except sqlite3.Error as e:
        print(f"Error creating tables: {e}")
        raise e
    finally:
        conn.close()

@db_management_app.route('/user_info', methods=['GET'])
def get_user_info():
    user_info = {
        'ip_address': request.remote_addr,
        'platform': request.user_agent.platform or 'Unknown',
        'device_type': request.user_agent.string.split('(')[1].split(')')[0] if '(' in request.user_agent.string else 'Unknown',
        'screen_resolution': request.headers.get('Sec-CH-UA-Mobile', 'Unknown'),
        'language': request.headers.get('Accept-Language', 'Unknown'),
        'app_version': request.headers.get('User-Agent', '').split('Version/')[1].split(' ')[0] if 'Version/' in request.headers.get('User-Agent', '') else 'Unknown',
        'user_agent': str(request.user_agent),
        'connection_type': request.headers.get('Connection', 'Unknown'),
        'timestamp': str(datetime.now()),
        'route_accessed': request.path
    }
    
    # Create table if not exists
    create_users_info_table()
      # Save to database
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute('''
            INSERT INTO users_info 
            (ip_address, platform, device_type, screen_resolution, language, 
            app_version, user_agent, connection_type, timestamp, route_accessed)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            user_info['ip_address'],
            user_info['platform'],
            user_info['device_type'],
            user_info['screen_resolution'],
            user_info['language'],
            user_info['app_version'],
            user_info['user_agent'],
            user_info['connection_type'],
            user_info['timestamp'],
            user_info['route_accessed']
        ))
        conn.commit()
    except sqlite3.Error as e:
        print(f"Error saving user info: {e}")
    finally:
        conn.close()
    
    return jsonify(user_info)

@db_management_app.route('/all_users_info', methods=['GET'])
def get_all_users_info():
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute('SELECT * FROM users_info')
        rows = [dict(row) for row in cur.fetchall()]
        return jsonify(rows)
    except sqlite3.Error as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@db_management_app.route('/users_dashboard', methods=['GET'])
def users_dashboard():
    return render_template_string(HTML_TEMPLATE)

@db_management_app.route('/import_excel', methods=['POST'])
def import_excel():
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
        
    file = request.files['file']
    if not file or not getattr(file, 'filename', None):
        return jsonify({'error': 'No file selected'}), 400
        
    filename = file.filename
    if not filename or not filename.endswith('.xlsx'):
        return jsonify({'error': 'File must be an Excel file (.xlsx)'}), 400

    conn = None
    try:
        # NOTE: This function is designed to read Excel files and assumes a specific schema.
        # If you intend to import data from Excel into the new, unified schema (courses_computer, sections, section_times),
        # this function will need significant modification to match the new table structures and column names.
        # For now, it remains as per your original code for Excel import,
        # but the /db/add_additional_sections endpoint is for the SQL data.

        # Read Excel file
        df = pd.read_excel(file)
        
        # Print column names for debugging
        print("Excel columns:", df.columns.tolist())
        
        conn = get_db()
        cur = conn.cursor()
        
        # Process each row
        for _, row in df.iterrows():
            # First create the course
            # This part of `import_excel` needs to be reconsidered if you solely use courses_computer.
            # Assuming 'courses' table was meant to be 'courses_computer' for this import path.
            # This logic will need careful adjustment if courses are already in courses_computer.
            
            # Attempt to find course_id from courses_computer based on name
            course_name = str(row['اسم درس 1'])
            cur.execute("SELECT id FROM courses_computer WHERE course_name = ?", (course_name,))
            course_result = cur.fetchone()

            if course_result:
                course_id = course_result[0]
            else:
                # If course not found, skip or handle as error.
                # For this context, let's skip sections if course doesn't exist.
                print(f"Skipping row for unknown course: {course_name}")
                continue

            # Define all possible section combinations
            sections_from_excel = [ # Renamed to avoid conflict with `sections` table name
                ('روز سکشن1', 'ساعت شروع سکشن یک', 'ساعت پایان سکشن1'),
                ('روز سکشن 2', 'ساعت شروع سکشن 2', 'ساعت پایان سکشن2'),
                ('روز سکشن 3', 'ساعت شروع سکشن 3', 'ساعت پایان سکشن 3'),
                ('روز سکشن 4', 'ساعت شروع سکشن4', 'ساعت پایان سکشن4')
            ]
            
            # Add sections (into the 'sections' table as defined globally)
            # This logic will need to be adapted to match the `sections` table fields like capacity, instructor_name etc.
            # Currently it only imports day, start_time, end_time.
            
            # Prepare section data for the `sections` table
            exam_date_str = str(row['تاریخ امتحان']) if pd.notna(row['تاریخ امتحان']) else None
            exam_time_str = str(row['ساعت شروع امتحان']) if pd.notna(row['ساعت شروع امتحان']) else None
            
            # Combine date and time for exam_datetime if both exist
            exam_datetime_combined = None
            if exam_date_str and exam_time_str:
                # Assuming date format is MM/DD (e.g., 10/23) and time is HH:MM (e.g., 10:00)
                # Need to add a year for datetime. Let's assume current year 2025.
                try:
                    # Example: 10/23 -> 2025-10-23
                    year = datetime.now().year # Or specify 2025 if all CSV data is for 2025
                    month, day = map(int, exam_date_str.split('/'))
                    exam_datetime_combined = f"{year}-{month:02d}-{day:02d}T{exam_time_str}:00"
                except ValueError:
                    exam_datetime_combined = None # Invalid date/time format

            section_main_data = {
                'course_id': course_id,
                'exam_datetime': exam_datetime_combined,
                'capacity': 40, # Default capacity, as not in CSV
                'instructor_name': 'نامشخص', # Default, as not in CSV
                'description': course_name # Use course name as description for simplicity
            }

            cur.execute('''
                INSERT INTO sections (course_id, exam_datetime, capacity, instructor_name, description)
                VALUES (?, ?, ?, ?, ?)
            ''', (section_main_data['course_id'], section_main_data['exam_datetime'],
                  section_main_data['capacity'], section_main_data['instructor_name'],
                  section_main_data['description']))
            
            current_section_id = cur.lastrowid # Get the ID of the newly inserted section

            # Add section_times for this section
            for day_col, start_col, end_col in sections_from_excel:
                try:
                    if pd.notna(row[day_col]) and pd.notna(row[start_col]) and pd.notna(row[end_col]):
                        section_time_data = {
                            'section_id': current_section_id,
                            'day': str(row[day_col]).strip(),
                            'start_time': str(row[start_col]).strip(),
                            'end_time': str(row[end_col]).strip(),
                            'location': 'نامشخص' # Default location, as not in CSV
                        }
                        
                        cur.execute('''
                            INSERT INTO section_times (section_id, day, start_time, end_time, location)
                            VALUES (?, ?, ?, ?, ?)
                        ''', (section_time_data['section_id'], section_time_data['day'],
                              section_time_data['start_time'], section_time_data['end_time'],
                              section_time_data['location']))
                except KeyError:
                    # Skip if column doesn't exist
                    continue
        
        conn.commit()
        return jsonify({'status': 'Success', 'message': 'Data imported successfully from Excel'})
        
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"Error during import from Excel: {str(e)}")  # Add debug print
        return jsonify({'error': str(e)}), 500
    finally:
        if conn:
            conn.close()

@db_management_app.route('/db/add_additional_sections', methods=['POST'])
def add_additional_sections():
    """
    Adds new sections data (from CSV conversion provided previously) to the database.
    This endpoint is designed to be called after the initial schema and static data
    have been loaded via init.sql. It prevents re-inserting existing sections.
    """
    conn = get_db()
    try:
        cur = conn.cursor()

        # Check if sections table already contains these additional sections (e.g., section ID 5 exists)
        cur.execute("SELECT id FROM sections WHERE id = 5")
        if cur.fetchone():
            return jsonify({'status': 'Skipped', 'message': 'Additional sections already populated.'})

        # SQL inserts for sections with IDs 5 through 37
        # These are generated from the CSV data you provided earlier
        additional_sections_inserts_sql = """
            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (5, 701, NULL, 40, 'نامشخص', 'آز نرم افزار');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (6, 5, 'شنبه', '10:00', '12:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (6, 803, NULL, 40, 'نامشخص', 'آز شبکه');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (7, 6, 'شنبه', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (7, 705, NULL, 40, 'نامشخص', 'آز ریزپردازنده');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (8, 7, 'شنبه', '16:00', '18:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (8, 606, '2025-10-23T10:00:00', 40, 'نامشخص', 'مباث ویژه');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (9, 8, 'شنبه', '18:00', '20:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (10, 8, 'یک شنبه', '18:20', '20:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (9, 701, '2025-10-17T10:00:00', 40, 'نامشخص', 'م نرم افزار');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (11, 9, 'یک شنبه', '10:00', '12:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (12, 9, 'سه شنبه', '10:00', '12:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (10, 704, NULL, 40, 'نامشخص', 'آز سیستم عامل');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (13, 10, 'یک شنبه', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (11, 703, '2025-10-21T10:00:00', 40, 'نامشخص', 'شبکه های کامپیوتری');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (14, 11, 'دوشنبه', '16:00', '20:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (12, 706, '2025-10-29T10:00:00', 40, 'نامشخص', 'رباتیکز');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (15, 12, 'سه شنبه', '16:00', '20:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (13, 503, '2025-10-22T10:00:00', 40, 'نامشخص', 'پایگاه');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (16, 13, 'شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (17, 13, 'چهارشنبه', '10:00', '12:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (14, 401, '2025-10-28T10:00:00', 40, 'نامشخص', 'طراحی الگوریتم');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (18, 14, 'شنبه', '10:00', '12:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (19, 14, 'دوشنبه', '10:00', '12:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (15, 501, '2025-10-30T10:00:00', 40, 'نامشخص', 'هوش مصنوعی');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (20, 15, 'یک شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (21, 15, 'سه شنبه', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (16, 506, '2025-10-14T08:00:00', 40, 'نامشخص', 'روش پژوهش');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (22, 16, 'یک شنبه', '10:00', '12:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (17, 502, '2025-10-24T10:00:00', 40, 'نامشخص', 'کامپایلر');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (23, 17, 'یک شنبه', '16:00', '18:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (24, 17, 'سه شنبه', '16:00', '18:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (18, 604, '2025-10-20T10:00:00', 40, 'نامشخص', 'سیستم عامل');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (25, 18, 'یک شنبه', '18:00', '20:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (26, 18, 'سه شنبه', '18:00', '20:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (19, 505, '2025-10-16T10:00:00', 40, 'نامشخص', 'سیگنال و سیستم');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (27, 19, 'دو شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (28, 19, 'سه شنبه', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (20, 504, NULL, 40, 'نامشخص', 'ریز پردازنده');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (29, 20, 'دو شنبه', '14:00', '18:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (21, 303, '2025-10-20T08:00:00', 40, 'نامشخص', 'معادلات');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (30, 21, 'شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (31, 21, 'دوشنبه', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (22, 302, '2025-10-24T10:00:00', 40, 'نامشخص', 'مدار منطقی');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (32, 22, 'شنبه', '10:00', '12:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (33, 22, 'سه شنبه ', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (23, 201, '2025-10-15T10:00:00', 40, 'نامشخص', 'پیشرفته');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (34, 23, 'شنبه', '14:00', '16:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (35, 23, 'دوشنبه', '16:00', '18:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (24, 304, NULL, 40, 'نامشخص', 'آز فیزیک2');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (36, 24, 'شنبه', '16:00', '18:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (37, 24, 'یک شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (38, 24, 'دوشنبه', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (25, 306, '2025-10-22T08:00:00', 40, 'نامشخص', 'زبان تخصصی');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (39, 25, 'شنبه', '18:00', '20:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (26, 301, '2025-10-28T10:00:00', 40, 'نامشخص', 'ساختمان داده');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (40, 26, 'یک شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (41, 26, 'سه شنبه ', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (27, 305, NULL, 40, 'نامشخص', 'آمار و احتمال ');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (42, 27, 'یک شنبه ', '14:00', '16:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (43, 27, 'سه شنبه ', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (28, 205, '2025-10-17T08:00:00', 40, 'نامشخص', 'ریاضی2');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (44, 28, 'یک شنبه', '18:00', '20:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (45, 28, 'سه شنبه ', '18:00', '20:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (29, 107, NULL, 40, 'نامشخص', 'آشنایی با صنعت کامپیوتر');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (46, 29, 'چهارشننبه', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (30, 107, '2025-10-21T10:00:00', 40, 'نامشخص', 'مبانی');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (47, 30, 'شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (48, 30, 'دوشنبه', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (31, 102, '2025-10-14T08:00:00', 40, 'نامشخص', 'ریاضی1');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (49, 31, 'شنبه', '10:00', '12:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (50, 31, 'دوشنبه', '10:00', '12:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (32, 101, NULL, 40, 'نامشخص', 'فیزیک1');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (51, 32, 'یک شنبه', '08:00', '10:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (52, 32, 'سه شنبه', '08:00', '10:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (33, 106, NULL, 40, 'نامشخص', 'تربیت بدنی ب');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (53, 33, 'یک شنبه', '10:00', '12:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (54, 33, 'یک شنبه', '14:00', '16:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (55, 33, 'یک شنبه', '16:00', '18:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (34, 105, '2025-10-24T08:00:00', 40, 'نامشخص', 'فارسی');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (56, 34, 'یک شنبه', '14:00', '16:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (57, 34, 'دوشنبه', '14:00', '16:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (58, 34, 'دوشنبه', '16:00', '18:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (59, 34, 'سه شنبه', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (35, 103, NULL, 40, 'نامشخص', 'انقلاب ب');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (60, 35, 'دو شنبه', '14:00', '16:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (61, 35, 'سه شنبه', '14:00', '16:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (36, 103, NULL, 40, 'نامشخص', 'انقلاب خ');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (62, 36, 'دوشنبه', '16:00', '18:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (63, 36, 'سه شنبه', '16:00', '18:00', 'نامشخص');

            INSERT OR IGNORE INTO sections (id, course_id, exam_datetime, capacity, instructor_name, description) VALUES
            (37, 106, NULL, 40, 'نامشخص', 'تربیت بدنی خ');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (64, 37, 'دوشنبه', '16:00', '18:00', 'نامشخص');
            INSERT OR IGNORE INTO section_times (id, section_id, day, start_time, end_time, location) VALUES
            (65, 37, 'سه شنبه', '17:00', '19:00', 'نامشخص');
        """
        _execute_sql_script(conn, additional_sections_inserts_sql)
        
        return jsonify({'status': 'Success', 'message': 'Additional sections data populated successfully!'})

    except sqlite3.Error as e:
        if conn:
            conn.rollback()
        print(f"Error during additional sections population: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if conn:
            conn.close()
