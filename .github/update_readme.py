# code that builds the data curration str entry
data_curation_str = """
Design philosophy:\n
"""

# Read the README.stub file
with open('README.stub') as f:
    readme_stub = f.read()

# simple replacement, use whatever stand-in value is useful for you.
readme = readme_stub.replace('{DATACURATION}', data_curation_str)

with open('README.md','w') as f:
    f.write(readme)