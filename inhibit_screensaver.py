#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import dbus
import time
import signal
import sys
import os

bus = dbus.Bus(dbus.Bus.TYPE_SESSION)
devobj = bus.get_object("org.kde.Solid.PowerManagement.PolicyAgent", "/org/kde/Solid/PowerManagement/PolicyAgent")
dev = dbus.Interface(devobj, "org.kde.Solid.PowerManagement.PolicyAgent")

cookies = {}

for i in [1, 2, 4]:
	cookies[i] = dev.AddInhibition(i, sys.argv[0], "inhibit screensaver while running (pid {})".format(os.getpid()))

while True:
	time.sleep(60)
