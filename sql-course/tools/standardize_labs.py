import os
import json
import glob

def standardize_lab_notebook(file_path):
    """Inyecta enlace de retorno al inicio del notebook."""
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Contenido del header
    header_source = [
        "[⬅️ Volver al Índice](../README.md)\n",
        "\n",
        "---\n"
    ]
    
    header_cell = {
        "cell_type": "markdown",
        "metadata": {"tags": ["header"]},
        "source": header_source
    }

    # Verificar si ya existe header (por tag o contenido)
    if data['cells'] and "header" in data['cells'][0].get('metadata', {}).get('tags', []):
        print(f"Actualizando header en {os.path.basename(file_path)}")
        data['cells'][0] = header_cell
    elif data['cells'] and "[⬅️ Volver al Índice]" in "".join(data['cells'][0]['source']):
        print(f"Header ya existe en {os.path.basename(file_path)}")
        data['cells'][0] = header_cell # Actualizar por si acaso
    else:
        print(f"Agregando header a {os.path.basename(file_path)}")
        data['cells'].insert(0, header_cell)

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=1, ensure_ascii=False)

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    labs_dir = os.path.join(base_dir, 'labs')
    
    if os.path.exists(labs_dir):
        notebooks = glob.glob(os.path.join(labs_dir, "*.ipynb"))
        for nb in notebooks:
            standardize_lab_notebook(nb)
        print("✅ Labs estandarizados exitosamente.")
    else:
        print(f"Directorio labs no encontrado: {labs_dir}")
