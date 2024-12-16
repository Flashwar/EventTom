from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserChangeForm, UserCreationForm
from django.contrib.auth.models import User

from .models import Employee, Coupon, Ticket, Event, TicketTyp


# Set a custom form for adding a new customer
class CustomUserAdmin(UserAdmin):
    add_form = UserCreationForm
    form = UserChangeForm
    model = User
    # Define the attributes of the customers that will be displayed in the list
    list_display = ['id','username', 'first_name', 'last_name', 'email']

    # set the form elements
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'email')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    # required fields
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'password1', 'password2', 'first_name', 'last_name', 'email'),
        }),
    )

class TicketAdmin(admin.ModelAdmin):
    # Define the attributes of the Ticket that will be displayed in the list
    list_display = ('event', 'owner_id', 'owner', 'ticket_typ', 'price', 'numb_tickets')

class CouponAdmin(admin.ModelAdmin):
    list_display = ('owner_id','owner', 'amount')

class EmployeeAdmin(admin.ModelAdmin):
    list_display = ('staff_number', 'person_id', 'person', 'position')


class EventAdmin(admin.ModelAdmin):
    list_display = ('title', 'max_tickets', 'bought_tickets', 'threshold_tickets', 'base_price')

class TicketTypAdmin(admin.ModelAdmin):
    list_display = ('name', 'fee' )

# remove form of the default user
admin.site.unregister(User)
# add the custom customer form to the admin site
admin.site.register(User, CustomUserAdmin)

# register all models
admin.site.register(Employee, EmployeeAdmin)
admin.site.register(Coupon, CouponAdmin)
admin.site.register(Ticket, TicketAdmin)
admin.site.register(Event, EventAdmin)
admin.site.register(TicketTyp,TicketTypAdmin)
