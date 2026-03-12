import sys
import re
import os

def search_markdown(query, file_path):
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split by the URL marker to separate pages
    sections = re.split(r'---\n## URL: (.*?)\n---', content)
    
    found = False
    # sections[0] is usually empty or header. 
    # sections[1] is URL, sections[2] is content, sections[3] is URL, sections[4] is content...
    for i in range(1, len(sections), 2):
        url = sections[i]
        text = sections[i+1]
        
        if query.lower() in text.lower() or query.lower() in url.lower():
            if not found:
                print(f"--- Search Results for '{query}' ---\n")
                found = True
            
            print(f"Match found in: {url}")
            # Print a snippet around the match
            match_index = text.lower().find(query.lower())
            start = max(0, match_index - 300)
            end = min(len(text), match_index + 300)
            
            snippet = text[start:end].replace('\n', ' ')
            print(f"...{snippet}...\n")
            print("-" * 50)

    if not found:
        print(f"No results found for '{query}'.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python search_docs.py <query>")
        sys.exit(1)
        
    query = sys.argv[1]
    # Path relative to the script's directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    docs_path = os.path.join(script_dir, '..', 'references', 'sepay_docs.md')
    
    search_markdown(query, docs_path)
