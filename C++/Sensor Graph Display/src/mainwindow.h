#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QScrollArea>
#include <QVector>
#include <QLabel>
#include <QMap>
#include <QCheckBox>
#include <QGroupBox>
#include <QLineEdit>
#include "droparea.h"
#include "graphwidget.h"
#include "detachedgraphwindow.h"
#include "pythongraphwidget.h"
#include "pythondetachedgraphwindow.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onShapeButtonClicked();
    void onMoveButtonClicked();
    void onResizeButtonClicked();
    void onDeleteButtonClicked();
    void onAddDropAreaButtonClicked();
    void onFileDropped(const QString &filePath, DropArea *dropArea);
    void onOpenInDetachedWindow(GraphWidget *widget);
    void onOpenInPythonDetachedWindow(PythonGraphWidget *widget);
    void onDetachedWindowClosed();
    void onInterpolateToggled(bool checked);
    void onXAxisLabelChanged();
    void onYAxisLabelChanged();
    void onUsePythonChartsToggled(bool checked);

private:
    void setupUI();
    void createButtons();
    void createControls();
    void createDropAreas();
    
    QWidget *centralWidget;
    QHBoxLayout *mainLayout;
    QVBoxLayout *buttonLayout;
    QVBoxLayout *dropAreasLayout;
    QScrollArea *scrollArea;
    QWidget *scrollContent;
    
    QPushButton *shapeButton;
    QPushButton *moveButton;
    QPushButton *resizeButton;
    QPushButton *deleteButton;
    QPushButton *addDropAreaButton;
    
    // Additional controls
    QGroupBox *controlsGroupBox;
    QCheckBox *interpolateCheckbox;
    QCheckBox *usePythonChartsCheckbox;
    QLineEdit *xAxisLabelEdit;
    QLineEdit *yAxisLabelEdit;
    QLabel *xAxisLabel;
    QLabel *yAxisLabel;
    
    QVector<DropArea*> dropAreas;
    QVector<GraphWidget*> graphWidgets;
    QVector<PythonGraphWidget*> pythonGraphWidgets;
    QMap<GraphWidget*, DetachedGraphWindow*> detachedWindows;
    QMap<PythonGraphWidget*, PythonDetachedGraphWindow*> pythonDetachedWindows;
    
    // Flag to use Python charts
    bool usePythonCharts;
    
    int currentMode; // 0: None, 1: Shape, 2: Move, 3: Resize, 4: Delete
};

#endif // MAINWINDOW_H
