import matplotlib.colors as mcolors

def GenerarColores(color_inicio = '#0D125B',color_fin = '#1C57AA',num_colores = 10):
    # Crear el gradiente interpolando entre los colores
    gradient = mcolors.LinearSegmentedColormap.from_list('custom_gradient', [color_inicio, color_fin], N=num_colores)
    return [mcolors.rgb2hex(gradient(i)) for i in range(num_colores)]