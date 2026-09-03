import os

def find_mouse_regions(start_dir):
    usages = []
    for root, dirs, files in os.walk(start_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                for idx, line in enumerate(lines, 1):
                    if 'MouseRegion' in line or 'onEnter' in line or 'onExit' in line:
                        usages.append((filepath, idx, line.strip()))
    return usages

if __name__ == '__main__':
    usages = find_mouse_regions(r'c:\Users\user\.gemini\antigravity\scratch\autopolicy\lib')
    print(f"Found {len(usages)} occurrences:")
    for filepath, line_num, content in usages:
        print(f"  {os.path.basename(filepath)}:{line_num} -> {content}")
