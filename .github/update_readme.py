# code that builds the data curration str entry
with open('DATA_MANAGEMENT.stub') as f:
    data_curation_str = f.read()

# Read the README.stub file
with open('README.stub') as f:
    readme_stub = f.read()

# simple replacement, use whatever stand-in value is useful for you.
readme = readme_stub.replace('{DATACURATION}', data_curation_str)

with open('README.md','w') as f:
    f.write(readme)