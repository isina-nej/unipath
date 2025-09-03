from rest_framework import viewsets
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from .models import Course, Section, SectionTime
from .serializers import CourseSerializer, SectionSerializer, SectionTimeSerializer

class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['units']
    search_fields = ['name']
    ordering_fields = ['name', 'units']

class SectionViewSet(viewsets.ModelViewSet):
    queryset = Section.objects.all()
    serializer_class = SectionSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['course', 'instructor']
    search_fields = ['course__name', 'instructor']
    ordering_fields = ['section_number', 'capacity']

class SectionTimeViewSet(viewsets.ModelViewSet):
    queryset = SectionTime.objects.all()
    serializer_class = SectionTimeSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['day', 'section__course']
    search_fields = ['location']
    ordering_fields = ['day', 'start_time']
