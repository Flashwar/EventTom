from rest_framework.permissions import BasePermission

class IsEventCreator(BasePermission):
    """
    Custom permission to allow only EventCreators to access a specific endpoint.
    EventManagers are explicitly denied access.
    """
    def has_permission(self, request, view):
        # if the user is not authenticated
        # deny access
        if not request.user.is_authenticated:
            return False

        # Retrieve the 'employee' attribute from the user, if not existing none
        # If the user does not have an 'employee' attribute or holds the position 'EventManager', deny access
        employee = getattr(request.user, 'employee', None)
        if not employee or employee.position == 'EventManager':
            return False

        # allow access
        return True

