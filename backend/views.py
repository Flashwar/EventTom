from django.contrib.auth.models import UserManager
from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework_simplejwt.authentication import JWTAuthentication


class LoginView(APIView):
    authentication_classes = [JWTAuthentication]

    @staticmethod
    def post(request):
        username = request.data.get('username')
        password = request.data.get('password')
        if not username or not password:
            return Response({'detail': 'username and password are required'}, status=401)
        # user = UserManager.authenticate(username=username, password=password)

class RegisterView(APIView):
    @staticmethod
    def post(request):
        username = request.data.get('username')
        password = request.data.get('password')
        if not username or not password:
            return Response({'detail': 'username and password are required'}, status=401)
        # user = UserManager.create(username=username, password=password)