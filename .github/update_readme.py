from re import search, findall
from pdb import set_trace

def _update_readme(readme: str) -> str:
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
        
    toc_str = "".join(toc_strs)

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
    

# code that builds the data curration str entry
with open('DATA_MANAGEMENT.stub') as f:
    data_curation_str = f.read()

# Read the README.stub file
with open('README.stub') as f:
    readme_stub = f.read()

# simple replacement, use whatever stand-in value is useful for you.
readme = readme_stub.replace('{DATACURATION}', data_curation_str)
readme = _update_readme(readme)

with open('README.md','w') as f:
    f.write(readme)
