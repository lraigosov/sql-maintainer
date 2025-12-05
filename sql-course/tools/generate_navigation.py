import os
import json
import glob

def get_notebooks(level_dir):
    """Obtiene lista de notebooks ordenados en un directorio."""
    notebooks = glob.glob(os.path.join(level_dir, "*.ipynb"))
    return sorted(notebooks)

def add_navigation_to_notebook(file_path, prev_nb, next_nb):
    """Inyecta celda de navegación al final del notebook."""
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Crear contenido de navegación
    nav_links = []
    if prev_nb:
        nav_links.append(f"[⬅️ Anterior]({os.path.basename(prev_nb)})")
    
    if prev_nb and next_nb:
        nav_links.append("|")
        
    if next_nb:
        nav_links.append(f"[Siguiente ➡️]({os.path.basename(next_nb)})")
    
    nav_md = " ".join(nav_links)
    
    # Celda de navegación
    nav_cell = {
        "cell_type": "markdown",
        "metadata": {"tags": ["navigation"]},
        "source": [
            "---\n",
            "## Navegación\n",
            f"{nav_md}\n",
            "---\n"
        ]
    }

    # Verificar si ya existe celda de navegación (por tag o contenido)
    if data['cells'] and "navigation" in data['cells'][-1].get('metadata', {}).get('tags', []):
        print(f"Actualizando navegación en {os.path.basename(file_path)}")
        data['cells'][-1] = nav_cell
    else:
        # Verificar si la última celda parece navegación antigua
        last_source = "".join(data['cells'][-1]['source']) if data['cells'] else ""
        if "## Navegación" in last_source or "[⬅️ Anterior]" in last_source:
             print(f"Actualizando navegación existente (sin tag) en {os.path.basename(file_path)}")
             data['cells'][-1] = nav_cell
        else:
            print(f"Agregando navegación a {os.path.basename(file_path)}")
            data['cells'].append(nav_cell)

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=1, ensure_ascii=False)

def process_level(level_dir):
    print(f"Procesando {level_dir}...")
    notebooks = get_notebooks(level_dir)
    
    for i, nb_path in enumerate(notebooks):
        prev_nb = notebooks[i-1] if i > 0 else None
        next_nb = notebooks[i+1] if i < len(notebooks) - 1 else None
        
        add_navigation_to_notebook(nb_path, prev_nb, next_nb)

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    levels = ['level01', 'level02', 'level03']
    
    for level in levels:
        level_path = os.path.join(base_dir, level)
        if os.path.exists(level_path):
            process_level(level_path)
        else:
            print(f"Directorio no encontrado: {level_path}")
            
    print("✅ Navegación generada exitosamente.")
