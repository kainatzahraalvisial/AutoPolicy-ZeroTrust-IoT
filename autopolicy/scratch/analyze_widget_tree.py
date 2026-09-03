def print_widget_tree(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    stack = []
    import re
    # Match WidgetName(
    widget_pat = re.compile(r'([A-Za-z0-9_]+)\s*\(')
    
    for line_num, line in enumerate(lines, 1):
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        
        # Look for widget names
        matches = list(widget_pat.finditer(line))
        for m in matches:
            wname = m.group(1)
            # Filter out common methods/constructors that aren't build widgets
            if wname in ['updateTheme', 'updateClock', 'dispose', 'initState', 'setState', 'Duration', 'BoxDecoration', 'BorderSide', 'Border', 'BoxShadow', 'Offset', 'LinearGradient', 'Radius', 'BorderRadius', 'TextStyle', 'EdgeInsets', 'Matrix4', 'ref', 'watch', 'read', 'any', 'where', 'toList', 'map', 'agg', 'final', 'String', 'int', 'double', 'Color', 'GestureDetector']:
                continue
            # If line has children: [
            has_children = 'children:' in line
            stack.append((wname, line_num, indent))
            print(f"{'  ' * len(stack)}{wname} (Line {line_num}, Indent {indent})")
            
        # If line contains closing ) or ], let's see
        # Simple counting of closing chars
        for char in line:
            if char == ')' and stack:
                # Close the top widget
                wname, lnum, ind = stack.pop()
                # print(f"{'  ' * len(stack)}  [CLOSED] {wname}")

if __name__ == '__main__':
    print_widget_tree(r'c:\Users\user\.gemini\antigravity\scratch\autopolicy\lib\screens\main_layout.dart')
