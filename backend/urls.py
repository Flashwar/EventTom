from django.shortcuts import render
from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView
from backend.views import LogoutView, EventInfoView, EventDetailView, EventListView, CouponGetView, TicketBookingView, \
    GetUserIdView, GetUserIdFromEmployeeUUID, TicketTypListView

urlpatterns = [

#path('websocketTest/', views.WebsocketTestView, name='websocket_test_view'),
    # login/-out
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('logout/', LogoutView.as_view(), name='logout'),

    # required APIs
    path('event/getEvent/', EventDetailView.as_view(), name='get_one_event'),
    path('manage/createEvent/', EventInfoView.as_view(), name='create_event'),
    path('event/listAll/', EventListView.as_view(), name='get_all_events'),
    path('user/listCoupons/', CouponGetView.as_view(), name='get_coupons'),
    path('user/buyTicket/', TicketBookingView.as_view(), name='ticket_booking'),

    #Get ID of user
    path('user/getUserId/', GetUserIdView.as_view(), name='get-user-id'),
    path('user/getUserIdFromStaffnumber/', GetUserIdFromEmployeeUUID.as_view(),
         name='get-user-id-from-employee'),
    # Get all TicketTyps
    path('event/listTicketTyp/', TicketTypListView.as_view(), name='list_ticket_type'),

    ###### Testing WS ####
    path('test/', lambda request: render(request, 'TestWebsockets.html')),

]