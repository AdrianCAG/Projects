#ifndef GRAPHWIDGET_H
#define GRAPHWIDGET_H

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
#include "sensordataparser.h"

class GraphWidget : public QWidget
{
    Q_OBJECT

public:
    explicit GraphWidget(QWidget *parent = nullptr);
    ~GraphWidget();

    void loadDataFromFile(const QString &filePath);
    void setMode(int mode);
    void setTitle(const QString &title);
    bool isSelected() const;
    void playAnimation();
    
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
    QVector<QPair<double, double>> getSensorData() const; // Legacy support
    void setSensorData(const QVector<QPair<double, double>> &data); // Legacy support
    void setGraphType(int type);
    void setGraphColor(const QColor &color);
    int getGraphType() const;
    QColor getGraphColor() const;
    QString getTitle() const;
    bool getInterpolate() const;
    void setInterpolate(bool enabled);

signals:
    void openInDetachedWindow(GraphWidget *widget);
    void seriesVisibilityChanged(const QString &seriesName, bool visible);

protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void paintEvent(QPaintEvent *event) override;
    void contextMenuEvent(QContextMenuEvent *event) override;

private slots:
    void updateAnimation();
    void onSeriesToggled(bool checked);

private:
    QLabel *titleLabel;
    
    int currentMode; // 0: None, 1: Shape, 2: Move, 3: Resize, 4: Delete
    bool selected;
    QPoint dragStartPosition;
    QSize originalSize;
    bool resizing;
    bool moving;

    // Legacy support
    QVector<QPair<double, double>> sensorData;
    
    // Multiple data series support
    QMap<QString, SensorDataParser::DataSeries> dataSeries;
    QMap<QString, QColor> seriesColors;
    QList<QColor> defaultColors = {Qt::blue, Qt::red, Qt::green, Qt::magenta, Qt::cyan, Qt::yellow, Qt::darkBlue, Qt::darkRed};
    
    QTimer *animationTimer;
    int animationIndex;
    
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
    
    // Helper methods
    void drawMultiSeries(QPainter &painter, const QRect &graphArea);
    void drawLegend(QPainter &painter, const QRect &graphArea);
    QColor getColorForSeries(const QString &seriesName);
};

#endif // GRAPHWIDGET_H
