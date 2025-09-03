from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'courses', views.CourseViewSet)
router.register(r'sections', views.SectionViewSet)
router.register(r'section-times', views.SectionTimeViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
