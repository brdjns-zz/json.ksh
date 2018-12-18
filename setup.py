#!/usr/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup
import os

# Allow setup.py to be run from any path
os.chdir(os.path.normpath(os.path.join(os.path.abspath(__file__), os.pardir)))

setup(
    name='json.ksh',
    scripts=[
        'json.ksh',
    ],
    version='0.3.2',
    description="JSON parser implemented in KornShell",
    long_description="",
    author='Bradley Jones',
    author_email='brdjns@sdf.org',
    url='https://github.com/brdjns/json.ksh',
    classifiers=[
        "Programming Language :: Unix Shell",
        "License :: OSI Approved :: MIT License",
        "License :: OSI Approved :: Apache Software License",
        "Intended Audience :: System Administrators",
        "Intended Audience :: Developers",
        "Operating System :: POSIX :: Linux",
        "Topic :: Utilities",
        "Topic :: Software Development :: Libraries",
    ],
)
