from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserChangeForm, UserCreationForm
from django.contrib.auth.models import User

from .models import Employee, Coupon


class CustomUserAdmin(UserAdmin):

    add_form = UserCreationForm
    form = UserChangeForm
    model = User
    list_display = ['username', 'first_name', 'last_name', 'email']

    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'email')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'password1', 'password2', 'first_name', 'last_name', 'email'),
        }),
    )

admin.site.unregister(User)
admin.site.register(User, CustomUserAdmin)

admin.site.register(Employee)
admin.site.register(Coupon)
