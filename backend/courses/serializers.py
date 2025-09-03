from rest_framework import serializers
from .models import Course, Section, SectionTime

class SectionTimeSerializer(serializers.ModelSerializer):
    class Meta:
        model = SectionTime
        fields = '__all__'

class SectionSerializer(serializers.ModelSerializer):
    times = SectionTimeSerializer(many=True, read_only=True)
    
    class Meta:
        model = Section
        fields = '__all__'

class CourseSerializer(serializers.ModelSerializer):
    prerequisites = serializers.PrimaryKeyRelatedField(many=True, queryset=Course.objects.all())
    corequisites = serializers.PrimaryKeyRelatedField(many=True, queryset=Course.objects.all())
    sections = SectionSerializer(many=True, read_only=True)
    
    class Meta:
        model = Course
        fields = '__all__'
