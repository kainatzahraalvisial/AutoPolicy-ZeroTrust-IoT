import os
import re

def analyze_animated_builders(start_dir):
    usages = []
    # Match AnimatedBuilder( or similar
    builder_pat = re.compile(r'AnimatedBuilder\s*\(')
    
    for root, dirs, files in os.walk(start_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if 'AnimatedBuilder' in content:
                    lines = content.split('\n')
                    for idx, line in enumerate(lines, 1):
                        if 'AnimatedBuilder' in line:
                            # Let's read a block of 15 lines following this to check child parameter
                            block = '\n'.join(lines[idx-1 : idx+15])
                            has_child_param = 'child:' in block
                            usages.append((filepath, idx, has_child_param, line.strip()))
    return usages

if __name__ == '__main__':
    usages = analyze_animated_builders(r'c:\Users\user\.gemini\antigravity\scratch\autopolicy\lib')
    print(f"Found {len(usages)} AnimatedBuilder usages:")
    for filepath, line_num, has_child, content in usages:
        status = "SECURE (caching child)" if has_child else "CRITICAL (rebuilding every frame!)"
        print(f"  {os.path.basename(filepath)}:{line_num} -> {status} | {content}")
