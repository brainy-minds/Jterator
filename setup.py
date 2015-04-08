#!/usr/bin/env python

import os.path
import sys
try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup


def readme():
    try:
        with open(os.path.join(os.path.dirname(__file__), 'README.md')) as f:
            return f.read()
    except (IOError, OSError):
        return ''


def get_version():
    src_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'src')
    sys.path.append(src_path)
    import jterator
    return jterator.__version__


setup(
    name='jterator',
    version=get_version(),
    description='A minimalistic pipeline engine for scientific computing.',
    long_description=readme(),
    author='Yauhen Yakimovich, Markus Herrmann',
    author_email='markusdherrmann at gmail dot com',
    url='https://github.com/HackerMD/Jterator',
    license='MIT',
    scripts=['src/jt'],
    packages=[
        'jterator',
    ],
    package_dir={'': 'src'},
    # package_data={
    #     '': ['*.html', '*.svg', '*.js'],
    # },
    include_package_data=True,
    download_url='https://github.com/HackerMD/Jterator/tarball/master',
    install_requires=[
        'h5py>=2.2.1',
        'numpy>=1.5.0',
        'Cython>=0.16',
        'tree_output>=0.1.2',
        'sh>=1.09',
        'subprocess32>=3.2.6',
        'PyYAML>=3.11',
    ],
    # data_files=[
    #     ('/usr/local/bin', ['jt']),
    # ],
    classifiers=[
        'Topic :: Scientific/Engineering :: Image Recognition',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Scientific/Engineering :: Bio-Informatics',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2.7',
        'Development Status :: 3 - Alpha',
        'License :: OSI Approved :: MIT License',
        'Operating System :: POSIX :: Linux',
        'Operating System :: MacOS',
    ],
    tests_require=['nose>=1.0'],
    test_suite='nose.collector',
)
