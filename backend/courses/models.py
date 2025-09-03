from django.db import models

class Course(models.Model):
    id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=200)
    units = models.IntegerField()
    prerequisites = models.ManyToManyField('self', blank=True, symmetrical=False, related_name='prereq_for')
    corequisites = models.ManyToManyField('self', blank=True, symmetrical=False, related_name='coreq_for')

    def __str__(self):
        return self.name

class Section(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE)
    section_number = models.IntegerField()
    instructor = models.CharField(max_length=100, blank=True)
    capacity = models.IntegerField(default=0)
    enrolled = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.course.name} - Section {self.section_number}"

class SectionTime(models.Model):
    DAYS_CHOICES = [
        ('sat', 'Saturday'),
        ('sun', 'Sunday'),
        ('mon', 'Monday'),
        ('tue', 'Tuesday'),
        ('wed', 'Wednesday'),
        ('thu', 'Thursday'),
        ('fri', 'Friday'),
    ]
    
    section = models.ForeignKey(Section, on_delete=models.CASCADE)
    day = models.CharField(max_length=3, choices=DAYS_CHOICES)
    start_time = models.TimeField()
    end_time = models.TimeField()
    location = models.CharField(max_length=100, blank=True)

    def __str__(self):
        return f"{self.section} - {self.day} {self.start_time}-{self.end_time}"
