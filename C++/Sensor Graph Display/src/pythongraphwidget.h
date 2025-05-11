#ifndef PYTHONGRAPHWIDGET_H
#define PYTHONGRAPHWIDGET_H

#include <QWidget>
#include <QTimer>
#include <QLabel>
#include <QVector>
#include <QPair>
#include <QPainter>
#include <QPaintEvent>
#include <QMouseEvent>
#include <QMenu>
#include <QContextMenuEvent>
#include <QMap>
#include <QCheckBox>
#include <QPixmap>
#include <QFutureWatcher>
#include <QElapsedTimer>
#include <QtConcurrent/QtConcurrent>
#include "sensordataparser.h"
#include "pythonchartbridge.h"

class PythonGraphWidget : public QWidget
{
    Q_OBJECT
    
    // Friend class declarations for testing
    friend class TestPythonGraphWidget;
    friend class TestChartGenerationEvents;
    friend class ChartGenerationCounter;
    friend class TestResizeTriggers;

public:
    explicit PythonGraphWidget(QWidget *parent = nullptr);
    ~PythonGraphWidget();

    void loadDataFromFile(const QString &filePath);
    void setMode(int mode);
    void setTitle(const QString &title);
    bool isSelected() const;

    
    // Methods for multiple data series support
    void setDataSeries(const QMap<QString, SensorDataParser::DataSeries> &series);
    QMap<QString, SensorDataParser::DataSeries> getDataSeries() const;
    void toggleSeriesVisibility(const QString &seriesName, bool visible);
    
    // Methods for axis labels
    void setXAxisLabel(const QString &label);
    void setYAxisLabel(const QString &label);
    QString getXAxisLabel() const;
    QString getYAxisLabel() const;
    
    // Methods for detached window support
    void setGraphType(int type);
    void setGraphColor(const QColor &color);
    int getGraphType() const;
    QColor getGraphColor() const;
    QString getTitle() const;
    bool getInterpolate() const;
    void setInterpolate(bool enabled);
    
    // Check if Python is available
    static bool isPythonAvailable();
    
    // Diagnostic methods for testing
    static int getTotalRequestCount() { return s_totalRequestCount; }
    void resetRequestCounts() { chartRequestCount = 0; s_totalRequestCount = 0; s_globalRequestTimer.restart(); }

signals:
    void openInDetachedWindow(PythonGraphWidget *widget);
    void seriesVisibilityChanged(const QString &seriesName, bool visible);
    
    // Diagnostic signals for testing
    void chartGenerationRequested(int localRequestCount, int globalRequestCount);
    void chartGenerationStarted(int localRequestCount, int globalRequestCount);
    void chartGenerationCompleted(int localRequestCount, int globalRequestCount, int durationMs);

protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void paintEvent(QPaintEvent *event) override;
    void contextMenuEvent(QContextMenuEvent *event) override;
    void resizeEvent(QResizeEvent *event) override;

private slots:
    void updateChart();
    void onSeriesToggled(bool checked);

private slots:
    void onChartImageGenerated();
    
private:
    QLabel *titleLabel;
    QLabel *chartLabel;
    QLabel *statusLabel; // To show loading status
    
    int currentMode; // 0: None, 1: Shape, 2: Move, 3: Resize, 4: Delete
    bool selected;
    QPoint dragStartPosition;
    QSize originalSize;
    bool resizing;
    bool moving;


    
    // Multiple data series support
    QMap<QString, SensorDataParser::DataSeries> dataSeries;
    QMap<QString, QColor> seriesColors;
    QMap<QString, bool> seriesVisibility;
    QList<QColor> defaultColors = {Qt::blue, Qt::red, Qt::green, Qt::magenta, Qt::cyan, Qt::yellow, Qt::darkBlue, Qt::darkRed};
    

    
    // Graph drawing properties
    int graphType; // 0: Line, 1: Points, 2: Bars, 3: Area, 4: Step, 5: Spline
    QColor graphColor;
    int pointSize;
    int lineWidth;
    bool showGrid;
    bool showLabels;
    bool interpolate;
    
    // Axis labels
    QString xAxisLabel;
    QString yAxisLabel;
    
    // Python chart bridge
    PythonChartBridge chartBridge;
    QString chartImagePath;
    QPixmap chartPixmap;
    
    // Async chart generation
    QFutureWatcher<QString> *chartFutureWatcher = nullptr;
    QElapsedTimer chartGenerationTimer;
    bool chartGenerationInProgress = false;
    bool pendingChartRequest = false;
    int chartRequestCount = 0;  // Instance-specific counter
    QTimer *debounceTimer = nullptr;
    bool pendingDebounceRequest = false;
    
    // Global static request counter and timer to detect application-wide infinite loops
    static int s_totalRequestCount;
    static QElapsedTimer s_globalRequestTimer;
    
    // Helper methods
    QColor getColorForSeries(const QString &seriesName);
    void generateChartImage(); // Request a chart update (debounced)
    void triggerChartGeneration(); // Actually generate the chart
};

#endif // PYTHONGRAPHWIDGET_H
