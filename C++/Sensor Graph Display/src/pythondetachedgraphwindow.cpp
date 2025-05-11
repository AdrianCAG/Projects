#include "pythondetachedgraphwindow.h"

PythonDetachedGraphWindow::PythonDetachedGraphWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setMinimumSize(800, 500);
    
    centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    
    mainLayout = new QVBoxLayout(centralWidget);
    
    // Title label
    titleLabel = new QLabel(this);
    titleLabel->setAlignment(Qt::AlignCenter);
    titleLabel->setStyleSheet("QLabel { font-weight: bold; font-size: 14px; }");
    mainLayout->addWidget(titleLabel);
    
    // Control layout for series selection and options
    controlLayout = new QHBoxLayout();
    mainLayout->addLayout(controlLayout);
    
    // Series selection group box
    seriesGroupBox = new QGroupBox("Data Series", this);
    seriesLayout = new QVBoxLayout(seriesGroupBox);
    
    // Add scroll area for series checkboxes
    QScrollArea *scrollArea = new QScrollArea();
    scrollArea->setWidgetResizable(true);
    QWidget *scrollContent = new QWidget();
    seriesLayout = new QVBoxLayout(scrollContent);
    scrollArea->setWidget(scrollContent);
    seriesGroupBox->setLayout(new QVBoxLayout());
    seriesGroupBox->layout()->addWidget(scrollArea);
    
    controlLayout->addWidget(seriesGroupBox);
    
    // Options group box
    QGroupBox *optionsGroupBox = new QGroupBox("Options", this);
    QVBoxLayout *optionsLayout = new QVBoxLayout(optionsGroupBox);
    
    // Interpolate option
    interpolateCheckbox = new QCheckBox("Interpolate", this);
    connect(interpolateCheckbox, &QCheckBox::toggled, this, &PythonDetachedGraphWindow::onInterpolateToggled);
    optionsLayout->addWidget(interpolateCheckbox);
    
    controlLayout->addWidget(optionsGroupBox);
    
    // Graph widget
    graphWidget = new PythonGraphWidget(this);
    graphWidget->setMinimumSize(750, 400);
    mainLayout->addWidget(graphWidget, 1);
    
    // Connect signals
    connect(graphWidget, &PythonGraphWidget::seriesVisibilityChanged, 
            this, &PythonDetachedGraphWindow::onSeriesVisibilityChanged);
    
    // Set window properties
    setWindowTitle("Detached Graph View (Python Charts)");
}

PythonDetachedGraphWindow::~PythonDetachedGraphWindow()
{
}

void PythonDetachedGraphWindow::setGraphData(const QVector<QPair<double, double>> &data)
{
    // Convert the data to a DataSeries format
    QMap<QString, SensorDataParser::DataSeries> seriesMap;
    
    if (!data.isEmpty()) {
        // Add the data as a single series
        SensorDataParser::DataSeries series;
        
        // Separate x and y values
        for (const auto &point : data) {
            series.x.append(point.first);
            series.y.append(point.second);
        }
        
        // Add to data series map with a default name
        seriesMap["Default Series"] = series;
        
        // Set the data series
        graphWidget->setDataSeries(seriesMap);
    }
    
    updateSeriesControls();
}

void PythonDetachedGraphWindow::setDataSeries(const QMap<QString, SensorDataParser::DataSeries> &series)
{
    graphWidget->setDataSeries(series);
    updateSeriesControls();
}

void PythonDetachedGraphWindow::setAxisLabels(const QString &xLabel, const QString &yLabel)
{
    graphWidget->setXAxisLabel(xLabel);
    graphWidget->setYAxisLabel(yLabel);
}

void PythonDetachedGraphWindow::setInterpolate(bool enabled)
{
    graphWidget->setInterpolate(enabled);
    interpolateCheckbox->setChecked(enabled);
}

void PythonDetachedGraphWindow::updateSeriesControls()
{
    // Clear existing checkboxes
    QLayoutItem *item;
    while ((item = seriesLayout->takeAt(0)) != nullptr) {
        if (item->widget()) {
            delete item->widget();
        }
        delete item;
    }
    seriesCheckboxes.clear();
    
    // Add checkboxes for each data series
    auto dataSeries = graphWidget->getDataSeries();
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        const QString &seriesName = it.key();
        const bool visible = it.value().visible;
        
        QCheckBox *checkbox = new QCheckBox(seriesName, this);
        checkbox->setChecked(visible);
        connect(checkbox, &QCheckBox::toggled, this, &PythonDetachedGraphWindow::onCheckboxToggled);
        
        seriesLayout->addWidget(checkbox);
        seriesCheckboxes[seriesName] = checkbox;
    }
    
    // Add a spacer at the end
    seriesLayout->addStretch();
}

void PythonDetachedGraphWindow::onSeriesVisibilityChanged(const QString &seriesName, bool visible)
{
    // Update the corresponding checkbox
    if (seriesCheckboxes.contains(seriesName)) {
        QCheckBox *checkbox = seriesCheckboxes[seriesName];
        checkbox->blockSignals(true);
        checkbox->setChecked(visible);
        checkbox->blockSignals(false);
    }
}

void PythonDetachedGraphWindow::onCheckboxToggled(bool checked)
{
    QCheckBox *checkbox = qobject_cast<QCheckBox*>(sender());
    if (checkbox) {
        QString seriesName = checkbox->text();
        graphWidget->toggleSeriesVisibility(seriesName, checked);
    }
}

void PythonDetachedGraphWindow::onInterpolateToggled(bool checked)
{
    graphWidget->setInterpolate(checked);
}

void PythonDetachedGraphWindow::setTitle(const QString &title)
{
    titleLabel->setText(title);
    setWindowTitle("Graph: " + title + " (Python Charts)");
}

void PythonDetachedGraphWindow::setGraphType(int type)
{
    graphWidget->setGraphType(type);
}

void PythonDetachedGraphWindow::setGraphColor(const QColor &color)
{
    graphWidget->setGraphColor(color);
}

void PythonDetachedGraphWindow::closeEvent(QCloseEvent *event)
{
    emit windowClosed();
    event->accept();
}
