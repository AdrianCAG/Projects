#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import json
import tempfile
import traceback
import time
import argparse
from typing import Dict, List, Any, Optional, Tuple

# Add command-line argument parsing
parser = argparse.ArgumentParser(description='Generate charts for Sensor Graph Display')
parser.add_argument('json_file', nargs='?', help='JSON file containing chart data')
parser.add_argument('--fast', action='store_true', help='Enable fast mode for chart generation')
args, unknown = parser.parse_known_args()

# Handle the case where json_file is not provided as a named argument
if not args.json_file and len(sys.argv) > 1 and not sys.argv[1].startswith('-'):
    args.json_file = sys.argv[1]

# Start timing for performance measurement
start_time = time.time()

# Only print debug information if not in fast mode
if not args.fast:
    print(f"Python version: {sys.version}")
    print(f"Arguments: {sys.argv}")
    print(f"Working directory: {os.getcwd()}")

try:
    import numpy as np
    import matplotlib
    matplotlib.use('Agg')  # Use non-interactive backend
    import matplotlib.pyplot as plt
    from matplotlib.figure import Figure
    from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
    import matplotlib.colors as mcolors
    from matplotlib.lines import Line2D
    
    if not args.fast:
        print(f"Successfully imported matplotlib {matplotlib.__version__} and numpy {np.__version__}")
except Exception as e:
    print(f"Error importing dependencies: {str(e)}")
    traceback.print_exc()
    sys.exit(1)

class ChartGenerator:
    """
    Python chart generator for Sensor Graph Display application.
    This class generates charts using matplotlib and saves them as image files
    that can be loaded by the C++ application.
    """
    
    def __init__(self, output_dir=None):
        """Initialize the chart generator with an output directory."""
        if output_dir is None:
            self.output_dir = tempfile.gettempdir()
        else:
            self.output_dir = output_dir
            os.makedirs(output_dir, exist_ok=True)
            
        # Set up a custom style for the charts
        plt.style.use('ggplot')
        
        # Define a color palette for consistent coloring
        self.color_palette = list(mcolors.TABLEAU_COLORS.values()) + list(mcolors.CSS4_COLORS.values())
    
    def generate_chart(self, data_json, width=800, height=600, dpi=100):
        """
        Generate a chart from JSON data and save it as an image.
        
        Args:
            data_json (str): JSON string containing chart data and settings
            width (int): Width of the chart in pixels
            height (int): Height of the chart in pixels
            dpi (int): DPI for the output image
            
        Returns:
            str: Path to the generated image file
        """
        # Parse the JSON data
        data = json.loads(data_json)
        
        # Extract chart settings
        title = data.get('title', '')
        x_label = data.get('x_label', 'Time')
        y_label = data.get('y_label', 'Value')
        chart_type = data.get('chart_type', 'line')
        interpolate = data.get('interpolate', False)
        series_data = data.get('series', [])
        grid = data.get('grid', True)
        x_min = data.get('x_min', None)
        x_max = data.get('x_max', None)
        y_min = data.get('y_min', None)
        y_max = data.get('y_max', None)
        
        # Create figure and axes
        fig = Figure(figsize=(width/dpi, height/dpi), dpi=dpi)
        canvas = FigureCanvas(fig)
        ax = fig.add_subplot(111)
        
        # Set title and labels
        ax.set_title(title)
        ax.set_xlabel(x_label)
        ax.set_ylabel(y_label)
        
        # Set axis limits if provided
        if x_min is not None and x_max is not None:
            ax.set_xlim(x_min, x_max)
        if y_min is not None and y_max is not None:
            ax.set_ylim(y_min, y_max)
        
        # Plot each series
        for i, series in enumerate(series_data):
            name = series.get('name', f'Series {i+1}')
            # Get color and strip any extra quotes that might cause matplotlib errors
            color = series.get('color', self.color_palette[i % len(self.color_palette)])
            # If color is a string with quotes, remove them
            if isinstance(color, str):
                color = color.strip('\'"')
            visible = series.get('visible', True)
            line_style = series.get('line_style', '-')
            marker = series.get('marker', None)
            line_width = series.get('line_width', 2.0)
            
            if not visible:
                continue
                
            x_values = series.get('x_values', [])
            y_values = series.get('y_values', [])
            
            if not x_values or not y_values:
                continue
            
            # For wave-like visualization like in screenshot 3
            if series.get('is_wave', False):
                # Ensure smooth wave rendering
                if len(x_values) < 100 and interpolate:
                    x_interp = np.linspace(min(x_values), max(x_values), 500)
                    y_interp = np.interp(x_interp, x_values, y_values)
                    x_values = x_interp
                    y_values = y_interp
                
            # Create the plot based on chart type
            if chart_type == 'line':
                if interpolate:
                    # Use cubic interpolation for smoother lines
                    ax.plot(x_values, y_values, label=name, color=color,
                           linestyle=line_style, marker=marker, linewidth=line_width)
                else:
                    # Connect points directly
                    ax.plot(x_values, y_values, label=name, color=color,
                           linestyle=line_style, marker=marker, linewidth=line_width)
            elif chart_type == 'scatter':
                ax.scatter(x_values, y_values, label=name, color=color, s=line_width*25)
            elif chart_type == 'bar':
                ax.bar(x_values, y_values, label=name, color=color, alpha=0.7)
            elif chart_type == 'area':
                ax.fill_between(x_values, y_values, alpha=0.3, label=name, color=color)
                ax.plot(x_values, y_values, color=color, linewidth=line_width)
            elif chart_type == 'step':
                ax.step(x_values, y_values, label=name, color=color, where='mid', linewidth=line_width)
            elif chart_type == 'sine':
                # Special case for sine waves like in screenshot 3
                ax.plot(x_values, y_values, label=name, color=color, linewidth=line_width)
        
        # Add grid
        if grid:
            ax.grid(True, linestyle='--', alpha=0.7)
        
        # Add legend if there are multiple series
        if len(series_data) > 1:
            ax.legend(loc='best')
        
        # Adjust layout
        fig.tight_layout()
        
        # Save to file
        filename = f"chart_{os.getpid()}_{id(data)}.png"
        filepath = os.path.join(self.output_dir, filename)
        fig.savefig(filepath)
        
        return filepath
    
    def generate_multi_series_chart(self, series_list, title="", x_label="Time", y_label="Value", 
                                   chart_type="line", interpolate=False, width=800, height=600, dpi=100,
                                   grid=True, x_min=None, x_max=None, y_min=None, y_max=None):
        """
        Generate a chart with multiple data series and save it as an image.
        
        Args:
            series_list (list): List of series, each containing name, x_values, y_values, color
            title (str): Chart title
            x_label (str): X-axis label
            y_label (str): Y-axis label
            chart_type (str): Chart type (line, scatter, bar, area, step, sine)
            interpolate (bool): Whether to interpolate between points
            width (int): Width of the chart in pixels
            height (int): Height of the chart in pixels
            dpi (int): DPI for the output image
            grid (bool): Whether to show grid lines
            x_min (float): Minimum x-axis value
            x_max (float): Maximum x-axis value
            y_min (float): Minimum y-axis value
            y_max (float): Maximum y-axis value
            
        Returns:
            str: Path to the generated image file
        """
        # Create data dictionary
        data = {
            'title': title,
            'x_label': x_label,
            'y_label': y_label,
            'chart_type': chart_type,
            'interpolate': interpolate,
            'grid': grid,
            'series': series_list
        }
        
        if x_min is not None and x_max is not None:
            data['x_min'] = x_min
            data['x_max'] = x_max
            
        if y_min is not None and y_max is not None:
            data['y_min'] = y_min
            data['y_max'] = y_max
        
        # Convert to JSON and generate chart
        data_json = json.dumps(data)
        return self.generate_chart(data_json, width, height, dpi)


# Create a cache for matplotlib figures
_figure_cache = {}

# Command-line interface for testing
if __name__ == "__main__":
    try:
        # Enable fast mode optimizations
        if args.fast:
            # Use the Agg backend with simplified renderer
            matplotlib.rcParams['figure.dpi'] = 100
            matplotlib.rcParams['savefig.dpi'] = 100
            matplotlib.rcParams['path.simplify'] = True
            matplotlib.rcParams['path.simplify_threshold'] = 1.0
            matplotlib.rcParams['agg.path.chunksize'] = 10000

        # Get JSON file from args
        json_file = args.json_file
        if not json_file:
            print("Error: No JSON file specified")
            sys.exit(1)
            
        if not args.fast:
            print(f"Reading JSON data from: {json_file}")
            
        # Check if file exists
        if not os.path.exists(json_file):
            print(f"Error: JSON file not found: {json_file}")
            sys.exit(1)
            
        # Read JSON data from file
        try:
            with open(json_file, 'r') as f:
                data_json = f.read()
            if not args.fast:
                print(f"Successfully read {len(data_json)} bytes from {json_file}")
        except Exception as e:
            print(f"Error reading JSON file: {str(e)}")
            traceback.print_exc()
            sys.exit(1)
            
        # Parse width and height if provided as arguments
        width = 800
        height = 600
        dpi = 100
        
        if len(sys.argv) > 3:
            try:
                width = int(sys.argv[2])
                height = int(sys.argv[3])
            except ValueError:
                print("Warning: Invalid width or height values. Using defaults.")
        
        if len(sys.argv) > 4:
            try:
                dpi = int(sys.argv[4])
            except ValueError:
                print("Warning: Invalid DPI value. Using default.")
        
        # Generate chart
        generator = ChartGenerator()
        chart_path = generator.generate_chart(data_json, width=width, height=height, dpi=dpi)
        # Always print the chart path in the exact format the C++ code expects
        print(f"Chart generated: {chart_path}")
            
        # Print performance timing information
        end_time = time.time()
        if args.fast:
            print(f"Chart generation completed in {(end_time - start_time):.3f} seconds")
            
    except Exception as e:
        print(f"Error generating chart: {str(e)}")
        traceback.print_exc()
        sys.exit(1)
