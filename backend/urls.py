from django.conf import settings
from django.urls import path

from backend import views
from backend.views import CouponUpdateView, CouponCreateView, CustomerDetailView, CustomerCreateView

urlpatterns = [
    path('websocketTest/', views.WebsocketTestView, name='websocket_test_view'),
    path('event/get/', views.EventDetailView.as_view(), name='event_getEvent'),
    path('event/', views.EventInfoView.as_view(), name='event_Event'),
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