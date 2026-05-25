from setuptools import setup, find_packages

setup(
    name='eros_kerbtap',
    version='1.1.0',
    description='EROS Mosaic Stream Protocol (MSP) Engine',
    packages=find_packages(),
    install_requires=[
        'textual>=0.27.0',
        'python-dotenv>=1.0.0'
    ],
    entry_points={
        'console_scripts': [
            'kerbtap=kerbtap_daemon:main',
        ],
    },
)
