from django.shortcuts import render
from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView, TokenVerifyView

from backend.views import LogoutView, EventInfoView, EventDetailView, EventListView, CouponGetView, TicketBookingView, \
    GetUserIdView, TicketTypListView, RegisterView, GetEmployeePositionView

# Define the RESTAPI URLs for various endpoints
urlpatterns = [
    # Endpoint for employee and customer login (JWT token generation)
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),

    # Endpoint for refreshing the JWT token (valid for 24 hours)
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # Endpoint for validating the JWT token
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),

    # Endpoint for logging of a user or customer
    path('logout/', LogoutView.as_view(), name='logout'),

    # Endpoint for creating a user
    path('createUser/', RegisterView.as_view(), name='create_user'),

    # Endpoint for getting the job position
    path('user/getEmployeePosition/', GetEmployeePositionView.as_view(), name='check_employee_status'),

    # Endpoint to get specific information about an event
    path('event/getEvent/', EventDetailView.as_view(), name='get_one_event'),

    # Endpoint for creating o new event
    path('manage/createEvent/', EventInfoView.as_view(), name='create_event'),

    # Endpoint to get a list of all available events
    path('event/listAll/', EventListView.as_view(), name='get_all_events'),

    # Endpoint to list all personalized coupons of a customer
    path('user/listCoupons/', CouponGetView.as_view(), name='get_coupons'),

    # Endpoint to buy a ticket
    path('user/buyTicket/', TicketBookingView.as_view(), name='ticket_booking'),

    # Endpoint to retrieve a user's ID from their username
    path('user/getUserId/', GetUserIdView.as_view(), name='get-user-id'),

    # Endpoint to get a list of all available TicketTyps
    path('event/listTicketTyp/', TicketTypListView.as_view(), name='list_ticket_type'),

    # Temporary testing endpoint for WebSocket functionality (to be removed later)
    path('test/', lambda request: render(request, 'TestWebsockets.html')),

]
