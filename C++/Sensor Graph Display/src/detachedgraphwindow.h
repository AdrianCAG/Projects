#ifndef DETACHEDGRAPHWINDOW_H
#define DETACHEDGRAPHWINDOW_H

#include <QMainWindow>
#include <QVBoxLayout>
#include <QLabel>
#include <QCloseEvent>
#include <QCheckBox>
#include <QHBoxLayout>
#include <QGroupBox>
#include <QScrollArea>
#include "graphwidget.h"
#include "sensordataparser.h"

class DetachedGraphWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit DetachedGraphWindow(QWidget *parent = nullptr);
    ~DetachedGraphWindow();

    // Legacy support
    void setGraphData(const QVector<QPair<double, double>> &data);
    
    // New multi-series support
    void setDataSeries(const QMap<QString, SensorDataParser::DataSeries> &series);
    
    void setTitle(const QString &title);
    void setGraphType(int type);
    void setGraphColor(const QColor &color);
    void setAxisLabels(const QString &xLabel, const QString &yLabel);
    void setInterpolate(bool enabled);

signals:
    void windowClosed();

protected:
    void closeEvent(QCloseEvent *event) override;

private slots:
    void onSeriesVisibilityChanged(const QString &seriesName, bool visible);
    void onCheckboxToggled(bool checked);
    void onInterpolateToggled(bool checked);

private:
    void updateSeriesControls();
    
    QWidget *centralWidget;
    QVBoxLayout *mainLayout;
    QHBoxLayout *controlLayout;
    QLabel *titleLabel;
    GraphWidget *graphWidget;
    QGroupBox *seriesGroupBox;
    QVBoxLayout *seriesLayout;
    QMap<QString, QCheckBox*> seriesCheckboxes;
    QCheckBox *interpolateCheckbox;
};

#endif // DETACHEDGRAPHWINDOW_H
