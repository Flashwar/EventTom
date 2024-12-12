from rest_framework.permissions import BasePermission

class IsEventCreator(BasePermission):
    """
    Custom permission to allow only EventCreators to access a specific endpoint.
    EventManagers are explicitly denied access.
    """
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False

        employee = getattr(request.user, 'employee', None)
        if not employee or employee.position == 'EventManager':
            return False


        return True

