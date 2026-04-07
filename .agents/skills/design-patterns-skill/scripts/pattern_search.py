#!/usr/bin/env python3
import argparse
import os

def search_patterns(query):
    references_path = os.path.join(os.path.dirname(__file__), '..', 'references', 'design-patterns.md')
    try:
        with open(references_path, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
            found = False
            for line in lines:
                if query.lower() in line.lower() and ('|' in line or '#' in line):
                    print(line.strip())
                    found = True
            if not found:
                print(f"No summary found for '{query}'.")
    except FileNotFoundError:
        print("Knowledge base not found.")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Search the design patterns knowledge base.")
    parser.add_argument('query', help="The design pattern to search for (e.g., 'Factory')")
    args = parser.parse_args()
    search_patterns(args.query)
