"""
Module to run on github to gather stubs for README

Loads `.stub` files from /documentation and compiles them
to a single string. Then, the string is scanned
for h2 and h3 markdown headers which are enriched with
html tags for hyperlinking, and a table of contents is
created with these headers and hyperlinks and inserted
into the str.

Finally, the string is written to a complete README.md file.

See the workflow defined in /.github/workflows/main.yaml
"""

from re import search, findall

def _update_readme(readme: str) -> str:
    """Find markdown headers and update
    
    Finds all markdown h2 and h3 headers (##, ###),
    adds html tags to them, and creates a table of
    contents that is added to the readme.
    
    Args:
        readme (str): Contents of README file

    Returns:
        str: Updated contents of README file
    """
    toc_candidates = findall("(#+\s.*?)\n\n", readme)
    
    header_counter = -1
    header_list = []
    sub_header_list = []
    for can in toc_candidates:
        # Titles should be ignored
        if search("^#{1}\s", can) is not None:
            continue
        
        if search("^#{2}\s", can) is not None:
            header_counter += 1
            sub_header_list.append([])
            header = search("#+\s(.+)", can).group(1)
            header_list.append(header)
        
        if search("^#{3}\s", can) is not None:
            sub_header = search("#+\s(.+)", can).group(1)
            sub_header_list[header_counter].append(sub_header)
            
    toc_strs = []
    for h, header in enumerate(header_list):
        toc_strs.append(f"{h+1}. [{header}](#{make_tag(header)})\n")
        readme = readme.replace(header, header_with_html_tag(header))
        
        for sh, sub_header in enumerate(sub_header_list[h]):
            toc_strs.append(f"\t{sh+1}. [{sub_header}](#{make_tag(sub_header)})\n")
            readme = readme.replace(sub_header, header_with_html_tag(sub_header))
        
    toc_str = "\n# Table of contents\n\n" + "".join(toc_strs)

    readme = readme.replace('{TOC}', toc_str)
    
    return readme

def make_tag(header: str) -> str:
    lower_header = header.lower()
    words = lower_header.split(" ")
    return "-".join(words)

def header_with_html_tag(header: str) -> str:
    tag = make_tag(header)
    html_tag = "<a name=\"" + tag + "\"></a>"
    return header + " " + html_tag
    
if __name__ == "__main__":
    # code that builds the data curration str entry
    with open('documentation/DATA_MANAGEMENT.stub') as f:
        data_curation_str = f.read()

    with open('documentation/DATA_ANALYSIS.stub') as f:
        data_analysis_str = f.read()
        
    with open('documentation/EXPERIMENT_MANAGEMENT.stub') as f:
        experiment_management_str = f.read()
        
    with open('documentation/TESTING.stub') as f:
        testing_str = f.read()

    # Read the README.stub file
    with open('documentation/README.stub') as f:
        readme = f.read()

    # simple replacement, use whatever stand-in value is useful for you.
    readme = readme.replace('{DATA_MANAGEMENT}', data_curation_str)
    readme = readme.replace('{DATA_ANALYSIS}', data_analysis_str)
    readme = readme.replace('{EXPERIMENT_MANAGEMENT}', experiment_management_str)
    readme = readme.replace('{TESTING}', testing_str)
    readme = _update_readme(readme)

    with open('README.md','w') as f:
        f.write(readme)
