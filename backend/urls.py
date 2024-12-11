from django.conf import settings
from django.urls import path

from backend import views
from backend.views import CouponUpdateView, CouponCreateView, CustomerDetailView, CustomerCreateView

urlpatterns = [
    path('websocketTest/', views.WebsocketTestView, name='websocket_test_view'),
    path('event/getEvent/', views.EventDetailView.as_view(), name='get_one_event'),
    path('manage/createEvent/', views.EventInfoView.as_view(), name='create_event'),
    path('event/listAll/', views.EventInfoView.as_view(), name='get_all_events'),
    path('user/listCoupons/', views.CouponGetView.as_view(), name='coupon_get_view'),
    ## Coupon Testing
    path('user/coupon/<int:id>/', CouponUpdateView.as_view(), name='coupon-update'),
    path('user/coupon/', CouponCreateView.as_view(), name='coupon-create'),
    # Customer Testing
    path('user/create/', CustomerCreateView.as_view(), name='customer-create'),
    path('user/create/<int:id>/', CustomerDetailView.as_view(), name='customer-update-delete-retrieve'),
    # Employee Testing
    path('manager/create/', CustomerCreateView.as_view(), name='customer-create'),
]