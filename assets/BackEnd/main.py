from flask import Flask, request, jsonify, abort
from flask_cors import CORS
import os
import sqlite3
from functools import wraps
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from db_management import db_management_app

app = Flask(__name__)
CORS(app)

# Set up rate limiting
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

# Error handlers
@app.errorhandler(400)
def bad_request_error(error):
    return jsonify({"error": "Bad request", "message": str(error)}), 400

@app.route('/')
def home():
    return jsonify({"message": "Welcome to the UniPath API"})

@app.errorhandler(404)
def not_found_error(error):
    return jsonify({"error": "Resource not found"}), 404

@app.errorhandler(429)
def ratelimit_handler(error):
    return jsonify({"error": "Rate limit exceeded", "message": str(error)}), 429

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error", "message": str(error)}), 500

# Register the db_management blueprint
app.register_blueprint(db_management_app, url_prefix='/db')

# Update paths to be environment-independent
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'unipath.db')
INIT_SQL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'init.sql')

# Add init_app function for proper application setup
def init_app(app):
    if not os.path.exists(DB_PATH):
        with sqlite3.connect(DB_PATH) as conn:
            with open(INIT_SQL_PATH, encoding='utf-8') as f:
                sql = f.read()
            conn.executescript(sql)
    return app

# Initialize the app
init_app(app)

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def validate_section_data(data, is_update=False):
    # فیلدهای اجباری
    required_keys = ['capacity', 'times']
    if not is_update:
        required_keys.append('course_id')
    
    # فیلدهای اختیاری با مقادیر پیش‌فرض
    data.setdefault('exam_datetime', '')
    data.setdefault('instructor_name', '')
    data.setdefault('description', '')
    
    missing_keys = [key for key in required_keys if key not in data]
    if missing_keys:
        return False, f"Missing required fields: {', '.join(missing_keys)}"
    
    if not isinstance(data['capacity'], int) or data['capacity'] < 0:
        return False, "Capacity must be a positive integer"
    
    if not isinstance(data['times'], list) or not data['times']:
        return False, "Times must be a non-empty list"
    for t in data['times']:
        # اضافه کردن مقدار پیش‌فرض برای location
        t.setdefault('location', '')
        
        # چک کردن فیلدهای اجباری زمان کلاس
        required_time_keys = ['day', 'start_time', 'end_time']
        if not all(key in t for key in required_time_keys):
            return False, "Each time slot must have day, start_time, and end_time"
            
    return True, ""

def db_transaction(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        conn = get_db()
        cur = conn.cursor()
        try:
            result = f(conn, cur, *args, **kwargs)
            conn.commit()
            return result
        except sqlite3.Error as e:
            conn.rollback()
            return jsonify({"error": "Database error", "message": str(e)}), 500
        finally:
            conn.close()
    return decorated_function

@app.route('/sections/<int:section_id>', methods=['GET'])
@limiter.limit("100/minute")
@db_transaction
def get_section_with_times(conn, cur, section_id):
    cur.execute("SELECT * FROM sections WHERE id = ?", (section_id,))
    section = cur.fetchone()
    if not section:
        return jsonify({"error": "Section not found"}), 404
        
    cur.execute("SELECT * FROM section_times WHERE section_id = ? ORDER BY day, start_time", (section_id,))
    times = [dict(row) for row in cur.fetchall()]
    
    result = dict(section)
    result['times'] = times
    return jsonify(result)

@app.route('/sections', methods=['POST'])
@limiter.limit("30/minute")
@db_transaction
def insert_section_with_times(conn, cur):
    data = request.json
    if not data:
        return jsonify({"error": "Invalid input"}), 400

    is_valid, message = validate_section_data(data)
    if not is_valid:
        return jsonify({"error": message}), 400

    # Check if course exists
    cur.execute("SELECT id FROM courses_computer WHERE id = ?", (data['course_id'],))
    if not cur.fetchone():
        return jsonify({"error": "Course not found"}), 404

    try:
        cur.execute(
            """
            INSERT INTO sections (course_id, exam_datetime, capacity, instructor_name, description)
            VALUES (?, ?, ?, ?, ?)
            """,
            (data['course_id'], data['exam_datetime'], data['capacity'], data['instructor_name'], data['description'])
        )
        section_id = cur.lastrowid

        for t in data['times']:
            cur.execute(
                """
                INSERT INTO section_times (section_id, day, start_time, end_time, location)
                VALUES (?, ?, ?, ?, ?)
                """,
                (section_id, t['day'], t['start_time'], t['end_time'], t['location'])
            )
        
        return jsonify({
            "section_id": section_id,
            "message": "Section created successfully"
        }), 201

    except sqlite3.Error as e:
        if "FOREIGN KEY constraint failed" in str(e):
            return jsonify({"error": "Invalid course_id"}), 400
        raise

@app.route('/sections/<int:section_id>', methods=['PUT'])
@limiter.limit("30/minute")
@db_transaction
def update_section_with_times(conn, cur, section_id):
    data = request.json
    if not data:
        return jsonify({"error": "Invalid input"}), 400

    is_valid, message = validate_section_data(data, is_update=True)
    if not is_valid:
        return jsonify({"error": message}), 400

    # Check if section exists
    cur.execute("SELECT id FROM sections WHERE id = ?", (section_id,))
    if not cur.fetchone():
        return jsonify({"error": "Section not found"}), 404

    try:
        cur.execute(
            """
            UPDATE sections 
            SET exam_datetime = ?, capacity = ?, instructor_name = ?, description = ?
            WHERE id = ?
            """,
            (data['exam_datetime'], data['capacity'], data['instructor_name'], 
             data['description'], section_id)
        )
        
        cur.execute("DELETE FROM section_times WHERE section_id = ?", (section_id,))
        
        for t in data['times']:
            cur.execute(
                """
                INSERT INTO section_times (section_id, day, start_time, end_time, location)
                VALUES (?, ?, ?, ?, ?)
                """,
                (section_id, t['day'], t['start_time'], t['end_time'], t['location'])
            )

        return jsonify({
            "message": "Section updated successfully",
            "section_id": section_id
        }), 200

    except sqlite3.Error as e:
        if "FOREIGN KEY constraint failed" in str(e):
            return jsonify({"error": "Invalid course_id"}), 400
        raise

@app.route('/sections/<int:section_id>', methods=['DELETE'])
@limiter.limit("30/minute")
@db_transaction
def delete_section_with_times(conn, cur, section_id):
    # Check if section exists
    cur.execute("SELECT id FROM sections WHERE id = ?", (section_id,))
    if not cur.fetchone():
        return jsonify({"error": "Section not found"}), 404

    cur.execute("DELETE FROM section_times WHERE section_id = ?", (section_id,))
    cur.execute("DELETE FROM sections WHERE id = ?", (section_id,))
    
    return jsonify({
        "message": "Section deleted successfully",
        "section_id": section_id
    }), 200

def clean_database():
    """Clean up orphaned records in the database"""
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()

        # Delete section_times without a valid section
        cur.execute("""
            DELETE FROM section_times 
            WHERE section_id NOT IN (SELECT id FROM sections)
        """)

        # Delete sections without any section_times
        cur.execute("""
            DELETE FROM sections 
            WHERE id NOT IN (SELECT DISTINCT section_id FROM section_times)
        """)

        # Delete sections referencing non-existent courses
        cur.execute("""
            DELETE FROM sections 
            WHERE course_id NOT IN (SELECT id FROM courses_computer)
        """)

        conn.commit()
        
    except sqlite3.Error as e:
        print(f"Error cleaning database: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            conn.close()

@app.before_request
def before_request():
    """Run database cleanup before each request"""
    if not request.path.startswith('/static'):
        clean_database()

@app.route('/all_university_data', methods=['GET'])
@limiter.limit("10/minute")  # More restrictive limit for this heavy endpoint
def get_all_university_data():
    conn = None
    try:
        conn = get_db()
        cur = conn.cursor()

        # Get all courses with their full details
        cur.execute("""
            SELECT * FROM courses_computer 
            ORDER BY id
        """)
        courses = [dict(row) for row in cur.fetchall()]

        # Get all prerequisites with course details
        cur.execute("""
            SELECT p.*, c.course_name as prerequisite_name 
            FROM course_computer_prerequisites p
            LEFT JOIN courses_computer c ON c.id IN (
                p.prerequisite_1, p.prerequisite_2, p.prerequisite_3
            )
            ORDER BY p.course_id
        """)
        prerequisites = [dict(row) for row in cur.fetchall()]

        # Get all corequisites with course details
        cur.execute("""
            SELECT co.*, c.course_name as corequisite_name
            FROM course_computer_corequisites co
            LEFT JOIN courses_computer c ON c.id IN (
                co.corequisites_1, co.corequisites_2, co.corequisites_3
            )
            ORDER BY co.course_id
        """)
        corequisites = [dict(row) for row in cur.fetchall()]

        # Get all sections with their times efficiently
        cur.execute("""
            SELECT s.*, 
                   GROUP_CONCAT(t.day || ',' || t.start_time || ',' || 
                              t.end_time || ',' || t.location, ';') as times
            FROM sections s
            LEFT JOIN section_times t ON s.id = t.section_id
            GROUP BY s.id
            ORDER BY s.course_id, s.exam_datetime
        """)
        sections = []
        for row in cur.fetchall():
            section = dict(row)
            if section['times']:
                times_data = []
                for time_str in section['times'].split(';'):
                    day, start, end, loc = time_str.split(',')
                    times_data.append({
                        'day': day,
                        'start_time': start,
                        'end_time': end,
                        'location': loc
                    })
                section['times'] = times_data
            else:
                section['times'] = []
            sections.append(section)

        # Create a complete course map with all relations
        course_map = {}
        for course in courses:
            course_id = course['id']
            
            course_map[course_id] = {
                'course': course,
                'prerequisites': [p for p in prerequisites if p['course_id'] == course_id],
                'corequisites': [c for c in corequisites if c['course_id'] == course_id],
                'sections': [s for s in sections if s['course_id'] == course_id],
                'dependent_courses': [
                    p for p in prerequisites
                    if p.get('prerequisite_1') == course_id
                    or p.get('prerequisite_2') == course_id
                    or p.get('prerequisite_3') == course_id
                ],
                'corequisite_dependents': [
                    c for c in corequisites
                    if c.get('corequisites_1') == course_id
                    or c.get('corequisites_2') == course_id
                    or c.get('corequisites_3') == course_id
                ]
            }
        
        return jsonify({
            'course_map': course_map,
            'raw_data': {
                'courses': courses,
                'prerequisites': prerequisites,
                'corequisites': corequisites,
                'sections': sections
            }
        }), 200

    except sqlite3.Error as e:
        return jsonify({
            "error": "Database error", 
            "message": str(e)
        }), 500
    finally:
        if conn:
            conn.close()

@app.route('/sections', methods=['GET'])
@limiter.limit("100/minute")
@db_transaction
def get_sections(conn, cur):
    try:
        page = max(1, request.args.get('page', 1, type=int))
        per_page = min(50, max(1, request.args.get('per_page', 10, type=int)))
        course_id = request.args.get('course_id', type=int)
        
        offset = (page - 1) * per_page
        
        # Base query
        count_query = "SELECT COUNT(*) FROM sections"
        sections_query = "SELECT * FROM sections"
        
        # Add course filter if specified
        params = []
        if course_id:
            count_query += " WHERE course_id = ?"
            sections_query += " WHERE course_id = ?"
            params.append(course_id)
        
        # Get total count
        cur.execute(count_query, params)
        total = cur.fetchone()[0]
        
        # Add pagination and ordering
        sections_query += " ORDER BY course_id, exam_datetime LIMIT ? OFFSET ?"
        params.extend([per_page, offset])
        
        cur.execute(sections_query, params)
        sections = [dict(row) for row in cur.fetchall()]
        
        # Get times for all sections in this page efficiently
        section_ids = [s['id'] for s in sections]
        if section_ids:
            placeholders = ','.join('?' * len(section_ids))
            cur.execute(
                f"""
                SELECT * FROM section_times 
                WHERE section_id IN ({placeholders})
                ORDER BY day, start_time
                """, 
                section_ids
            )
            times = [dict(row) for row in cur.fetchall()]
            
            # Group times by section
            for section in sections:
                section['times'] = [t for t in times if t['section_id'] == section['id']]
        
        return jsonify({
            "data": sections,
            "total": total,
            "page": page,
            "per_page": per_page,
            "total_pages": (total + per_page - 1) // per_page,
            "has_next": offset + per_page < total,
            "has_prev": page > 1
        })
    except sqlite3.Error as e:
        return jsonify({"error": "Database error", "message": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
