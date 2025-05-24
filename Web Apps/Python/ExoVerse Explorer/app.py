import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import requests
from sklearn.preprocessing import MinMaxScaler
from PIL import Image
import io
import base64

# Set page configuration
st.set_page_config(
    page_title="ExoVerse Explorer",
    page_icon="🪐",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
def add_custom_css():
    st.markdown("""
    <style>
    .main {
        background-color: #0E1117;
        color: white;
    }
    .stApp {
        background: linear-gradient(to right, #0E1117, #1E2130);
    }
    .stSidebar {
        background-color: rgba(17, 23, 36, 0.7);
        backdrop-filter: blur(10px);
    }
    .stHeader {
        background-color: transparent !important;
    }
    .stButton>button {
        background-color: #4B56D2;
        color: white;
        border-radius: 20px;
        padding: 10px 25px;
        font-weight: bold;
        border: none;
        transition: all 0.3s ease;
    }
    .stButton>button:hover {
        background-color: #5D6AD2;
        transform: translateY(-2px);
        box-shadow: 0px 5px 15px rgba(75, 86, 210, 0.4);
    }
    h1, h2, h3 {
        color: #d6e0ff;
    }
    .planet-card {
        background-color: rgba(30, 41, 59, 0.7);
        border-radius: 10px;
        padding: 20px;
        margin: 10px 0px;
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255, 255, 255, 0.1);
    }
    </style>
    """, unsafe_allow_html=True)

add_custom_css()

# Create animated stars background
def stars_background():
    st.markdown("""
    <style>
    @keyframes twinkle {
        0% { opacity: 0.2; }
        50% { opacity: 1; }
        100% { opacity: 0.2; }
    }
    
    .stars {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        z-index: -1;
    }
    
    .star {
        position: absolute;
        background-color: white;
        border-radius: 50%;
    }
    </style>
    
    <div class="stars" id="stars">
    <script>
        const starsContainer = document.getElementById('stars');
        const starCount = 150;
        
        for (let i = 0; i < starCount; i++) {
            const star = document.createElement('div');
            const size = Math.random() * 2;
            
            star.className = 'star';
            star.style.width = `${size}px`;
            star.style.height = `${size}px`;
            star.style.top = `${Math.random() * 100}%`;
            star.style.left = `${Math.random() * 100}%`;
            star.style.animation = `twinkle ${3 + Math.random() * 7}s infinite ${Math.random() * 5}s`;
            
            starsContainer.appendChild(star);
        }
    </script>
    </div>
    """, unsafe_allow_html=True)

stars_background()

# App title and description
col1, col2 = st.columns([3, 1])
with col1:
    st.title("🪐 ExoVerse Explorer")
    st.markdown("""
    Discover and analyze exoplanets from NASA's database. This interactive dashboard allows you to explore 
    alien worlds beyond our solar system, visualize their properties, and understand what makes them unique.
    """)

# Create a loading animation for initial data fetch
def loading_animation():
    cols = st.columns(5)
    for col in cols:
        col.markdown("🚀")
    st.markdown("## Loading Exoplanet Data...")
    progress_bar = st.progress(0)
    for percent_complete in range(100):
        progress_bar.progress(percent_complete + 1)
        if percent_complete == 99:
            progress_bar.empty()

@st.cache_data(ttl=3600)
def fetch_exoplanet_data():
    """Fetch exoplanet data from NASA Exoplanet Archive"""
    loading_animation()
    url = "https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+pl_name,hostname,discoverymethod,disc_year,pl_orbper,pl_rade,pl_bmasse,pl_orbeccen,pl_eqt,pl_insol,st_teff,st_rad,st_mass,sy_dist&format=csv"
    try:
        data = pd.read_csv(url)
        return data
    except Exception as e:
        # If the external API fails, use generated example data
        st.warning("Could not connect to NASA Exoplanet Archive. Using sample data instead.")
        return generate_sample_data()

def generate_sample_data(n=500):
    """Generate sample exoplanet data if API fails"""
    np.random.seed(42)
    methods = ['Transit', 'Radial Velocity', 'Microlensing', 'Imaging', 'Timing Variations']
    names = [f"Exoplanet-{i}" for i in range(1, n+1)]
    hostnames = [f"Star-{i}" for i in range(1, n+1)]
    
    data = pd.DataFrame({
        'pl_name': names,
        'hostname': hostnames,
        'discoverymethod': np.random.choice(methods, n),
        'disc_year': np.random.randint(1995, 2023, n),
        'pl_orbper': np.random.exponential(100, n),  # Orbital period in days
        'pl_rade': np.random.lognormal(0.5, 0.8, n),  # Planet radius in Earth radii
        'pl_bmasse': np.random.lognormal(0.5, 1.5, n),  # Planet mass in Earth masses
        'pl_orbeccen': np.random.beta(1, 5, n),  # Orbital eccentricity
        'pl_eqt': np.random.normal(500, 300, n),  # Equilibrium temperature in K
        'pl_insol': np.random.exponential(200, n),  # Insolation flux
        'st_teff': np.random.normal(5500, 1000, n),  # Star temperature in K
        'st_rad': np.random.lognormal(0, 0.5, n),  # Star radius in Solar radii
        'st_mass': np.random.lognormal(0, 0.3, n),  # Star mass in Solar masses
        'sy_dist': np.random.exponential(300, n)  # Distance from Earth in parsecs
    })
    
    return data

# Fetch the exoplanet data
exoplanet_data = fetch_exoplanet_data()

# Clean data
exoplanet_data = exoplanet_data.replace([np.inf, -np.inf], np.nan)
exoplanet_data = exoplanet_data.fillna({
    'pl_orbper': exoplanet_data['pl_orbper'].median(),
    'pl_rade': exoplanet_data['pl_rade'].median(),
    'pl_bmasse': exoplanet_data['pl_bmasse'].median(),
    'pl_orbeccen': exoplanet_data['pl_orbeccen'].median(),
    'pl_eqt': exoplanet_data['pl_eqt'].median(),
    'pl_insol': exoplanet_data['pl_insol'].median(),
    'st_teff': exoplanet_data['st_teff'].median(),
    'st_rad': exoplanet_data['st_rad'].median(),
    'st_mass': exoplanet_data['st_mass'].median(),
    'sy_dist': exoplanet_data['sy_dist'].median(),
})

# Sidebar for filters
st.sidebar.title("🌌 Explorer Controls")

# Year range slider
min_year = int(exoplanet_data['disc_year'].min())
max_year = int(exoplanet_data['disc_year'].max())
year_range = st.sidebar.slider("Discovery Year", min_year, max_year, (min_year, max_year))

# Discovery method selection
methods = ['All'] + sorted(exoplanet_data['discoverymethod'].unique().tolist())
selected_method = st.sidebar.selectbox("Discovery Method", methods)

# Planet properties filters
st.sidebar.subheader("Planet Properties")
min_radius = float(exoplanet_data['pl_rade'].min())
max_radius = float(exoplanet_data['pl_rade'].max())
radius_range = st.sidebar.slider("Planet Radius (Earth Radii)", min_radius, max_radius, (min_radius, max_radius))

# Apply filters
filtered_data = exoplanet_data.copy()
filtered_data = filtered_data[
    (filtered_data['disc_year'] >= year_range[0]) & 
    (filtered_data['disc_year'] <= year_range[1]) &
    (filtered_data['pl_rade'] >= radius_range[0]) & 
    (filtered_data['pl_rade'] <= radius_range[1])
]

if selected_method != 'All':
    filtered_data = filtered_data[filtered_data['discoverymethod'] == selected_method]

# Display metrics
st.sidebar.markdown("---")
st.sidebar.subheader("Current Selection")
st.sidebar.metric("Exoplanets", len(filtered_data))
st.sidebar.metric("Unique Star Systems", len(filtered_data['hostname'].unique()))

# Create color scheme for visualization based on star temperature
def get_star_color(temp):
    if temp < 3700:
        return "#FF4500"  # Red
    elif temp < 5200:
        return "#FF8C00"  # Orange
    elif temp < 6000:
        return "#FFD700"  # Yellow
    elif temp < 7500:
        return "#F8F8FF"  # White
    else:
        return "#ADD8E6"  # Blue

filtered_data['star_color'] = filtered_data['st_teff'].apply(get_star_color)

# Main dashboard area
tab1, tab2, tab3 = st.tabs(["📊 Visual Explorer", "🔎 Detailed Analysis", "🌍 Habitability Finder"])

with tab1:
    st.header("Visual Explorer")
    
    # Create a visualization selection
    viz_type = st.selectbox(
        "Choose Visualization",
        ["Planet Size vs. Orbital Period", "Discovery Timeline", "Star System Map", "Planet Type Distribution"]
    )
    
    if viz_type == "Planet Size vs. Orbital Period":
        fig = px.scatter(
            filtered_data,
            x="pl_orbper",
            y="pl_rade",
            size="pl_bmasse",
            color="star_color",
            hover_name="pl_name",
            log_x=True,
            labels={
                "pl_orbper": "Orbital Period (days, log scale)",
                "pl_rade": "Planet Radius (Earth radii)",
                "pl_bmasse": "Planet Mass (Earth masses)"
            },
            title="Exoplanet Size vs. Orbital Period"
        )
        fig.update_layout(
            template="plotly_dark",
            plot_bgcolor="rgba(0, 0, 0, 0)",
            paper_bgcolor="rgba(0, 0, 0, 0)",
            height=600
        )
        st.plotly_chart(fig, use_container_width=True)
        
    elif viz_type == "Discovery Timeline":
        yearly_counts = filtered_data.groupby('disc_year').size().reset_index(name='count')
        fig = px.bar(
            yearly_counts,
            x="disc_year",
            y="count",
            labels={"disc_year": "Discovery Year", "count": "Number of Exoplanets"},
            title="Exoplanet Discoveries by Year"
        )
        fig.update_layout(
            template="plotly_dark",
            plot_bgcolor="rgba(0, 0, 0, 0)",
            paper_bgcolor="rgba(0, 0, 0, 0)",
        )
        st.plotly_chart(fig, use_container_width=True)
        
    elif viz_type == "Star System Map":
        # Taking a sample if there are too many data points
        display_data = filtered_data if len(filtered_data) < 500 else filtered_data.sample(500)
        
        # Create a 3D scatter plot of star systems
        # Using distance and randomized positions for visualization
        display_data['x_pos'] = display_data['sy_dist'] * np.cos(np.random.rand(len(display_data)) * 2 * np.pi)
        display_data['y_pos'] = display_data['sy_dist'] * np.sin(np.random.rand(len(display_data)) * 2 * np.pi)
        display_data['z_pos'] = (display_data['sy_dist'] * np.cos(np.random.rand(len(display_data)) * np.pi)) - 50
        
        fig = px.scatter_3d(
            display_data,
            x='x_pos',
            y='y_pos',
            z='z_pos',
            color='star_color',
            size='pl_rade',
            hover_name='pl_name',
            hover_data=['hostname', 'sy_dist'],
            opacity=0.7,
            title="3D Star Map (Based on Distance)"
        )
        
        fig.update_layout(
            template="plotly_dark",
            scene=dict(
                xaxis_title='X (parsecs)',
                yaxis_title='Y (parsecs)',
                zaxis_title='Z (parsecs)'
            ),
            plot_bgcolor="rgba(0, 0, 0, 0)",
            paper_bgcolor="rgba(0, 0, 0, 0)",
            height=700
        )
        st.plotly_chart(fig, use_container_width=True)
        
    elif viz_type == "Planet Type Distribution":
        # Define planet categories
        def categorize_planet(row):
            radius = row['pl_rade']
            temp = row['pl_eqt'] if not np.isnan(row['pl_eqt']) else 300
            
            if radius < 1.6:
                return "Rocky (Earth-like)"
            elif radius < 3.5:
                return "Mini-Neptune"
            elif radius < 6:
                return "Neptune-like"
            elif radius < 15:
                return "Jupiter-like"
            else:
                return "Super-Jupiter"
        
        filtered_data['planet_type'] = filtered_data.apply(categorize_planet, axis=1)
        
        # Create a pie chart
        type_counts = filtered_data['planet_type'].value_counts().reset_index()
        type_counts.columns = ['planet_type', 'count']
        
        fig = px.pie(
            type_counts,
            values='count',
            names='planet_type',
            title="Distribution of Planet Types",
            color_discrete_sequence=px.colors.qualitative.Plotly
        )
        fig.update_layout(
            template="plotly_dark",
            plot_bgcolor="rgba(0, 0, 0, 0)",
            paper_bgcolor="rgba(0, 0, 0, 0)"
        )
        st.plotly_chart(fig, use_container_width=True)

with tab2:
    st.header("Detailed Analysis")
    
    # Search functionality
    search_term = st.text_input("Search exoplanets by name", "")
    
    if search_term:
        search_results = filtered_data[filtered_data['pl_name'].str.contains(search_term, case=False) | 
                                      filtered_data['hostname'].str.contains(search_term, case=False)]
        if not search_results.empty:
            st.write(f"Found {len(search_results)} matching exoplanets")
            for _, planet in search_results.iterrows():
                with st.container():
                    st.markdown(f"""
                    <div class="planet-card">
                        <h3>{planet['pl_name']} - {planet['hostname']}</h3>
                        <p>🔍 Discovered in {int(planet['disc_year'])} via {planet['discoverymethod']}</p>
                        <p>📏 Size: {planet['pl_rade']:.2f} Earth radii | 
                           ⚖️ Mass: {planet['pl_bmasse']:.2f} Earth masses if available</p>
                        <p>🌡️ Equilibrium Temperature: {planet['pl_eqt']:.0f} K | 
                           🔄 Orbital Period: {planet['pl_orbper']:.2f} days</p>
                        <p>✨ Star Temperature: {planet['st_teff']:.0f} K | 
                           📍 System Distance: {planet['sy_dist']:.1f} parsecs</p>
                    </div>
                    """, unsafe_allow_html=True)
        else:
            st.info("No matching exoplanets found. Try another search term.")
    
    # Data correlation analysis
    st.subheader("Correlation Analysis")
    correlation_features = st.multiselect(
        "Select features to analyze correlation",
        options=['pl_orbper', 'pl_rade', 'pl_bmasse', 'pl_eqt', 'st_teff', 'st_rad', 'st_mass', 'sy_dist'],
        default=['pl_orbper', 'pl_rade']
    )
    
    if len(correlation_features) >= 2:
        correlation_data = filtered_data[correlation_features].corr()
        
        fig = px.imshow(
            correlation_data,
            text_auto=True,
            aspect="auto",
            color_continuous_scale=px.colors.sequential.Viridis
        )
        fig.update_layout(
            template="plotly_dark",
            plot_bgcolor="rgba(0, 0, 0, 0)",
            paper_bgcolor="rgba(0, 0, 0, 0)"
        )
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("Please select at least two features to analyze correlation")

with tab3:
    st.header("Habitability Finder")
    
    st.markdown("""
    This tool helps identify potentially habitable exoplanets based on key parameters.
    Adjust the sliders below to find planets within specific habitability criteria.
    """)
    
    # Habitability parameters
    col1, col2 = st.columns(2)
    
    with col1:
        hab_temp_range = st.slider(
            "Temperature Range (K)",
            200, 500, (250, 350),
            help="Earth's average equilibrium temperature is ~255K"
        )
        
        hab_size_range = st.slider(
            "Planet Size (Earth Radii)",
            0.5, 2.5, (0.8, 1.5),
            help="Earth-sized planets are 1.0 Earth radii"
        )
    
    with col2:
        hab_orbit_range = st.slider(
            "Orbital Period (Earth Days)",
            0, 1000, (200, 500),
            help="Earth's orbital period is 365.25 days"
        )
        
        hab_star_temp = st.slider(
            "Star Temperature (K)",
            2000, 8000, (4500, 6500),
            help="Our Sun's temperature is ~5700K"
        )
    
    # Apply habitability filters
    habitable_planets = filtered_data[
        (filtered_data['pl_eqt'] >= hab_temp_range[0]) &
        (filtered_data['pl_eqt'] <= hab_temp_range[1]) &
        (filtered_data['pl_rade'] >= hab_size_range[0]) &
        (filtered_data['pl_rade'] <= hab_size_range[1]) &
        (filtered_data['pl_orbper'] >= hab_orbit_range[0]) &
        (filtered_data['pl_orbper'] <= hab_orbit_range[1]) &
        (filtered_data['st_teff'] >= hab_star_temp[0]) &
        (filtered_data['st_teff'] <= hab_star_temp[1])
    ]
    
    # Calculate a habitability score (simple version)
    def calculate_hab_score(planet):
        # These are simplified weights - a real model would be more complex
        temp_weight = 0.4
        size_weight = 0.3
        orbit_weight = 0.2
        star_weight = 0.1
        
        # Normalize scores between 0-1 where 1 is Earth-like
        temp_score = 1 - min(abs(planet['pl_eqt'] - 255) / 200, 1)
        size_score = 1 - min(abs(planet['pl_rade'] - 1) / 1.5, 1)
        orbit_score = 1 - min(abs(planet['pl_orbper'] - 365.25) / 300, 1)
        star_score = 1 - min(abs(planet['st_teff'] - 5700) / 1500, 1)
        
        total_score = (temp_score * temp_weight +
                      size_score * size_weight +
                      orbit_score * orbit_weight +
                      star_score * star_weight) * 100
        
        return max(min(total_score, 100), 0)  # Cap between 0-100
    
    if len(habitable_planets) > 0:
        habitable_planets['hab_score'] = habitable_planets.apply(calculate_hab_score, axis=1)
        habitable_planets = habitable_planets.sort_values('hab_score', ascending=False)
        
        st.markdown(f"### Found {len(habitable_planets)} Potentially Habitable Exoplanets")
        
        # Show top 10 with habitability scores
        for _, planet in habitable_planets.head(10).iterrows():
            score = planet['hab_score']
            score_color = "#ff0000" if score < 50 else "#ffcc00" if score < 75 else "#00cc44"
            
            with st.container():
                st.markdown(f"""
                <div class="planet-card">
                    <div style="display: flex; justify-content: space-between; align-items: center">
                        <h3>{planet['pl_name']}</h3>
                        <div style="background-color: {score_color}; color: black; padding: 5px 10px; 
                                   border-radius: 20px; font-weight: bold;">
                            Score: {score:.1f}/100
                        </div>
                    </div>
                    <p>Star System: {planet['hostname']} | Distance: {planet['sy_dist']:.1f} parsecs</p>
                    <p>🌡️ Temperature: {planet['pl_eqt']:.0f} K | 
                       📏 Size: {planet['pl_rade']:.2f} Earth radii</p>
                    <p>🔄 Orbital Period: {planet['pl_orbper']:.2f} days | 
                       ✨ Star Temperature: {planet['st_teff']:.0f} K</p>
                </div>
                """, unsafe_allow_html=True)
    else:
        st.warning("No planets match these habitability criteria. Try adjusting the parameters.")

# Add a footer
st.markdown("---")
st.markdown("#### About ExoVerse Explorer")
st.markdown("""
This app uses data from the NASA Exoplanet Archive, providing an interactive way to explore and
visualize thousands of planets discovered beyond our solar system. The habitability scores are
simplified approximations and not definitive scientific assessments.

Created with 💙 using Streamlit.
""") 