# 🪐 ExoVerse Explorer

A unique and interactive Streamlit dashboard for exploring exoplanet data from NASA's database. This application allows users to discover and visualize alien worlds beyond our solar system.

## Features

- **Visual Explorer**: Interactive visualizations of exoplanet properties including size, orbital period, discovery timeline, and 3D star system map
- **Detailed Analysis**: Search specific exoplanets, view detailed information, and analyze correlations between planetary characteristics
- **Habitability Finder**: Identify potentially habitable exoplanets based on customizable criteria and view habitability scores

## Getting Started

### Prerequisites

- Python 3.7+
- pip

### Installation

1. Clone this repository or download the files
2. Set up a virtual environment and install the required packages:

```bash
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install requirements
pip install -r requirements.txt
```

### Running the App

```bash
streamlit run app.py
```

The app will open in your default web browser at `http://localhost:8501`.

## Data Source

The app uses data from the NASA Exoplanet Archive when an internet connection is available. If the connection fails, it will generate sample data for demonstration purposes.

## Technologies Used

- Streamlit: For the interactive web interface
- Pandas: For data manipulation
- Plotly: For interactive visualizations
- scikit-learn: For data processing

## Screenshots

The app features a beautiful space-themed interface with:
- Interactive 3D star maps
- Correlation visualizations
- Planet type distribution charts
- Habitability scoring system 