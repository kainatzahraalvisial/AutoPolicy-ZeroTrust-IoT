import re

def analyze_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    stack = []
    for line_num, line in enumerate(lines, 1):
        for char_idx, char in enumerate(line):
            if char in '([{':
                stack.append((char, line_num, char_idx + 1))
            elif char in ')]}':
                if not stack:
                    print(f"Extra closing char '{char}' at line {line_num}, col {char_idx + 1}")
                    continue
                open_char, open_line, open_col = stack.pop()
                expected = {')': '(', ']': '[', '}': '{'}[char]
                if open_char != expected:
                    print(f"Mismatched closing '{char}' at line {line_num}, col {char_idx + 1} (expected matching for '{open_char}' from line {open_line})")
    
    if stack:
        print(f"Unclosed opened structures: {len(stack)}")
        for char, line_num, col in stack[-10:]:
            print(f"  Unclosed '{char}' at line {line_num}, col {col}")

if __name__ == '__main__':
    analyze_file(r'c:\Users\user\.gemini\antigravity\scratch\autopolicy\lib\screens\main_layout.dart')
