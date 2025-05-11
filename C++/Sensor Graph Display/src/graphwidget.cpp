#include "graphwidget.h"
#include <QVBoxLayout>
#include <QFile>
#include <QTextStream>
#include <QMessageBox>
#include <QFileInfo>
#include <QRandomGenerator>
#include <QPainterPath>
#include <cmath>

GraphWidget::GraphWidget(QWidget *parent)
    : QWidget(parent), currentMode(0), selected(false), resizing(false), moving(false), animationIndex(0),
      graphType(0), graphColor(Qt::blue), pointSize(5), lineWidth(2), showGrid(true), showLabels(true),
      interpolate(false), xAxisLabel("Time"), yAxisLabel("Value")
{
    setMinimumSize(200, 150);
    setMouseTracking(true);
    
    QVBoxLayout *layout = new QVBoxLayout(this);
    
    // Title label
    titleLabel = new QLabel(this);
    titleLabel->setAlignment(Qt::AlignCenter);
    titleLabel->setStyleSheet("QLabel { font-weight: bold; }");
    layout->addWidget(titleLabel);
    
    // Animation timer
    animationTimer = new QTimer(this);
    connect(animationTimer, &QTimer::timeout, this, &GraphWidget::updateAnimation);
    
    // Set background color
    setAutoFillBackground(true);
    QPalette pal = palette();
    pal.setColor(QPalette::Window, Qt::white);
    setPalette(pal);
}

GraphWidget::~GraphWidget()
{
}

void GraphWidget::loadDataFromFile(const QString &filePath)
{
    // Clear previous data
    sensorData.clear();
    dataSeries.clear();
    seriesColors.clear();
    
    // Parse file with multiple data series
    QMap<QString, SensorDataParser::DataSeries> newSeries;
    if (SensorDataParser::parseFile(filePath, newSeries)) {
        // Set the data series
        setDataSeries(newSeries);
        
        // Set axis labels based on file name
        QFileInfo fileInfo(filePath);
        setXAxisLabel("Time");
        setYAxisLabel(fileInfo.baseName());
        
        // For backward compatibility, also set the first series to sensorData
        if (!newSeries.isEmpty()) {
            auto firstSeries = newSeries.begin().value();
            // Convert x and y vectors to the legacy sensorData format
            sensorData.clear();
            for (int i = 0; i < firstSeries.x.size() && i < firstSeries.y.size(); i++) {
                sensorData.append(qMakePair(firstSeries.x[i], firstSeries.y[i]));
            }
        }
        
        // Trigger a repaint to show the graph
        update();
    } else {
        QMessageBox::warning(nullptr, "Error", "No valid data found in file: " + filePath);
    }
}

void GraphWidget::setMode(int mode)
{
    currentMode = mode;
    setCursor(Qt::ArrowCursor);
    
    switch (currentMode) {
        case 1: // Shape
            setCursor(Qt::PointingHandCursor);
            break;
        case 2: // Move
            setCursor(Qt::SizeAllCursor);
            break;
        case 3: // Resize
            setCursor(Qt::SizeFDiagCursor);
            break;
        case 4: // Delete
            setCursor(Qt::CrossCursor);
            break;
    }
}

void GraphWidget::setTitle(const QString &title)
{
    titleLabel->setText(title);
}

bool GraphWidget::isSelected() const
{
    return selected;
}

// Methods for multiple data series support
void GraphWidget::setDataSeries(const QMap<QString, SensorDataParser::DataSeries> &series)
{
    dataSeries = series;
    
    // Assign colors to each series
    int colorIndex = 0;
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        if (!seriesColors.contains(it.key())) {
            seriesColors[it.key()] = defaultColors[colorIndex % defaultColors.size()];
            colorIndex++;
        }
    }
    
    update();
}

QMap<QString, SensorDataParser::DataSeries> GraphWidget::getDataSeries() const
{
    return dataSeries;
}

void GraphWidget::toggleSeriesVisibility(const QString &seriesName, bool visible)
{
    if (dataSeries.contains(seriesName)) {
        dataSeries[seriesName].visible = visible;
        emit seriesVisibilityChanged(seriesName, visible);
        update();
    }
}

void GraphWidget::onSeriesToggled(bool checked)
{
    QCheckBox *checkbox = qobject_cast<QCheckBox*>(sender());
    if (checkbox) {
        QString seriesName = checkbox->text();
        toggleSeriesVisibility(seriesName, checked);
    }
}

// Methods for axis labels
void GraphWidget::setXAxisLabel(const QString &label)
{
    xAxisLabel = label;
    update();
}

void GraphWidget::setYAxisLabel(const QString &label)
{
    yAxisLabel = label;
    update();
}

QString GraphWidget::getXAxisLabel() const
{
    return xAxisLabel;
}

QString GraphWidget::getYAxisLabel() const
{
    return yAxisLabel;
}

// Legacy support methods
QVector<QPair<double, double>> GraphWidget::getSensorData() const
{
    return sensorData;
}

void GraphWidget::setSensorData(const QVector<QPair<double, double>> &data)
{
    sensorData = data;
    
    // Also update the first data series if it exists
    if (!dataSeries.isEmpty()) {
        auto firstKey = dataSeries.keys().first();
        // Convert legacy data format to x and y vectors
        dataSeries[firstKey].x.clear();
        dataSeries[firstKey].y.clear();
        for (const auto &point : data) {
            dataSeries[firstKey].x.append(point.first);
            dataSeries[firstKey].y.append(point.second);
        }
    } else {
        // Create a default data series
        SensorDataParser::DataSeries series;
        series.name = "Variable 1";
        // Convert legacy data format to x and y vectors
        series.x.clear();
        series.y.clear();
        for (const auto &point : data) {
            series.x.append(point.first);
            series.y.append(point.second);
        }
        dataSeries[series.name] = series;
        seriesColors[series.name] = graphColor;
    }
    
    update();
}

void GraphWidget::setGraphType(int type)
{
    graphType = type;
    update();
}

void GraphWidget::setGraphColor(const QColor &color)
{
    graphColor = color;
    update();
}

int GraphWidget::getGraphType() const
{
    return graphType;
}

QColor GraphWidget::getGraphColor() const
{
    return graphColor;
}

QString GraphWidget::getTitle() const
{
    return titleLabel->text();
}

bool GraphWidget::getInterpolate() const
{
    return interpolate;
}

void GraphWidget::setInterpolate(bool enabled)
{
    interpolate = enabled;
    update();
}

QColor GraphWidget::getColorForSeries(const QString &seriesName)
{
    if (seriesColors.contains(seriesName)) {
        return seriesColors[seriesName];
    }
    
    // If no color assigned, use the default graph color
    return graphColor;
}

void GraphWidget::playAnimation()
{
    if (sensorData.isEmpty()) {
        return;
    }
    
    // Reset animation
    animationIndex = 0;
    
    // Start animation timer
    animationTimer->start(50);  // Update every 50ms
}

void GraphWidget::updateAnimation()
{
    if (animationIndex >= sensorData.size()) {
        animationTimer->stop();
        return;
    }
    
    // Increment animation index
    animationIndex++;
    
    // Trigger a repaint to show updated animation
    update();
    
    // If we've added all points, stop the animation
    if (animationIndex >= sensorData.size()) {
        animationTimer->stop();
    }
}

void GraphWidget::drawLegend(QPainter &painter, const QRect &graphArea)
{
    if (dataSeries.isEmpty()) return;
    
    // Set up legend area in top-right corner
    const int legendMargin = 10;
    const int legendItemHeight = 20;
    const int legendWidth = 120;
    
    int legendHeight = dataSeries.size() * legendItemHeight + 2 * legendMargin;
    QRect legendRect(graphArea.right() - legendWidth - 10, 
                     graphArea.top() + 10, 
                     legendWidth, 
                     legendHeight);
    
    // Draw legend background
    painter.fillRect(legendRect, QColor(255, 255, 255, 200));
    painter.setPen(QPen(Qt::gray, 1));
    painter.drawRect(legendRect);
    
    // Draw legend items
    int y = legendRect.top() + legendMargin;
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        const QString &seriesName = it.key();
        const bool visible = it.value().visible;
        const QColor color = getColorForSeries(seriesName);
        
        // Draw color box
        QRect colorBox(legendRect.left() + 10, y + 2, 16, 16);
        if (visible) {
            painter.fillRect(colorBox, color);
            painter.setPen(QPen(Qt::black, 1));
        } else {
            painter.setPen(QPen(Qt::gray, 1));
        }
        painter.drawRect(colorBox);
        
        // Draw series name
        painter.setPen(visible ? Qt::black : Qt::gray);
        painter.drawText(colorBox.right() + 5, y + 15, seriesName);
        
        y += legendItemHeight;
    }
}

void GraphWidget::drawMultiSeries(QPainter &painter, const QRect &graphArea)
{
    if (dataSeries.isEmpty()) return;
    
    // Calculate min/max values across all visible series
    double minX = std::numeric_limits<double>::max();
    double maxX = std::numeric_limits<double>::lowest();
    double minY = std::numeric_limits<double>::max();
    double maxY = std::numeric_limits<double>::lowest();
    
    // First pass: find min/max values
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        if (!it.value().visible) continue;
        
        const auto &xValues = it.value().x;
        const auto &yValues = it.value().y;
        int numPoints = qMin(xValues.size(), yValues.size());
        for (int i = 0; i < numPoints; i++) {
            minX = std::min(minX, xValues[i]);
            maxX = std::max(maxX, xValues[i]);
            minY = std::min(minY, yValues[i]);
            maxY = std::max(maxY, yValues[i]);
        }
    }
    
    // Add padding
    double xRange = maxX - minX;
    double yRange = maxY - minY;
    
    if (xRange <= 0) xRange = 1;
    if (yRange <= 0) yRange = 1;
    
    // Draw grid if enabled
    if (showGrid) {
        painter.setPen(QPen(QColor(220, 220, 220), 1, Qt::DotLine));
        
        // Vertical grid lines
        for (int i = 1; i < 10; i++) {
            int x = graphArea.left() + (i * graphArea.width() / 10);
            painter.drawLine(x, graphArea.top(), x, graphArea.bottom());
        }
        
        // Horizontal grid lines
        for (int i = 1; i < 10; i++) {
            int y = graphArea.top() + (i * graphArea.height() / 10);
            painter.drawLine(graphArea.left(), y, graphArea.right(), y);
        }
    }
    
    // Draw axes labels if enabled
    if (showLabels) {
        painter.setPen(Qt::black);
        
        // Y-axis labels
        painter.drawText(graphArea.left() - 40, graphArea.top() - 5, QString::number(maxY, 'f', 1));
        painter.drawText(graphArea.left() - 40, graphArea.bottom() + 15, QString::number(minY, 'f', 1));
        
        // X-axis labels
        painter.drawText(graphArea.left() - 15, graphArea.bottom() + 15, QString::number(minX, 'f', 1));
        painter.drawText(graphArea.right() - 25, graphArea.bottom() + 15, QString::number(maxX, 'f', 1));
        
        // Axis titles
        painter.save();
        painter.translate(graphArea.left() - 60, graphArea.top() + graphArea.height() / 2);
        painter.rotate(-90);
        painter.drawText(0, 0, yAxisLabel);
        painter.restore();
        
        painter.drawText(graphArea.left() + graphArea.width() / 2 - 20, graphArea.bottom() + 35, xAxisLabel);
    }
    
    // Draw each visible data series
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        const QString &seriesName = it.key();
        const auto &xValues = it.value().x;
        const auto &yValues = it.value().y;
        
        // Skip if series is not visible or has no data
        if (!it.value().visible || xValues.isEmpty() || yValues.isEmpty()) continue;
        
        // Set pen for this series
        QColor seriesColor = getColorForSeries(seriesName);
        painter.setPen(QPen(seriesColor, lineWidth));
        
        // Draw the graph based on type
        switch (graphType) {
            case 0: // Line graph
            {
                QPainterPath path;
                bool firstPoint = true;
                
                int numPoints = qMin(xValues.size(), yValues.size());
                for (int i = 0; i < numPoints; i++) {
                    // Scale the point to fit in the graph area
                    int x = graphArea.left() + ((xValues[i] - minX) / xRange) * graphArea.width();
                    int y = graphArea.bottom() - ((yValues[i] - minY) / yRange) * graphArea.height();
                    
                    if (firstPoint) {
                        path.moveTo(x, y);
                        firstPoint = false;
                    } else {
                        if (interpolate) {
                            path.lineTo(x, y);
                        } else {
                            path.lineTo(x, y);
                        }
                    }
                }
                
                painter.drawPath(path);
                break;
            }
            
            case 1: // Points graph
            {
                int numPoints = qMin(xValues.size(), yValues.size());
                for (int i = 0; i < numPoints; i++) {
                    // Scale the point to fit in the graph area
                    int x = graphArea.left() + ((xValues[i] - minX) / xRange) * graphArea.width();
                    int y = graphArea.bottom() - ((yValues[i] - minY) / yRange) * graphArea.height();
                    
                    painter.drawEllipse(QPoint(x, y), pointSize, pointSize);
                }
                break;
            }
            
            // Other graph types would be implemented here
            // For brevity, only line and points are shown in this example
            default:
                // Fall back to line graph for other types
                QPainterPath path;
                bool firstPoint = true;
                
                int numPoints = qMin(xValues.size(), yValues.size());
                for (int i = 0; i < numPoints; i++) {
                    int x = graphArea.left() + ((xValues[i] - minX) / xRange) * graphArea.width();
                    int y = graphArea.bottom() - ((yValues[i] - minY) / yRange) * graphArea.height();
                    
                    if (firstPoint) {
                        path.moveTo(x, y);
                        firstPoint = false;
                    } else {
                        path.lineTo(x, y);
                    }
                }
                
                painter.drawPath(path);
                break;
        }
    }
}

void GraphWidget::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        dragStartPosition = event->pos();
        originalSize = size();
        
        switch (currentMode) {
            case 1: // Shape
                // Change the graph type/shape
                graphType = (graphType + 1) % 6; // Cycle through line, points, bars, area, step, spline
                update(); // Redraw with new graph type
                break;
                
            case 2: // Move
                moving = true;
                break;
                
            case 3: // Resize
                resizing = true;
                break;
                
            case 4: // Delete
                // Hide this widget
                setVisible(false);
                break;
        }
        
        // Toggle selection
        selected = !selected;
        update();
    }
    
    QWidget::mousePressEvent(event);
}

void GraphWidget::mouseMoveEvent(QMouseEvent *event)
{
    if (moving && (event->buttons() & Qt::LeftButton)) {
        QPoint delta = event->pos() - dragStartPosition;
        move(pos() + delta);
    } else if (resizing && (event->buttons() & Qt::LeftButton)) {
        QPoint delta = event->pos() - dragStartPosition;
        resize(originalSize.width() + delta.x(), originalSize.height() + delta.y());
    }
    
    QWidget::mouseMoveEvent(event);
}

void GraphWidget::mouseReleaseEvent(QMouseEvent *event)
{
    moving = false;
    resizing = false;
    
    QWidget::mouseReleaseEvent(event);
}

void GraphWidget::contextMenuEvent(QContextMenuEvent *event)
{
    // Only show context menu if we have data to display
    if (sensorData.isEmpty()) {
        return;
    }
    
    QMenu contextMenu(tr("Graph Menu"), this);
    
    // Add action to open in detached window
    QAction *openAction = contextMenu.addAction(tr("Open in Detached Window"));
    
    // Add actions to change graph type
    QMenu *typeMenu = contextMenu.addMenu(tr("Change Graph Type"));
    QAction *lineAction = typeMenu->addAction(tr("Line"));
    QAction *pointsAction = typeMenu->addAction(tr("Points"));
    QAction *barsAction = typeMenu->addAction(tr("Bars"));
    QAction *areaAction = typeMenu->addAction(tr("Area"));
    QAction *stepAction = typeMenu->addAction(tr("Step"));
    QAction *splineAction = typeMenu->addAction(tr("Spline"));
    
    // Add actions to change color
    QMenu *colorMenu = contextMenu.addMenu(tr("Change Color"));
    QAction *blueAction = colorMenu->addAction(tr("Blue"));
    QAction *redAction = colorMenu->addAction(tr("Red"));
    QAction *greenAction = colorMenu->addAction(tr("Green"));
    QAction *purpleAction = colorMenu->addAction(tr("Purple"));
    QAction *orangeAction = colorMenu->addAction(tr("Orange"));
    
    // Show the context menu
    QAction *selectedAction = contextMenu.exec(event->globalPos());
    
    // Handle the selected action
    if (selectedAction == openAction) {
        emit openInDetachedWindow(this);
    } else if (selectedAction == lineAction) {
        setGraphType(0);
    } else if (selectedAction == pointsAction) {
        setGraphType(1);
    } else if (selectedAction == barsAction) {
        setGraphType(2);
    } else if (selectedAction == areaAction) {
        setGraphType(3);
    } else if (selectedAction == stepAction) {
        setGraphType(4);
    } else if (selectedAction == splineAction) {
        setGraphType(5);
    } else if (selectedAction == blueAction) {
        setGraphColor(Qt::blue);
    } else if (selectedAction == redAction) {
        setGraphColor(Qt::red);
    } else if (selectedAction == greenAction) {
        setGraphColor(Qt::green);
    } else if (selectedAction == purpleAction) {
        setGraphColor(Qt::magenta);
    } else if (selectedAction == orangeAction) {
        setGraphColor(QColor(255, 165, 0));
    }
}

void GraphWidget::paintEvent(QPaintEvent *event)
{
    QWidget::paintEvent(event);
    
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    
    // Draw graph area
    QRect graphArea = rect().adjusted(20, 30, -20, -20);
    painter.fillRect(graphArea, QColor(245, 245, 245));
    painter.setPen(QPen(Qt::gray, 1));
    painter.drawRect(graphArea);
    
    // If we have multi-series data, use that for drawing
    if (!dataSeries.isEmpty()) {
        drawMultiSeries(painter, graphArea);
        drawLegend(painter, graphArea);
    }
    // Otherwise fall back to legacy single series data
    else if (!sensorData.isEmpty()) {
        // Calculate min/max values for scaling
        double minX = std::numeric_limits<double>::max();
        double maxX = std::numeric_limits<double>::lowest();
        double minY = std::numeric_limits<double>::max();
        double maxY = std::numeric_limits<double>::lowest();
        
        for (const auto &point : sensorData) {
            minX = std::min(minX, point.first);
            maxX = std::max(maxX, point.first);
            minY = std::min(minY, point.second);
            maxY = std::max(maxY, point.second);
        }
        
        // Add padding
        double xRange = maxX - minX;
        double yRange = maxY - minY;
        
        if (xRange <= 0) xRange = 1;
        if (yRange <= 0) yRange = 1;
        
        // Draw grid if enabled
        if (showGrid) {
            painter.setPen(QPen(QColor(220, 220, 220), 1, Qt::DotLine));
            
            // Vertical grid lines
            for (int i = 1; i < 10; i++) {
                int x = graphArea.left() + (i * graphArea.width() / 10);
                painter.drawLine(x, graphArea.top(), x, graphArea.bottom());
            }
            
            // Horizontal grid lines
            for (int i = 1; i < 10; i++) {
                int y = graphArea.top() + (i * graphArea.height() / 10);
                painter.drawLine(graphArea.left(), y, graphArea.right(), y);
            }
        }
        
        // Draw axes labels if enabled
        if (showLabels) {
            painter.setPen(Qt::black);
            painter.drawText(graphArea.left() - 40, graphArea.top() - 5, QString::number(maxY, 'f', 1));
            painter.drawText(graphArea.left() - 40, graphArea.bottom() + 15, QString::number(minY, 'f', 1));
            painter.drawText(graphArea.left() - 15, graphArea.bottom() + 15, QString::number(minX, 'f', 1));
            painter.drawText(graphArea.right() - 25, graphArea.bottom() + 15, QString::number(maxX, 'f', 1));
            
            // Draw axis titles
            painter.save();
            painter.translate(graphArea.left() - 60, graphArea.top() + graphArea.height() / 2);
            painter.rotate(-90);
            painter.drawText(0, 0, yAxisLabel);
            painter.restore();
            
            painter.drawText(graphArea.left() + graphArea.width() / 2 - 20, graphArea.bottom() + 35, xAxisLabel);
            
            // Draw graph type label
            QString typeLabel;
            switch (graphType) {
                case 0: typeLabel = "Line"; break;
                case 1: typeLabel = "Points"; break;
                case 2: typeLabel = "Bars"; break;
                case 3: typeLabel = "Area"; break;
                case 4: typeLabel = "Step"; break;
                case 5: typeLabel = "Spline"; break;
            }
            painter.drawText(graphArea.right() - 60, graphArea.top() - 5, typeLabel);
        }
        
        // Set pen for data points
        painter.setPen(QPen(graphColor, lineWidth));
        
        // Draw the graph based on type
        switch (graphType) {
            case 0: // Line graph
            {
                QPainterPath path;
                bool firstPoint = true;
                
                for (const auto &point : sensorData) {
                    // Scale the point to fit in the graph area
                    int x = graphArea.left() + ((point.first - minX) / xRange) * graphArea.width();
                    int y = graphArea.bottom() - ((point.second - minY) / yRange) * graphArea.height();
                    
                    if (firstPoint) {
                        path.moveTo(x, y);
                        firstPoint = false;
                    } else {
                        path.lineTo(x, y);
                    }
                }
                
                painter.drawPath(path);
                break;
            }
            
            case 1: // Points graph
            {
                for (const auto &point : sensorData) {
                    // Scale the point to fit in the graph area
                    int x = graphArea.left() + ((point.first - minX) / xRange) * graphArea.width();
                    int y = graphArea.bottom() - ((point.second - minY) / yRange) * graphArea.height();
                    
                    painter.drawEllipse(QPoint(x, y), pointSize, pointSize);
                }
                break;
            }
            
            // Other graph types would be handled similarly
            // For brevity, only showing line and points in the legacy mode
            default:
                // Fall back to line graph
                QPainterPath path;
                bool firstPoint = true;
                
                for (const auto &point : sensorData) {
                    int x = graphArea.left() + ((point.first - minX) / xRange) * graphArea.width();
                    int y = graphArea.bottom() - ((point.second - minY) / yRange) * graphArea.height();
                    
                    if (firstPoint) {
                        path.moveTo(x, y);
                        firstPoint = false;
                    } else {
                        path.lineTo(x, y);
                    }
                }
                
                painter.drawPath(path);
                break;
        }
    }
    
    // Draw selection border if selected
    if (selected) {
        painter.setPen(QPen(Qt::blue, 2, Qt::DashLine));
        painter.drawRect(rect().adjusted(2, 2, -2, -2));
    }
}
