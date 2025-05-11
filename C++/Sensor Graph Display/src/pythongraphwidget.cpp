#include "pythongraphwidget.h"
#include <QVBoxLayout>
#include <QPainter>
#include <QMouseEvent>
#include <QMenu>
#include <QAction>
#include <QLabel>
#include <QMessageBox>
#include <QFileDialog>
#include <QContextMenuEvent>
#include <QColorDialog>
#include <QtConcurrent/QtConcurrent>
#include <QDebug>

// Initialize static variables
int PythonGraphWidget::s_totalRequestCount = 0;
QElapsedTimer PythonGraphWidget::s_globalRequestTimer;

PythonGraphWidget::PythonGraphWidget(QWidget *parent)
    : QWidget(parent),
      currentMode(0),
      selected(false),
      resizing(false),
      moving(false),
      chartBridge(),
      graphType(0),
      graphColor(Qt::blue),
      pointSize(5),
      lineWidth(2),
      showGrid(true),
      showLabels(true),
      interpolate(false),
      xAxisLabel("Time"),
      yAxisLabel("Value"),
      chartGenerationInProgress(false),
      pendingChartRequest(false),
      chartRequestCount(0),
      debounceTimer(nullptr),
      pendingDebounceRequest(false)
{
    // Initialize UI elements
    QVBoxLayout *layout = new QVBoxLayout(this);
    
    // Create title label
    titleLabel = new QLabel("Sensor Data Graph");
    titleLabel->setAlignment(Qt::AlignCenter);
    QFont titleFont = titleLabel->font();
    titleFont.setPointSize(14);
    titleFont.setBold(true);
    titleLabel->setFont(titleFont);
    
    // Create chart label
    chartLabel = new QLabel(this);
    chartLabel->setAlignment(Qt::AlignCenter);
    chartLabel->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
    
    // Create status label
    statusLabel = new QLabel(this);
    statusLabel->setAlignment(Qt::AlignCenter);
    statusLabel->setText("Loading...");
    statusLabel->setVisible(false);
    
    // Add widgets to layout
    layout->addWidget(titleLabel);
    layout->addWidget(chartLabel);
    layout->addWidget(statusLabel);
    
    // Set up layout
    setLayout(layout);
    

    
    // Set up debounce timer for chart generation
    debounceTimer = new QTimer(this);
    debounceTimer->setSingleShot(true);
    
    // Set up async chart generation
    chartFutureWatcher = new QFutureWatcher<QString>(this);
    connect(chartFutureWatcher, &QFutureWatcher<QString>::finished, this, &PythonGraphWidget::onChartImageGenerated);
    
    // Set default widget size
    setMinimumSize(400, 300);
    setMaximumSize(1920, 1080);
    
    // Initialize the global timer if not started
    if (!s_globalRequestTimer.isValid()) {
        s_globalRequestTimer.start();
    }
}

PythonGraphWidget::~PythonGraphWidget()
{
    // Clean up
}

void PythonGraphWidget::loadDataFromFile(const QString &filePath)
{
    // Create a data container for the loaded data
    QMap<QString, SensorDataParser::DataSeries> loadedData;
    
    // Parse the file using the static method
    bool success = SensorDataParser::parseFile(filePath, loadedData);
    
    if (!success || loadedData.isEmpty()) {
        QMessageBox::warning(this, "Error", "Failed to load data from file or file is empty.");
        return;
    }
    
    // Set the data to the widget
    setDataSeries(loadedData);
    
    // Update the title to show the file name
    QFileInfo fileInfo(filePath);
    setTitle(fileInfo.fileName());
    
    // Generate the chart
    triggerChartGeneration();
}

void PythonGraphWidget::setMode(int mode)
{
    if (mode >= 0 && mode <= 4) {
        currentMode = mode;
        
        // Clear selection when changing modes
        if (mode != 2 && mode != 3) {
            selected = false;
            resizing = false;
            moving = false;
            setCursor(Qt::ArrowCursor);
        }
        
        // Update the cursor based on the mode
        if (mode == 1) {
            setCursor(Qt::CrossCursor);
        } else if (mode == 2) {
            setCursor(Qt::SizeAllCursor);
        } else if (mode == 3) {
            setCursor(Qt::SizeFDiagCursor);
        } else if (mode == 4) {
            setCursor(Qt::ForbiddenCursor);
        }
    }
}

void PythonGraphWidget::setTitle(const QString &title)
{
    titleLabel->setText(title);
    triggerChartGeneration();
}

bool PythonGraphWidget::isSelected() const
{
    return selected;
}

void PythonGraphWidget::setDataSeries(const QMap<QString, SensorDataParser::DataSeries> &series)
{
    dataSeries = series;
    
    // Assign colors to series if not already assigned and initialize visibility
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        if (!seriesColors.contains(it.key())) {
            seriesColors[it.key()] = getColorForSeries(it.key());
        }
        
        // Initialize visibility to true if not already set
        if (!seriesVisibility.contains(it.key())) {
            seriesVisibility[it.key()] = true;
        }
    }
    
    triggerChartGeneration();
}

QMap<QString, SensorDataParser::DataSeries> PythonGraphWidget::getDataSeries() const
{
    return dataSeries;
}

void PythonGraphWidget::toggleSeriesVisibility(const QString &seriesName, bool visible)
{
    if (dataSeries.contains(seriesName)) {
        // Store the visibility state for this series
        seriesVisibility[seriesName] = visible;
        
        // Emit signal for any listeners
        emit seriesVisibilityChanged(seriesName, visible);
        
        // Regenerate the chart with updated visibility
        triggerChartGeneration();
    }
}

void PythonGraphWidget::onSeriesToggled(bool checked)
{
    QAction *action = qobject_cast<QAction*>(sender());
    if (action) {
        QString seriesName = action->text();
        toggleSeriesVisibility(seriesName, checked);
    }
}

void PythonGraphWidget::setXAxisLabel(const QString &label)
{
    xAxisLabel = label;
    triggerChartGeneration();
}

void PythonGraphWidget::setYAxisLabel(const QString &label)
{
    yAxisLabel = label;
    triggerChartGeneration();
}

QString PythonGraphWidget::getXAxisLabel() const
{
    return xAxisLabel;
}

QString PythonGraphWidget::getYAxisLabel() const
{
    return yAxisLabel;
}

void PythonGraphWidget::setGraphType(int type)
{
    graphType = type;
    triggerChartGeneration();
}

void PythonGraphWidget::setGraphColor(const QColor &color)
{
    graphColor = color;
    triggerChartGeneration();
}

int PythonGraphWidget::getGraphType() const
{
    return graphType;
}

QColor PythonGraphWidget::getGraphColor() const
{
    return graphColor;
}

QString PythonGraphWidget::getTitle() const
{
    return titleLabel->text();
}

bool PythonGraphWidget::getInterpolate() const
{
    return interpolate;
}

void PythonGraphWidget::setInterpolate(bool enabled)
{
    interpolate = enabled;
    triggerChartGeneration();
}

QColor PythonGraphWidget::getColorForSeries(const QString &seriesName)
{
    // Get a deterministic color based on the series name
    int index = qHash(seriesName) % defaultColors.size();
    return defaultColors[index];
}

void PythonGraphWidget::updateChart()
{
    triggerChartGeneration();
}

bool PythonGraphWidget::isPythonAvailable()
{
    return PythonChartBridge::isPythonAvailable();
}

void PythonGraphWidget::generateChartImage()
{
    if (dataSeries.isEmpty()) {
        return;
    }
    
    // Aggressively debounce chart generation requests
    pendingDebounceRequest = true;
    
    // Reset and restart the debounce timer to ensure we only
    // generate one chart after rapid consecutive requests
    if (debounceTimer->isActive()) {
        debounceTimer->stop();
    }
    
    // Use a longer debounce period (500ms) to ensure we don't overwhelm the system
    debounceTimer->setInterval(500);
    debounceTimer->start();
}

void PythonGraphWidget::triggerChartGeneration()
{
    // Only allow one chart generation at a time
    if (chartGenerationInProgress) {
        // If a chart is already being generated, set a flag to generate another one when it's done
        pendingChartRequest = true;
        qDebug() << "Chart generation already in progress, queueing request";
        return;
    }
    
    // Increment request counters - both instance-specific and global
    chartRequestCount++;
    s_totalRequestCount++;
    
    // Reset the global timer on the first request
    if (s_totalRequestCount == 1) {
        s_globalRequestTimer.restart();
    }
    
    // Reset global counter if we've been running for more than 10 minutes
    // to prevent overflow and give system a fresh start periodically
    if (s_globalRequestTimer.elapsed() > 600000) { // 10 minutes in ms
        s_totalRequestCount = 1;
        s_globalRequestTimer.restart();
    }
    
    // Show status indicator
    chartGenerationInProgress = true;
    pendingChartRequest = false;
    statusLabel->setText("Generating chart...");
    statusLabel->setVisible(true);
    chartGenerationTimer.start();
    
    qDebug() << "Starting chart generation for request #" << chartRequestCount << "(Global #" << s_totalRequestCount << ")";
    
    // Filter data series to only include visible ones
    QMap<QString, SensorDataParser::DataSeries> visibleSeries;
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        QString seriesName = it.key();
        // Include series only if visibility is not explicitly set to false
        if (!seriesVisibility.contains(seriesName) || seriesVisibility[seriesName]) {
            visibleSeries[seriesName] = it.value();
        }
    }
    
    // Generate chart asynchronously
    QFuture<QString> future = QtConcurrent::run(
        [this, visibleSeries]() {
            return chartBridge.generateChart(
                visibleSeries,
                titleLabel->text(),
                xAxisLabel,
                yAxisLabel,
                graphType,
                interpolate,
                width(),
                height()
            );
        }
    );
    
    // Set the future watcher to monitor the async operation
    chartFutureWatcher->setFuture(future);
}

void PythonGraphWidget::onChartImageGenerated()
{
    // Get the result from the future
    chartImagePath = chartFutureWatcher->result();
    
    // Calculate and display generation time
    int elapsedMs = chartGenerationTimer.elapsed();
    qDebug() << "Chart generation completed in" << elapsedMs << "ms for request #" << chartRequestCount << "(Global #" << s_totalRequestCount << ")";
    
    // Reset chart generation flag immediately to prevent race conditions
    chartGenerationInProgress = false;
    
    // Check if the chart generation was successful
    bool chartSuccess = true;
    if (chartImagePath.isEmpty()) {
        qWarning() << "Failed to generate chart image";
        chartSuccess = false;
    } else {
        // Load the chart image
        chartPixmap.load(chartImagePath);
        if (chartPixmap.isNull()) {
            qWarning() << "Failed to load chart image from" << chartImagePath;
            chartSuccess = false;
        } else {
            // Scale the pixmap to fit the label
            chartPixmap = chartPixmap.scaled(chartLabel->size(), Qt::KeepAspectRatio, Qt::SmoothTransformation);
            
            // Set the pixmap to the label
            chartLabel->setPixmap(chartPixmap);
        }
    }
    
    // Hide status indicator
    statusLabel->setVisible(false);
    
    // Process any pending chart requests
    if (pendingChartRequest) {
        pendingChartRequest = false;
        
        // Wait a short delay before generating the next chart
        // to avoid overwhelming the system with rapid consecutive requests
        QTimer::singleShot(100, this, &PythonGraphWidget::triggerChartGeneration);
    }
}

void PythonGraphWidget::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        // Store the initial position for dragging
        dragStartPosition = event->pos();
        
        // Handle based on current mode
        if (currentMode == 1) {
            // Shape mode: Create a new shape
            // This would be implemented based on your application's needs
        } else if (currentMode == 2 && selected) {
            // Move mode: Start moving the widget
            moving = true;
            setCursor(Qt::ClosedHandCursor);
        } else if (currentMode == 3 && selected) {
            // Resize mode: Start resizing the widget
            resizing = true;
            originalSize = size();
            setCursor(Qt::SizeFDiagCursor);
        } else {
            // Select the widget
            selected = true;
            update(); // Repaint to show selection
        }
    }
    
    QWidget::mousePressEvent(event);
}

void PythonGraphWidget::mouseMoveEvent(QMouseEvent *event)
{
    if ((event->buttons() & Qt::LeftButton) && moving) {
        // Move the widget
        QPoint delta = event->pos() - dragStartPosition;
        move(pos() + delta);
    } else if ((event->buttons() & Qt::LeftButton) && resizing) {
        // Resize the widget
        QPoint delta = event->pos() - dragStartPosition;
        resize(originalSize.width() + delta.x(), originalSize.height() + delta.y());
    }
    
    QWidget::mouseMoveEvent(event);
}

void PythonGraphWidget::mouseReleaseEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        moving = false;
        resizing = false;
        
        if (currentMode == 2) {
            setCursor(Qt::SizeAllCursor);
        } else if (currentMode == 3) {
            setCursor(Qt::SizeFDiagCursor);
        }
    }
    
    QWidget::mouseReleaseEvent(event);
}

void PythonGraphWidget::contextMenuEvent(QContextMenuEvent *event)
{
    QMenu menu(this);
    
    // Graph type submenu
    QMenu* graphTypeMenu = menu.addMenu("Graph Type");
    
    QAction* lineAction = graphTypeMenu->addAction("Line");
    lineAction->setCheckable(true);
    lineAction->setChecked(graphType == 0);
    connect(lineAction, &QAction::triggered, [this]() {
        setGraphType(0);
    });
    
    QAction* pointsAction = graphTypeMenu->addAction("Points");
    pointsAction->setCheckable(true);
    pointsAction->setChecked(graphType == 1);
    connect(pointsAction, &QAction::triggered, [this]() {
        setGraphType(1);
    });
    
    QAction* barsAction = graphTypeMenu->addAction("Bars");
    barsAction->setCheckable(true);
    barsAction->setChecked(graphType == 2);
    connect(barsAction, &QAction::triggered, [this]() {
        setGraphType(2);
    });
    
    QAction* areaAction = graphTypeMenu->addAction("Area");
    areaAction->setCheckable(true);
    areaAction->setChecked(graphType == 3);
    connect(areaAction, &QAction::triggered, [this]() {
        setGraphType(3);
    });
    
    QAction* stepAction = graphTypeMenu->addAction("Step");
    stepAction->setCheckable(true);
    stepAction->setChecked(graphType == 4);
    connect(stepAction, &QAction::triggered, [this]() {
        setGraphType(4);
    });
    
    // Color picker action
    QAction* colorAction = menu.addAction("Set Color...");
    connect(colorAction, &QAction::triggered, [this]() {
        QColor color = QColorDialog::getColor(graphColor, this, "Select Graph Color");
        if (color.isValid()) {
            setGraphColor(color);
        }
    });
    
    // Series visibility submenu
    if (dataSeries.size() > 1) {
        QMenu* seriesMenu = menu.addMenu("Series");
        
        for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
            QAction* seriesAction = seriesMenu->addAction(it.key());
            seriesAction->setCheckable(true);
            seriesAction->setChecked(true); // Default to visible
            connect(seriesAction, &QAction::toggled, this, &PythonGraphWidget::onSeriesToggled);
        }
    }
    
    // Interpolation toggle
    QAction* interpolateAction = menu.addAction("Interpolate");
    interpolateAction->setCheckable(true);
    interpolateAction->setChecked(interpolate);
    connect(interpolateAction, &QAction::triggered, [this](bool checked) {
        setInterpolate(checked);
    });
    
    // Open in detached window
    QAction *detachAction = menu.addAction("Open in Detached Window");
    connect(detachAction, &QAction::triggered, [this]() {
        emit openInDetachedWindow(this);
    });
    
    menu.exec(event->globalPos());
}

void PythonGraphWidget::paintEvent(QPaintEvent *event)
{
    QWidget::paintEvent(event);
    
    QPainter painter(this);
    
    // Draw selection border if selected
    if (selected) {
        painter.setPen(QPen(Qt::blue, 2, Qt::DashLine));
        painter.drawRect(rect().adjusted(2, 2, -2, -2));
    }
}

void PythonGraphWidget::resizeEvent(QResizeEvent *event)
{
    QWidget::resizeEvent(event);
    
    // Regenerate the chart when the widget is resized
    // Use the throttled method instead of direct generation
    if (!dataSeries.isEmpty()) {
        triggerChartGeneration();
    }
}
