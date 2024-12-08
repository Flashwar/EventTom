from django.shortcuts import render

# Create your views here.
from django.shortcuts import render

def websocket_test_view(request):
    return render(request, 'Test.html')


