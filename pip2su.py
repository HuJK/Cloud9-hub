#!/usr/bin/python3
import sys
import pexpect
child = pexpect.spawn(" ".join(sys.argv[1:]))
password = input()
child.sendline(password)
print(child.read().decode("utf8"))
