# Data Visualization Dashboard

A stunning interactive dashboard built with Streamlit, featuring real-time data visualizations from multiple internet sources.

![Dashboard Preview](https://streamlit.io/images/brand/streamlit-logo-secondary-colormark-darktext.png)

## Features

- **Stock Market Analysis**: Real-time stock data from Yahoo Finance with interactive price charts and performance metrics
- **COVID-19 Statistics**: Global pandemic data trends and visualizations
- **Weather Analysis**: Temperature and humidity data from major cities with correlation analysis
- **Cryptocurrency Market**: Current prices, 24-hour changes, and market capitalization visualizations

## Data Sources

- Stock data: Yahoo Finance API (via yfinance)
- COVID-19 data: disease.sh API
- Weather data: Sample data (simulated from OpenWeatherMap)
- Cryptocurrency data: CoinCap API

## Setup Instructions

This app runs in a Python virtual environment to ensure dependency isolation.

### Prerequisites

- Python 3.8 or higher
- pip (Python package installer)

### Installation

1. Clone this repository or download the code
2. Navigate to the project directory
3. Create and activate a virtual environment:

```bash
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
# On macOS/Linux
source venv/bin/activate

# On Windows
venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip
```

4. Install dependencies:

```bash
# Install requirements
pip install -r requirements.txt
```

### Running the App

1. Ensure the virtual environment is activated
2. Run the Streamlit app:

```bash
streamlit run app.py
```

3. The app will open in your default web browser at `http://localhost:8501`

## Customization

Feel free to modify the data sources or add new visualization types by editing the `app.py` file. The modular design makes it easy to add new data sources and visualizations.

## License

This project is open source and available under the MIT License.

## Acknowledgements

- [Streamlit](https://streamlit.io/) for the amazing framework
- All the API providers for making data accessible 