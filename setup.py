import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="megahat",
    version="0.5.0",
    author="OptoCeutics",
    author_email="mark@henney.dk",
    description="Donders OC colab project",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/henneysq/meg-ahat",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    install_requires=[
        "pandas==2.1.3",
        "pyserial==3.5",
        "dotmap==1.3.30",
        #"git+https://optogit.optoceutics.com/optoceutics/software/libledcontroller.git@master#egg=libLEDController", # Proprietary software to control OptoCeutics ApS light stimulator
        #"git+https://github.com/henneysq/psychopy.git@dev#egg=psychopy", # Forked version of psychopy v. 2023.2.3
        #"https://optogit.optoceutics.com/optoceutics/research/megahatledcontroller.git"
    ],
    python_requires='>=3.8',
)
