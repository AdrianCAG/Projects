import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import matplotlib.pyplot as plt
import seaborn as sns
import requests
import yfinance as yf
from datetime import datetime, timedelta
import json

# Set page configuration
st.set_page_config(
    page_title="Data Visualization Dashboard",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for styling
st.markdown("""
<style>
    :root {
        --bg-dark: #191c36;
        --card-bg: #1b1f38;
        --purple-card: #6b4ef9;
        --orange-card: #ff7d46;
        --blue-card: #3279fc;
        --text-color: #ffffff;
        --text-secondary: #a8b1d6;
        --highlight-blue: #55c2f9;
    }
    
    /* Base styling */
    .stApp {
        background-color: var(--bg-dark);
        color: var(--text-color);
        background-image: linear-gradient(to bottom right, #191c36, #151832);
    }
    
    .main-header {
        font-size: 1.8rem;
        color: var(--text-color);
        margin-bottom: 1.5rem;
        font-weight: 500;
        text-align: center;
    }
    
    .sub-header {
        font-size: 1.5rem;
        color: var(--text-color);
        margin-bottom: 1rem;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        padding-bottom: 0.5rem;
    }
    
    .balance-header {
        font-size: 2.5rem;
        color: var(--text-color);
        font-weight: 700;
        margin-bottom: 0;
        text-align: center;
    }

    .balance-currency {
        font-size: 1.2rem;
        color: rgba(255,255,255,0.5);
        font-weight: 500;
        margin-top: 0;
        text-align: center;
    }
    
    /* Dashboard containers */
    .dashboard-container {
        background-color: var(--card-bg);
        border-radius: 24px;
        padding: 1.5rem;
        box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        margin-bottom: 1.5rem;
        border: 1px solid rgba(255, 255, 255, 0.03);
        overflow: hidden;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    .dashboard-container:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 20px rgba(0,0,0,0.3);
    }
    
    /* Card styles */
    .purple-card {
        background: linear-gradient(135deg, #5c42e5 0%, #6b4ef9 100%);
        color: white;
    }
    
    .blue-card {
        background: linear-gradient(135deg, #2c68eb 0%, #3279fc 100%);
        color: white;
    }
    
    .orange-card {
        background: linear-gradient(135deg, #fa6a3c 0%, #ff7d46 100%);
        color: white;
    }
    
    /* Wallet card styles */
    .purple-wallet {
        background: linear-gradient(135deg, #5c42e5 0%, #6b4ef9 100%);
        color: white;
        border-radius: 24px;
        padding: 1.2rem;
        box-shadow: 0 8px 16px rgba(91, 66, 229, 0.2);
        text-align: center;
    }
    
    .blue-wallet {
        background: linear-gradient(135deg, #2c68eb 0%, #3279fc 100%);
        color: white;
        border-radius: 24px;
        padding: 1.2rem;
        box-shadow: 0 8px 16px rgba(44, 104, 235, 0.2);
        text-align: center;
    }
    
    .orange-wallet {
        background: linear-gradient(135deg, #fa6a3c 0%, #ff7d46 100%);
        color: white;
        border-radius: 24px;
        padding: 1.2rem;
        box-shadow: 0 8px 16px rgba(250, 106, 60, 0.2);
        text-align: center;
    }
    
    .coin-icon {
        font-size: 2.5rem;
        margin-bottom: 0.5rem;
    }
    
    .coin-amount {
        font-size: 1.8rem;
        font-weight: 700;
    }
    
    .coin-symbol {
        font-size: 1rem;
        opacity: 0.9;
    }
    
    .coin-change {
        font-size: 0.9rem;
        opacity: 0.9;
        margin-top: 0.5rem;
    }
    
    .positive-change {
        color: #4cd964;
    }
    
    .negative-change {
        color: #ff3b30;
    }
    
    /* Button styling */
    button[kind="primary"] {
        background: linear-gradient(90deg, #5c42e5, #7958ff);
        border-radius: 30px;
        transition: all 0.3s ease;
        box-shadow: 0 4px 12px rgba(91, 66, 229, 0.3);
        border: none;
    }
    
    button[kind="primary"]:hover {
        box-shadow: 0 6px 16px rgba(91, 66, 229, 0.5);
    }
    
    /* Chart styling */
    .js-plotly-plot {
        border-radius: 15px;
        overflow: hidden;
    }
    
    /* Sidebar tweaks */
    .stSidebar {
        background-color: #151730;
        border-right: 1px solid rgba(255, 255, 255, 0.05);
    }
    
    div[data-testid="stSidebarNav"] {
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 15px;
        padding: 1rem;
    }
    
    /* Chart area */
    .chart-area {
        background-color: var(--card-bg);
        border-radius: 24px;
        padding: 1rem;
        margin-top: 1rem;
        border: 1px solid rgba(255, 255, 255, 0.03);
    }
    
    /* Add a container for the circular chart */
    .circular-chart-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 1rem;
    }
    
    /* Period selector styling */
    .period-selector {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 1rem;
    }
    
    .period-selector button {
        background-color: transparent;
        border: none;
        color: var(--text-secondary);
        padding: 0.5rem 1rem;
        margin-left: 0.5rem;
        border-radius: 20px;
        cursor: pointer;
    }
    
    .period-selector button.active {
        background-color: rgba(255, 255, 255, 0.1);
        color: var(--text-color);
    }
    
    /* Footer styling */
    .footer {
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 15px;
        padding: 1rem;
        text-align: center;
        margin-top: 2rem;
        border: 1px solid rgba(255, 255, 255, 0.05);
    }
</style>
""", unsafe_allow_html=True)

# Sidebar
with st.sidebar:
    st.image("https://www.python.org/static/community_logos/python-logo-generic.svg", width=200)
    st.markdown("<h2 style='color: #ffffff; text-align: center;'>Data Explorer</h2>", unsafe_allow_html=True)
    
    data_source = st.selectbox(
        "Choose a data source",
        ["Stock Market", "COVID-19 Statistics", "Weather Data", "Cryptocurrency"]
    )
    
    st.divider()
    
    with st.expander("About", expanded=True):
        st.write("""
        This dashboard visualizes different types of data from various internet sources.
        Select a data source from the dropdown above to explore different visualizations.
        """)

# Main content
st.markdown('<h1 class="main-header">Interactive Data Visualization Dashboard</h1>', unsafe_allow_html=True)

# Function to get stock data
def get_stock_data():
    tickers = ["AAPL", "MSFT", "GOOG", "AMZN", "META"]
    end = datetime.now()
    start = end - timedelta(days=365)
    
    data = {}
    for ticker in tickers:
        stock = yf.Ticker(ticker)
        data[ticker] = stock.history(start=start, end=end)
    
    return data

# Function to get COVID data
def get_covid_data():
    try:
        response = requests.get("https://disease.sh/v3/covid-19/historical/all?lastdays=all")
        data = response.json()
        return data
    except Exception as e:
        st.error(f"Failed to fetch COVID data: {e}")
        return None

# Function to get weather data
def get_weather_data():
    cities = ["London", "New York", "Tokyo", "Sydney", "Paris"]
    api_key = "4f0c5f237b428798b92e8e5d42f38d32"  # This is a sample key, won't work in production
    
    weather_data = {}
    for city in cities:
        try:
            response = requests.get(f"https://samples.openweathermap.org/data/2.5/forecast?q={city}&appid={api_key}")
            weather_data[city] = response.json()
        except:
            # Use sample data if API fails
            weather_data[city] = {
                "temp": np.random.normal(20, 5, 10).tolist(),
                "humidity": np.random.normal(60, 10, 10).tolist(),
                "pressure": np.random.normal(1013, 5, 10).tolist(),
            }
    
    return weather_data

# Function to get cryptocurrency data
def get_crypto_data():
    try:
        response = requests.get("https://api.coincap.io/v2/assets?limit=10")
        data = response.json()
        return data["data"]
    except:
        # Sample data if API fails
        return [
            {"id": "bitcoin", "symbol": "BTC", "priceUsd": "45000", "changePercent24Hr": "2.5"},
            {"id": "ethereum", "symbol": "ETH", "priceUsd": "3000", "changePercent24Hr": "1.8"},
            {"id": "ripple", "symbol": "XRP", "priceUsd": "0.8", "changePercent24Hr": "-0.5"},
            {"id": "cardano", "symbol": "ADA", "priceUsd": "1.2", "changePercent24Hr": "3.2"},
            {"id": "solana", "symbol": "SOL", "priceUsd": "40", "changePercent24Hr": "4.1"},
        ]

# Function to create donut chart
def create_donut_chart(values, labels, colors):
    fig = go.Figure()
    fig.add_trace(go.Pie(
        values=values,
        labels=labels,
        hole=0.7,
        marker=dict(colors=colors),
        textinfo='none',
        hoverinfo='label+percent',
    ))
    
    fig.update_layout(
        showlegend=False,
        margin=dict(t=0, b=0, l=0, r=0),
        height=300,
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
    )
    
    return fig

# Function to create a line chart
def create_line_chart(data, x_vals=None, y_vals=None, color='#5c42e5'):
    fig = go.Figure()
    
    if x_vals is None or y_vals is None:
        # Create x-axis dates (30 days)
        dates = pd.date_range(end=datetime.now(), periods=30).tolist()
        
        # Generate some smooth random data
        y_values = np.cumsum(np.random.normal(0, 3, 30)) + 100
        normalized = (y_values - min(y_values)) / (max(y_values) - min(y_values)) * 50 + 75
        
        x_vals = dates
        y_vals = normalized
    
    fig.add_trace(go.Scatter(
        x=x_vals,
        y=y_vals,
        mode='lines',
        line=dict(color=color, width=3),
        fill='tozeroy',
        fillcolor=f'rgba({int(color[1:3], 16)}, {int(color[3:5], 16)}, {int(color[5:7], 16)}, 0.1)'
    ))
    
    fig.update_layout(
        margin=dict(t=10, b=10, l=10, r=10),
        height=300,
        paper_bgcolor='rgba(0,0,0,0)',
        plot_bgcolor='rgba(0,0,0,0)',
        xaxis=dict(
            showgrid=True,
            gridcolor='rgba(255, 255, 255, 0.05)',
            showticklabels=True,
            tickfont=dict(color='rgba(255, 255, 255, 0.5)'),
        ),
        yaxis=dict(
            showgrid=True,
            gridcolor='rgba(255, 255, 255, 0.05)',
            showticklabels=True,
            tickfont=dict(color='rgba(255, 255, 255, 0.5)'),
        ),
    )
    
    return fig

# Function to create wallet cards
def create_wallet_card(icon, amount, symbol, change, css_class):
    change_class = "positive-change" if float(change) > 0 else "negative-change"
    change_symbol = "↑" if float(change) > 0 else "↓"
    change_html = f'<div class="coin-change {change_class}">{change_symbol} {abs(float(change)):.2f}%</div>'
    
    html = f"""
    <div class="{css_class}">
        <div class="coin-icon">{icon}</div>
        <div class="coin-amount">{float(amount):.4f}</div>
        <div class="coin-symbol">{symbol}</div>
        {change_html}
    </div>
    """
    return html

# Load and display data based on selection
if data_source == "Stock Market":
    st.markdown('<h2 class="sub-header">Stock Market Analysis</h2>', unsafe_allow_html=True)
    
    with st.spinner("Fetching stock market data..."):
        stock_data = get_stock_data()
        
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown('<div class="dashboard-container purple-card">', unsafe_allow_html=True)
        st.subheader("Stock Price Comparison")
        fig = go.Figure()
        
        for ticker, data in stock_data.items():
            fig.add_trace(go.Scatter(
                x=data.index,
                y=data['Close'],
                mode='lines',
                name=ticker
            ))
        
        fig.update_layout(
            title="Closing Prices Over Last Year",
            xaxis_title="Date",
            yaxis_title="Price (USD)",
            template="plotly_dark",
            height=500,
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            legend=dict(font=dict(color="white")),
            title_font=dict(color="white"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
        )
        st.plotly_chart(fig, use_container_width=True)
        st.markdown('</div>', unsafe_allow_html=True)
    
    with col2:
        st.markdown('<div class="dashboard-container blue-card">', unsafe_allow_html=True)
        st.subheader("Stock Performance")
        # Calculate percentage change
        perf_data = {}
        for ticker, data in stock_data.items():
            first_price = data['Close'].iloc[0]
            last_price = data['Close'].iloc[-1]
            perf_data[ticker] = ((last_price - first_price) / first_price) * 100
        
        # Create bar chart
        fig = px.bar(
            x=list(perf_data.keys()),
            y=list(perf_data.values()),
            color=list(perf_data.values()),
            color_continuous_scale="viridis",
            labels={'x': 'Company', 'y': 'Return (%)'},
            title="Annual Return (%)"
        )
        
        fig.update_layout(
            height=500,
            template="plotly_dark",
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            title_font=dict(color="white"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
        )
        st.plotly_chart(fig, use_container_width=True)
        st.markdown('</div>', unsafe_allow_html=True)
    
    # Trading volume
    st.markdown('<div class="dashboard-container orange-card">', unsafe_allow_html=True)
    st.subheader("Trading Volume Analysis")
    
    selected_ticker = st.selectbox("Select a stock", list(stock_data.keys()))
    
    volume_fig = px.area(
        stock_data[selected_ticker],
        x=stock_data[selected_ticker].index,
        y="Volume",
        title=f"{selected_ticker} Trading Volume"
    )
    volume_fig.update_layout(
        height=400,
        template="plotly_dark",
        paper_bgcolor="rgba(0,0,0,0)",
        plot_bgcolor="rgba(0,0,0,0)",
        title_font=dict(color="white"),
        xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
        yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
    )
    st.plotly_chart(volume_fig, use_container_width=True)
    st.markdown('</div>', unsafe_allow_html=True)

elif data_source == "COVID-19 Statistics":
    st.markdown('<h2 class="sub-header">COVID-19 Global Statistics</h2>', unsafe_allow_html=True)
    
    with st.spinner("Fetching COVID-19 data..."):
        covid_data = get_covid_data()
    
    if covid_data:
        # Create dataframes from the data
        cases_df = pd.DataFrame(list(covid_data['cases'].items()), columns=['date', 'cases'])
        deaths_df = pd.DataFrame(list(covid_data['deaths'].items()), columns=['date', 'deaths'])
        recovered_df = pd.DataFrame(list(covid_data['recovered'].items() if 'recovered' in covid_data else []), columns=['date', 'recovered'])
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown('<div class="dashboard-container purple-card">', unsafe_allow_html=True)
            st.subheader("Global Cases Over Time")
            fig = px.line(
                cases_df,
                x='date',
                y='cases',
                title="Cumulative COVID-19 Cases Worldwide",
                labels={'cases': 'Cases', 'date': 'Date'}
            )
            fig.update_layout(
                height=500,
                template="plotly_dark",
                paper_bgcolor="rgba(0,0,0,0)",
                plot_bgcolor="rgba(0,0,0,0)",
                title_font=dict(color="white"),
                xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
                yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            )
            st.plotly_chart(fig, use_container_width=True)
            st.markdown('</div>', unsafe_allow_html=True)
        
        with col2:
            st.markdown('<div class="dashboard-container blue-card">', unsafe_allow_html=True)
            st.subheader("Global Deaths Over Time")
            fig = px.line(
                deaths_df,
                x='date',
                y='deaths',
                title="Cumulative COVID-19 Deaths Worldwide",
                labels={'deaths': 'Deaths', 'date': 'Date'}
            )
            fig.update_layout(
                height=500,
                template="plotly_dark",
                paper_bgcolor="rgba(0,0,0,0)",
                plot_bgcolor="rgba(0,0,0,0)",
                title_font=dict(color="white"),
                xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
                yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            )
            st.plotly_chart(fig, use_container_width=True)
            st.markdown('</div>', unsafe_allow_html=True)
        
        # Daily new cases calculation
        cases_df['new_cases'] = cases_df['cases'].diff().fillna(0)
        
        st.markdown('<div class="dashboard-container orange-card">', unsafe_allow_html=True)
        st.subheader("Daily New Cases")
        
        # Filter for last year
        recent_df = cases_df.tail(365)
        
        fig = px.bar(
            recent_df,
            x='date',
            y='new_cases',
            title="Daily New COVID-19 Cases",
            labels={'new_cases': 'New Cases', 'date': 'Date'}
        )
        
        fig.update_layout(
            height=400,
            template="plotly_dark",
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            title_font=dict(color="white"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
        )
        st.plotly_chart(fig, use_container_width=True)
        st.markdown('</div>', unsafe_allow_html=True)

elif data_source == "Weather Data":
    st.markdown('<h2 class="sub-header">Global Weather Analysis</h2>', unsafe_allow_html=True)
    
    with st.spinner("Fetching weather data..."):
        # Due to API limitations, we'll generate sample data
        cities = ["London", "New York", "Tokyo", "Sydney", "Paris"]
        weather_data = {
            city: {
                "dates": pd.date_range(start=datetime.now() - timedelta(days=10), periods=10, freq='D'),
                "temp": np.random.normal(20, 5, 10),
                "humidity": np.random.normal(60, 10, 10),
                "pressure": np.random.normal(1013, 5, 10),
            } for city in cities
        }
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown('<div class="dashboard-container purple-card">', unsafe_allow_html=True)
        st.subheader("Temperature Comparison")
        
        temps_df = pd.DataFrame({
            city: data["temp"] for city, data in weather_data.items()
        }, index=weather_data["London"]["dates"])
        
        fig = px.line(
            temps_df,
            x=temps_df.index,
            y=temps_df.columns,
            labels={"value": "Temperature (°C)", "variable": "City"},
            title="Temperature Trends by City"
        )
        
        fig.update_layout(
            height=500,
            template="plotly_dark",
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            title_font=dict(color="white"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            legend=dict(font=dict(color="white")),
        )
        st.plotly_chart(fig, use_container_width=True)
        st.markdown('</div>', unsafe_allow_html=True)
    
    with col2:
        st.markdown('<div class="dashboard-container blue-card">', unsafe_allow_html=True)
        st.subheader("Humidity Comparison")
        
        humidity_df = pd.DataFrame({
            city: data["humidity"] for city, data in weather_data.items()
        }, index=weather_data["London"]["dates"])
        
        fig = px.line(
            humidity_df,
            x=humidity_df.index,
            y=humidity_df.columns,
            labels={"value": "Humidity (%)", "variable": "City"},
            title="Humidity Trends by City"
        )
        
        fig.update_layout(
            height=500,
            template="plotly_dark",
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            title_font=dict(color="white"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            yaxis=dict(gridcolor="rgba(255,255,255,0.1)"),
            legend=dict(font=dict(color="white")),
        )
        st.plotly_chart(fig, use_container_width=True)
        st.markdown('</div>', unsafe_allow_html=True)
    
    # Correlation heatmap
    st.markdown('<div class="dashboard-container orange-card">', unsafe_allow_html=True)
    st.subheader("Weather Metrics Correlation")
    
    selected_city = st.selectbox("Select a city", cities)
    
    # Create a correlation matrix for the selected city
    city_df = pd.DataFrame({
        "temperature": weather_data[selected_city]["temp"],
        "humidity": weather_data[selected_city]["humidity"],
        "pressure": weather_data[selected_city]["pressure"]
    })
    
    corr = city_df.corr()
    
    fig, ax = plt.subplots(figsize=(10, 8))
    sns.set(style="dark")
    sns.heatmap(corr, annot=True, cmap="inferno", ax=ax)
    plt.title(f"Weather Metrics Correlation for {selected_city}")
    
    # Set the figure's background to be transparent
    fig.patch.set_facecolor('none')
    ax.set_facecolor('none')
    
    st.pyplot(fig)
    st.markdown('</div>', unsafe_allow_html=True)

elif data_source == "Cryptocurrency":
    st.markdown('<h2 class="sub-header">Cryptocurrency Market</h2>', unsafe_allow_html=True)
    
    with st.spinner("Fetching cryptocurrency data..."):
        crypto_data = get_crypto_data()
        crypto_df = pd.DataFrame(crypto_data)
        crypto_df["priceUsd"] = crypto_df["priceUsd"].astype(float).round(2)
        crypto_df["changePercent24Hr"] = crypto_df["changePercent24Hr"].astype(float).round(2)
        crypto_df["value"] = crypto_df["priceUsd"] * np.random.uniform(0.1, 2, len(crypto_df))  # Simulated holdings

    # Calculate total value
    total_value = crypto_df["value"].sum().round(2)

    # Display total balance
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        st.markdown(f'<div class="balance-header">{total_value:.2f}</div>', unsafe_allow_html=True)
        st.markdown('<div class="balance-currency">USD</div>', unsafe_allow_html=True)

    # Portfolio allocation graph
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        # Portfolio composition circle
        st.markdown('<div class="dashboard-container circular-chart-container">', unsafe_allow_html=True)
        
        # Create data for the donut chart
        top_cryptos = crypto_df.nlargest(3, 'value')
        other_value = crypto_df.nsmallest(len(crypto_df) - 3, 'value')['value'].sum()
        
        values = top_cryptos['value'].tolist() + [other_value]
        labels = top_cryptos['symbol'].tolist() + ['Other']
        colors = ['#6b4ef9', '#3279fc', '#ff7d46', '#a8b1d6']
        
        # Calculate total return
        total_return = ((crypto_df['value'] * crypto_df['changePercent24Hr']).sum() / total_value)
        total_return_pct = total_return.round(1)
        
        # Create a donut chart showing portfolio allocation
        donut_chart = create_donut_chart(values, labels, colors)
        
        # Add the total return in the center of the donut
        donut_chart.add_annotation(
            text=f"{'+' if total_return_pct > 0 else ''}{total_return_pct}%",
            font=dict(size=30, color="#ffffff"),
            showarrow=False,
        )
        donut_chart.add_annotation(
            text="Total",
            y=0.85,
            font=dict(size=14, color="#a8b1d6"),
            showarrow=False,
        )
        
        st.plotly_chart(donut_chart, use_container_width=True)
        st.markdown('</div>', unsafe_allow_html=True)

    # Crypto wallet cards
    st.markdown("<div style='padding: 0.5rem;'></div>", unsafe_allow_html=True)
    col1, col2, col3, col4 = st.columns([0.1, 1, 1, 0.1])

    with col2:
        # ETH wallet
        eth_data = crypto_df[crypto_df['symbol'] == 'ETH'].iloc[0] if 'ETH' in crypto_df['symbol'].values else crypto_df.iloc[0]
        eth_amount = np.random.uniform(0.5, 5)
        eth_change = eth_data['changePercent24Hr']
        st.markdown(create_wallet_card('⟠', eth_amount, 'ETH', eth_change, 'purple-wallet'), unsafe_allow_html=True)

    with col3:
        # BTC wallet
        btc_data = crypto_df[crypto_df['symbol'] == 'BTC'].iloc[0] if 'BTC' in crypto_df['symbol'].values else crypto_df.iloc[1]
        btc_amount = np.random.uniform(0.05, 0.5)
        btc_change = btc_data['changePercent24Hr']
        st.markdown(create_wallet_card('₿', btc_amount, 'BTC', btc_change, 'blue-wallet'), unsafe_allow_html=True)

    # Exchange rates
    st.markdown("<div style='padding: 0.5rem;'></div>", unsafe_allow_html=True)
    col1, col2, col3 = st.columns([0.1, 1, 0.1])
    with col2:
        st.markdown('<div class="dashboard-container">', unsafe_allow_html=True)
        
        # Generate random exchange rate data
        eth_price = float(crypto_df[crypto_df['symbol'] == 'ETH']['priceUsd'].iloc[0]) if 'ETH' in crypto_df['symbol'].values else 3000
        eth_usd = 1/eth_price
        
        st.markdown(f"""
        <div style='display: flex; justify-content: space-between; margin-bottom: 2rem;'>
            <div>
                <h3 style='margin: 0; font-size: 2.5rem; font-weight: 700;'>{eth_price:.2f}</h3>
                <p style='margin: 0; color: var(--text-secondary);'>1 ETH = ${eth_price:.2f}</p>
            </div>
            <div>
                <h3 style='margin: 0; font-size: 2.5rem; font-weight: 700;'>{eth_usd:.6f}</h3>
                <p style='margin: 0; color: var(--text-secondary);'>1 USD = {eth_usd:.6f} ETH</p>
            </div>
        </div>
        """, unsafe_allow_html=True)
        
        # Period selector
        st.markdown("""
        <div class='period-selector'>
            <button class='active'>DAILY</button>
            <button>MONTH</button>
            <button>YEAR</button>
        </div>
        """, unsafe_allow_html=True)
        
        # Price chart
        line_chart = create_line_chart(None)
        st.plotly_chart(line_chart, use_container_width=True)
        
        st.markdown('</div>', unsafe_allow_html=True)

# Footer
st.markdown("""
<div class="footer">
    <p>Built with Streamlit and ❤️</p>
    <p style="color: rgba(255,255,255,0.7);">Data sources: Yahoo Finance, disease.sh, OpenWeatherMap, CoinCap</p>
</div>
""", unsafe_allow_html=True) 