from injector import inject, Module, singleton
from .services import EventService, CouponService, TicketService, UserService, TicketTypService, EmployeeService


class AppModule(Module):
    # define services which will be injected
    def configure(self, binder):
        binder.bind(EventService, to=EventService, scope=singleton)
        binder.bind(CouponService, to=CouponService, scope=singleton)
        binder.bind(TicketService, to=TicketService, scope=singleton)
        binder.bind(UserService, to=UserService, scope=singleton)
        binder.bind(TicketTypService, to=TicketTypService, scope=singleton)
        binder.bind(EmployeeService, to=EmployeeService, scope=singleton)