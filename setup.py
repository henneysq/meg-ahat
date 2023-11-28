import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="megahat",
    version="0.1.3",
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
        "pandas",
    ],
    python_requires='>=3.7',
)
