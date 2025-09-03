#!/usr/bin/env python
"""
Script to populate the database with sample data for testing
"""
import os
import django
from django.core.management import execute_from_command_line

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'unipath_backend.settings')
django.setup()

from courses.models import Course, Section, SectionTime

def populate_sample_data():
    # Create sample courses
    math_course = Course.objects.create(
        id=1,
        name="Calculus I",
        units=3
    )
    
    physics_course = Course.objects.create(
        id=2,
        name="Physics I",
        units=4
    )
    
    # Create prerequisites
    math_course.prerequisites.add(physics_course)
    
    # Create sections
    section1 = Section.objects.create(
        course=math_course,
        section_number=1,
        instructor="Dr. Smith",
        capacity=30,
        enrolled=25
    )
    
    # Create section times
    SectionTime.objects.create(
        section=section1,
        day='mon',
        start_time='08:00',
        end_time='09:30',
        location='Room 101'
    )
    
    SectionTime.objects.create(
        section=section1,
        day='wed',
        start_time='08:00',
        end_time='09:30',
        location='Room 101'
    )
    
    print("Sample data populated successfully!")

if __name__ == '__main__':
    populate_sample_data()
