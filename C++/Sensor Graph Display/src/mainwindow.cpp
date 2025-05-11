#include "mainwindow.h"
#include <QFileInfo>
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), currentMode(0), usePythonCharts(false)
{
    // Check if Python is available but don't auto-select it
    bool pythonAvailable = PythonGraphWidget::isPythonAvailable();
    
    setupUI();
    createButtons();
    createControls();
    createDropAreas();
}

MainWindow::~MainWindow()
{
}

void MainWindow::setupUI()
{
    centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    
    mainLayout = new QHBoxLayout(centralWidget);
    
    // Left side - buttons and controls
    buttonLayout = new QVBoxLayout();
    buttonLayout->setAlignment(Qt::AlignTop);
    mainLayout->addLayout(buttonLayout, 1);
    
    // Right side - drop areas with scroll
    scrollArea = new QScrollArea(this);
    scrollArea->setWidgetResizable(true);
    scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    
    scrollContent = new QWidget();
    dropAreasLayout = new QVBoxLayout(scrollContent);
    dropAreasLayout->setAlignment(Qt::AlignTop);
    
    scrollArea->setWidget(scrollContent);
    mainLayout->addWidget(scrollArea, 5);
    
    // Set window title and size
    setWindowTitle("Sensor Graph Display");
    resize(1200, 800);
}

void MainWindow::createButtons()
{
    // Create buttons
    shapeButton = new QPushButton("Shape", this);
    moveButton = new QPushButton("Move", this);
    resizeButton = new QPushButton("Resize", this);
    deleteButton = new QPushButton("Delete", this);
    addDropAreaButton = new QPushButton("Add Drop Area", this);
    
    // Style the buttons with explicit text color
    QString buttonStyle = "QPushButton { background-color: #f0f0f0; color: #000000; border: 1px solid #c0c0c0; border-radius: 4px; padding: 8px; margin: 5px; } "
                          "QPushButton:hover { background-color: #e0e0e0; } "
                          "QPushButton:pressed { background-color: #d0d0d0; } "
                          "QPushButton:checked { background-color: #c0c0c0; color: #000000; }";
    
    shapeButton->setStyleSheet(buttonStyle);
    moveButton->setStyleSheet(buttonStyle);
    resizeButton->setStyleSheet(buttonStyle);
    deleteButton->setStyleSheet(buttonStyle);
    addDropAreaButton->setStyleSheet(buttonStyle);
    
    // Make mode buttons checkable
    shapeButton->setCheckable(true);
    moveButton->setCheckable(true);
    resizeButton->setCheckable(true);
    deleteButton->setCheckable(true);
    
    // Add buttons to layout
    buttonLayout->addWidget(shapeButton);
    buttonLayout->addWidget(moveButton);
    buttonLayout->addWidget(resizeButton);
    buttonLayout->addWidget(deleteButton);
    buttonLayout->addWidget(addDropAreaButton);
    
    // Connect signals
    connect(shapeButton, &QPushButton::clicked, this, &MainWindow::onShapeButtonClicked);
    connect(moveButton, &QPushButton::clicked, this, &MainWindow::onMoveButtonClicked);
    connect(resizeButton, &QPushButton::clicked, this, &MainWindow::onResizeButtonClicked);
    connect(deleteButton, &QPushButton::clicked, this, &MainWindow::onDeleteButtonClicked);
    connect(addDropAreaButton, &QPushButton::clicked, this, &MainWindow::onAddDropAreaButtonClicked);
}

void MainWindow::createDropAreas()
{
    // Create initial drop areas (4 for example)
    for (int i = 0; i < 4; ++i) {
        DropArea* dropArea = new DropArea(this);
        connect(dropArea, &DropArea::fileDropped, this, [this, dropArea](const QString &filePath) {
            onFileDropped(filePath, dropArea);
        });
        
        dropAreasLayout->addWidget(dropArea);
        dropAreas.append(dropArea);
        
        // Create a placeholder for the graph widget (Qt version)
        GraphWidget* graphWidget = new GraphWidget(this);
        graphWidget->setVisible(false);
        dropAreasLayout->addWidget(graphWidget);
        graphWidgets.append(graphWidget);
        
        // Create a placeholder for the Python graph widget
        PythonGraphWidget* pythonGraphWidget = new PythonGraphWidget(this);
        pythonGraphWidget->setVisible(false);
        dropAreasLayout->addWidget(pythonGraphWidget);
        pythonGraphWidgets.append(pythonGraphWidget);
    }
}

void MainWindow::onShapeButtonClicked()
{
    if (shapeButton->isChecked()) {
        moveButton->setChecked(false);
        resizeButton->setChecked(false);
        deleteButton->setChecked(false);
        currentMode = 1;
    } else {
        currentMode = 0;
    }
    
    // Update all graph widgets with the current mode
    for (auto graphWidget : graphWidgets) {
        if (graphWidget->isVisible()) {
            graphWidget->setMode(currentMode);
        }
    }
}

void MainWindow::onMoveButtonClicked()
{
    if (moveButton->isChecked()) {
        shapeButton->setChecked(false);
        resizeButton->setChecked(false);
        deleteButton->setChecked(false);
        currentMode = 2;
    } else {
        currentMode = 0;
    }
    
    // Update all graph widgets with the current mode
    for (auto graphWidget : graphWidgets) {
        if (graphWidget->isVisible()) {
            graphWidget->setMode(currentMode);
        }
    }
}

void MainWindow::onResizeButtonClicked()
{
    if (resizeButton->isChecked()) {
        shapeButton->setChecked(false);
        moveButton->setChecked(false);
        deleteButton->setChecked(false);
        currentMode = 3;
    } else {
        currentMode = 0;
    }
    
    // Update all graph widgets with the current mode
    for (auto graphWidget : graphWidgets) {
        if (graphWidget->isVisible()) {
            graphWidget->setMode(currentMode);
        }
    }
}

void MainWindow::onDeleteButtonClicked()
{
    if (deleteButton->isChecked()) {
        shapeButton->setChecked(false);
        moveButton->setChecked(false);
        resizeButton->setChecked(false);
        currentMode = 4;
    } else {
        currentMode = 0;
    }
    
    // Update all graph widgets with the current mode
    for (auto graphWidget : graphWidgets) {
        if (graphWidget->isVisible()) {
            graphWidget->setMode(currentMode);
        }
    }
}





void MainWindow::onAddDropAreaButtonClicked()
{
    // Create a new drop area
    DropArea* dropArea = new DropArea(this);
    connect(dropArea, &DropArea::fileDropped, this, [this, dropArea](const QString &filePath) {
        onFileDropped(filePath, dropArea);
    });
    
    dropAreasLayout->addWidget(dropArea);
    dropAreas.append(dropArea);
    
    // Create a placeholder for the graph widget
    GraphWidget* graphWidget = new GraphWidget(this);
    graphWidget->setVisible(false);
    dropAreasLayout->addWidget(graphWidget);
    graphWidgets.append(graphWidget);
}

void MainWindow::createControls()
{
    // Create controls group box
    controlsGroupBox = new QGroupBox("Graph Controls", this);
    QVBoxLayout *controlsLayout = new QVBoxLayout(controlsGroupBox);
    
    // Interpolate checkbox
    interpolateCheckbox = new QCheckBox("Interpolate", this);
    controlsLayout->addWidget(interpolateCheckbox);
    
    // Python charts checkbox (only show if Python is available)
    if (PythonGraphWidget::isPythonAvailable()) {
        usePythonChartsCheckbox = new QCheckBox("Use Python Charts", this);
        usePythonChartsCheckbox->setChecked(false); // Always start with native charts
        controlsLayout->addWidget(usePythonChartsCheckbox);
        connect(usePythonChartsCheckbox, &QCheckBox::toggled, this, &MainWindow::onUsePythonChartsToggled);
    }
    
    // Axis labels
    QHBoxLayout *xAxisLayout = new QHBoxLayout();
    xAxisLabel = new QLabel("X-Axis Label:", this);
    xAxisLabelEdit = new QLineEdit("Time", this);
    xAxisLayout->addWidget(xAxisLabel);
    xAxisLayout->addWidget(xAxisLabelEdit);
    controlsLayout->addLayout(xAxisLayout);
    
    QHBoxLayout *yAxisLayout = new QHBoxLayout();
    yAxisLabel = new QLabel("Y-Axis Label:", this);
    yAxisLabelEdit = new QLineEdit("Value", this);
    yAxisLayout->addWidget(yAxisLabel);
    yAxisLayout->addWidget(yAxisLabelEdit);
    controlsLayout->addLayout(yAxisLayout);
    
    // Add controls to button layout
    buttonLayout->addWidget(controlsGroupBox);
    buttonLayout->addStretch();
    
    // Connect signals
    connect(interpolateCheckbox, &QCheckBox::toggled, this, &MainWindow::onInterpolateToggled);
    connect(xAxisLabelEdit, &QLineEdit::editingFinished, this, &MainWindow::onXAxisLabelChanged);
    connect(yAxisLabelEdit, &QLineEdit::editingFinished, this, &MainWindow::onYAxisLabelChanged);
}

void MainWindow::onFileDropped(const QString &filePath, DropArea *dropArea)
{
    QFileInfo fileInfo(filePath);
    
    // Check if it's a valid file
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        QMessageBox::warning(this, "Invalid File", "The dropped item is not a valid file.");
        return;
    }
    
    // Check file extension
    QString extension = fileInfo.suffix().toLower();
    if (extension != "csv" && extension != "json" && extension != "txt") {
        QMessageBox::warning(this, "Unsupported File Type", 
                             "Only CSV, JSON, and TXT files are supported.\n"
                             "Supported formats:\n"
                             "- CSV: time,value or value1,value2,... per line\n"
                             "- JSON: array of {time, value} objects\n"
                             "- TXT: value per line or time,value per line");
        return;
    }
    
    // Find the index of the drop area
    int index = dropAreas.indexOf(dropArea);
    if (index >= 0 && index < graphWidgets.size() && index < pythonGraphWidgets.size()) {
        // Hide the drop area
        dropArea->setVisible(false);
        
        if (usePythonCharts && PythonGraphWidget::isPythonAvailable()) {
            // Hide Qt graph widget and show Python graph widget
            graphWidgets[index]->setVisible(false);
            
            // Load the sensor data and display it in the Python graph widget
            pythonGraphWidgets[index]->loadDataFromFile(filePath);
            pythonGraphWidgets[index]->setVisible(true);
            
            // Set the file name as a label for the graph
            pythonGraphWidgets[index]->setTitle(fileInfo.fileName());
            
            // Set axis labels
            pythonGraphWidgets[index]->setXAxisLabel(xAxisLabelEdit->text());
            pythonGraphWidgets[index]->setYAxisLabel(yAxisLabelEdit->text());
            
            // Set interpolation
            pythonGraphWidgets[index]->setInterpolate(interpolateCheckbox->isChecked());
            
            // Connect the graph widget to the detached window handler
            connect(pythonGraphWidgets[index], &PythonGraphWidget::openInDetachedWindow, 
                    this, &MainWindow::onOpenInPythonDetachedWindow);
        } else {
            // Hide Python graph widget and show Qt graph widget
            pythonGraphWidgets[index]->setVisible(false);
            
            // Load the sensor data and display it in the graph widget
            graphWidgets[index]->loadDataFromFile(filePath);
            graphWidgets[index]->setVisible(true);
            
            // Set the file name as a label for the graph
            graphWidgets[index]->setTitle(fileInfo.fileName());
            
            // Set axis labels
            graphWidgets[index]->setXAxisLabel(xAxisLabelEdit->text());
            graphWidgets[index]->setYAxisLabel(yAxisLabelEdit->text());
            
            // Set interpolation
            graphWidgets[index]->setInterpolate(interpolateCheckbox->isChecked());
            
            // Connect the graph widget to the detached window handler
            connect(graphWidgets[index], &GraphWidget::openInDetachedWindow, 
                    this, &MainWindow::onOpenInDetachedWindow);
        }
    }
}

void MainWindow::onOpenInDetachedWindow(GraphWidget *widget)
{
    // Check if this widget already has a detached window
    if (detachedWindows.contains(widget)) {
        // If it does, just bring it to front
        detachedWindows[widget]->raise();
        detachedWindows[widget]->activateWindow();
        return;
    }
    
    // Create a new detached window
    DetachedGraphWindow *detachedWindow = new DetachedGraphWindow(this);
    
    // Transfer the graph data and properties
    detachedWindow->setDataSeries(widget->getDataSeries());
    detachedWindow->setTitle(widget->getTitle());
    detachedWindow->setGraphType(widget->getGraphType());
    detachedWindow->setGraphColor(widget->getGraphColor());
    detachedWindow->setAxisLabels(widget->getXAxisLabel(), widget->getYAxisLabel());
    detachedWindow->setInterpolate(widget->getInterpolate());
    
    // Connect the window closed signal
    connect(detachedWindow, &DetachedGraphWindow::windowClosed, 
            this, &MainWindow::onDetachedWindowClosed);
    
    // Store the detached window in the map
    detachedWindows[widget] = detachedWindow;
    
    // Show the detached window
    detachedWindow->show();
}

void MainWindow::onOpenInPythonDetachedWindow(PythonGraphWidget *widget)
{
    // Check if this widget already has a detached window
    if (pythonDetachedWindows.contains(widget)) {
        // If it does, just bring it to front
        pythonDetachedWindows[widget]->raise();
        pythonDetachedWindows[widget]->activateWindow();
        return;
    }
    
    // Create a new detached window
    PythonDetachedGraphWindow *detachedWindow = new PythonDetachedGraphWindow(this);
    
    // Transfer the graph data and properties
    detachedWindow->setDataSeries(widget->getDataSeries());
    detachedWindow->setTitle(widget->getTitle());
    detachedWindow->setGraphType(widget->getGraphType());
    detachedWindow->setGraphColor(widget->getGraphColor());
    detachedWindow->setAxisLabels(widget->getXAxisLabel(), widget->getYAxisLabel());
    detachedWindow->setInterpolate(widget->getInterpolate());
    
    // Connect the window closed signal
    connect(detachedWindow, &PythonDetachedGraphWindow::windowClosed, 
            this, &MainWindow::onDetachedWindowClosed);
    
    // Store the detached window in the map
    pythonDetachedWindows[widget] = detachedWindow;
    
    // Show the detached window
    detachedWindow->show();
}

void MainWindow::onDetachedWindowClosed()
{
    // Find the sender detached window
    DetachedGraphWindow *closedWindow = qobject_cast<DetachedGraphWindow*>(sender());
    if (closedWindow) {
        // Find the associated graph widget
        GraphWidget *associatedWidget = detachedWindows.key(closedWindow, nullptr);
        if (associatedWidget) {
            // Remove the window from the map
            detachedWindows.remove(associatedWidget);
        }
    } else {
        // Check if it's a Python detached window
        PythonDetachedGraphWindow *closedPythonWindow = qobject_cast<PythonDetachedGraphWindow*>(sender());
        if (closedPythonWindow) {
            // Find the associated Python graph widget
            PythonGraphWidget *associatedWidget = pythonDetachedWindows.key(closedPythonWindow, nullptr);
            if (associatedWidget) {
                // Remove the window from the map
                pythonDetachedWindows.remove(associatedWidget);
            }
        }
    }
    
    // The window will be deleted automatically by Qt's parent-child mechanism
}

void MainWindow::onInterpolateToggled(bool checked)
{
    if (usePythonCharts) {
        // Apply interpolation to the selected Python graph widget
        for (auto graphWidget : pythonGraphWidgets) {
            if (graphWidget->isVisible() && graphWidget->isSelected()) {
                graphWidget->setInterpolate(checked);
                
                // Update detached window if it exists
                if (pythonDetachedWindows.contains(graphWidget)) {
                    pythonDetachedWindows[graphWidget]->setInterpolate(checked);
                }
                break;
            }
        }
    } else {
        // Apply interpolation to the selected Qt graph widget
        for (auto graphWidget : graphWidgets) {
            if (graphWidget->isVisible() && graphWidget->isSelected()) {
                graphWidget->setInterpolate(checked);
                
                // Update detached window if it exists
                if (detachedWindows.contains(graphWidget)) {
                    detachedWindows[graphWidget]->setInterpolate(checked);
                }
                break;
            }
        }
    }
}

void MainWindow::onUsePythonChartsToggled(bool checked)
{
    usePythonCharts = checked;
    
    // Switch between Qt and Python graph widgets
    for (int i = 0; i < dropAreas.size(); ++i) {
        if (!dropAreas[i]->isVisible()) {
            // This drop area has a graph loaded
            if (i < graphWidgets.size() && i < pythonGraphWidgets.size()) {
                if (usePythonCharts) {
                    // Switch to Python graph widget
                    if (graphWidgets[i]->isVisible()) {
                        // Transfer data from Qt to Python widget
                        pythonGraphWidgets[i]->setDataSeries(graphWidgets[i]->getDataSeries());
                        pythonGraphWidgets[i]->setTitle(graphWidgets[i]->getTitle());
                        pythonGraphWidgets[i]->setGraphType(graphWidgets[i]->getGraphType());
                        pythonGraphWidgets[i]->setGraphColor(graphWidgets[i]->getGraphColor());
                        pythonGraphWidgets[i]->setXAxisLabel(graphWidgets[i]->getXAxisLabel());
                        pythonGraphWidgets[i]->setYAxisLabel(graphWidgets[i]->getYAxisLabel());
                        pythonGraphWidgets[i]->setInterpolate(graphWidgets[i]->getInterpolate());
                        
                        // Show Python widget, hide Qt widget
                        graphWidgets[i]->setVisible(false);
                        pythonGraphWidgets[i]->setVisible(true);
                        
                        // Connect signals
                        connect(pythonGraphWidgets[i], &PythonGraphWidget::openInDetachedWindow, 
                                this, &MainWindow::onOpenInPythonDetachedWindow, Qt::UniqueConnection);
                    }
                } else {
                    // Switch to Qt graph widget
                    if (pythonGraphWidgets[i]->isVisible()) {
                        // Transfer data from Python to Qt widget
                        graphWidgets[i]->setDataSeries(pythonGraphWidgets[i]->getDataSeries());
                        graphWidgets[i]->setTitle(pythonGraphWidgets[i]->getTitle());
                        graphWidgets[i]->setGraphType(pythonGraphWidgets[i]->getGraphType());
                        graphWidgets[i]->setGraphColor(pythonGraphWidgets[i]->getGraphColor());
                        graphWidgets[i]->setXAxisLabel(pythonGraphWidgets[i]->getXAxisLabel());
                        graphWidgets[i]->setYAxisLabel(pythonGraphWidgets[i]->getYAxisLabel());
                        graphWidgets[i]->setInterpolate(pythonGraphWidgets[i]->getInterpolate());
                        
                        // Show Qt widget, hide Python widget
                        pythonGraphWidgets[i]->setVisible(false);
                        graphWidgets[i]->setVisible(true);
                        
                        // Connect signals
                        connect(graphWidgets[i], &GraphWidget::openInDetachedWindow, 
                                this, &MainWindow::onOpenInDetachedWindow, Qt::UniqueConnection);
                    }
                }
            }
        }
    }
}

void MainWindow::onXAxisLabelChanged()
{
    QString label = xAxisLabelEdit->text();
    
    // Apply X-axis label to the selected graph widget
    for (auto graphWidget : graphWidgets) {
        if (graphWidget->isVisible() && graphWidget->isSelected()) {
            graphWidget->setXAxisLabel(label);
            
            // Update detached window if it exists
            if (detachedWindows.contains(graphWidget)) {
                detachedWindows[graphWidget]->setAxisLabels(label, graphWidget->getYAxisLabel());
            }
            break;
        }
    }
}

void MainWindow::onYAxisLabelChanged()
{
    QString label = yAxisLabelEdit->text();
    
    // Apply Y-axis label to the selected graph widget
    for (auto graphWidget : graphWidgets) {
        if (graphWidget->isVisible() && graphWidget->isSelected()) {
            graphWidget->setYAxisLabel(label);
            
            // Update detached window if it exists
            if (detachedWindows.contains(graphWidget)) {
                detachedWindows[graphWidget]->setAxisLabels(graphWidget->getXAxisLabel(), label);
            }
            break;
        }
    }
}
