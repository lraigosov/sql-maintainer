import json
import os
import glob
import re

def get_notebooks(directory):
    return glob.glob(os.path.join(directory, "*.ipynb"))

def classify_cell(cell):
    source = "".join(cell.get("source", [])).strip()
    
    if not source:
        return "empty"
    
    # Title: Starts with # X.Y or # Level
    if re.match(r"^#\s+\d+\.\d+", source) or re.match(r"^#\s+Level", source) or re.match(r"^#\s+Módulo", source):
        return "title"
    
    # Navigation
    if "## Navegación" in source or "navigation" in cell.get("metadata", {}).get("tags", []):
        return "navigation"
    
    # Credits
    if re.match(r"^#\s+Créditos", source):
        return "credits"
    
    # Errors
    if "## Errores Comunes" in source:
        return "errors"
    
    # Summary / Next Steps
    if "## Próximos Pasos" in source or "## Resumen" in source or "## Recursos" in source:
        # Note: Resources might be content, but usually at end. Let's group with summary.
        return "summary"
    
    # Exercises
    if "🟢" in source or "🟠" in source or "🔴" in source or "⚙️" in source:
        return "exercise"
    
    return "content"

def get_exercise_priority(cell):
    source = "".join(cell.get("source", [])).strip()
    if "🟢" in source: return 1
    if "🟠" in source: return 2
    if "🔴" in source: return 3
    if "⚙️" in source: return 4
    return 5

def reorder_notebook(file_path):
    print(f"Processing {os.path.basename(file_path)}...")
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    cells = data.get("cells", [])
    if not cells:
        return
    
    buckets = {
        "title": [],
        "content": [],
        "exercise": [],
        "errors": [],
        "summary": [],
        "credits": [],
        "navigation": [],
        "empty": []
    }
    
    # Classify
    for cell in cells:
        category = classify_cell(cell)
        buckets[category].append(cell)
        
    # Sort Exercises
    buckets["exercise"].sort(key=get_exercise_priority)
    
    # Reassemble: Title -> Content -> Exercises -> Errors -> Summary -> Credits -> Navigation
    # Note: If no title found, warn but proceed (keeps content at top)
    
    new_cells = (
        buckets["title"] +
        buckets["content"] +
        buckets["exercise"] +
        buckets["errors"] +
        buckets["summary"] +
        buckets["credits"] +
        buckets["navigation"]
    )
    
    # Check if we lost or duplicated anything (sanity check)
    if len(new_cells) != len(cells):
        # Could happen if empty cells were dropped? I added 'empty' bucket but didn't include it.
        # Let's include empty cells at the end of content? Or just drop them?
        # Better to keep them attached to previous block. But logic is per cell.
        # Let's put empty cells in content for now.
        new_cells = (
            buckets["title"] +
            buckets["content"] +
            buckets["empty"] +
            buckets["exercise"] +
            buckets["errors"] +
            buckets["summary"] +
            buckets["credits"] +
            buckets["navigation"]
        )
    
    data["cells"] = new_cells
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=1, ensure_ascii=False)

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    target_levels = ['level01', 'level03', 'module-ia', 'labs', 'evaluation'] 
    # Let's run on L1 and L3 first.
    
    for level in target_levels:
        level_dir = os.path.join(base_dir, level)
        if os.path.exists(level_dir):
            notebooks = get_notebooks(level_dir)
            for nb in notebooks:
                reorder_notebook(nb)

if __name__ == "__main__":
    main()
