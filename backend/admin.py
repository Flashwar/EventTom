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
    list_display = ['username', 'first_name', 'last_name', 'email']

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


# remove form of the default user
admin.site.unregister(User)
# add the custom customer form to the admin site
admin.site.register(User, CustomUserAdmin)

# register all models
admin.site.register(Employee)
admin.site.register(Coupon)
admin.site.register(Ticket)
admin.site.register(Event)
admin.site.register(TicketTyp)
