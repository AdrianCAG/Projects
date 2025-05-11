#include "detachedgraphwindow.h"

DetachedGraphWindow::DetachedGraphWindow(QWidget *parent)
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
    connect(interpolateCheckbox, &QCheckBox::toggled, this, &DetachedGraphWindow::onInterpolateToggled);
    optionsLayout->addWidget(interpolateCheckbox);
    
    controlLayout->addWidget(optionsGroupBox);
    
    // Graph widget
    graphWidget = new GraphWidget(this);
    graphWidget->setMinimumSize(750, 400);
    mainLayout->addWidget(graphWidget, 1);
    
    // Connect signals
    connect(graphWidget, &GraphWidget::seriesVisibilityChanged, 
            this, &DetachedGraphWindow::onSeriesVisibilityChanged);
    
    // Set window properties
    setWindowTitle("Detached Graph View");
}

DetachedGraphWindow::~DetachedGraphWindow()
{
}

void DetachedGraphWindow::setGraphData(const QVector<QPair<double, double>> &data)
{
    graphWidget->setSensorData(data);
    updateSeriesControls();
}

void DetachedGraphWindow::setDataSeries(const QMap<QString, SensorDataParser::DataSeries> &series)
{
    graphWidget->setDataSeries(series);
    updateSeriesControls();
}

void DetachedGraphWindow::setAxisLabels(const QString &xLabel, const QString &yLabel)
{
    graphWidget->setXAxisLabel(xLabel);
    graphWidget->setYAxisLabel(yLabel);
}

void DetachedGraphWindow::setInterpolate(bool enabled)
{
    graphWidget->setInterpolate(enabled);
    interpolateCheckbox->setChecked(enabled);
}

void DetachedGraphWindow::updateSeriesControls()
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
        connect(checkbox, &QCheckBox::toggled, this, &DetachedGraphWindow::onCheckboxToggled);
        
        seriesLayout->addWidget(checkbox);
        seriesCheckboxes[seriesName] = checkbox;
    }
    
    // Add a spacer at the end
    seriesLayout->addStretch();
}

void DetachedGraphWindow::onSeriesVisibilityChanged(const QString &seriesName, bool visible)
{
    // Update the corresponding checkbox
    if (seriesCheckboxes.contains(seriesName)) {
        QCheckBox *checkbox = seriesCheckboxes[seriesName];
        checkbox->blockSignals(true);
        checkbox->setChecked(visible);
        checkbox->blockSignals(false);
    }
}

void DetachedGraphWindow::onCheckboxToggled(bool checked)
{
    QCheckBox *checkbox = qobject_cast<QCheckBox*>(sender());
    if (checkbox) {
        QString seriesName = checkbox->text();
        graphWidget->toggleSeriesVisibility(seriesName, checked);
    }
}

void DetachedGraphWindow::onInterpolateToggled(bool checked)
{
    graphWidget->setInterpolate(checked);
}

void DetachedGraphWindow::setTitle(const QString &title)
{
    titleLabel->setText(title);
    setWindowTitle("Graph: " + title);
}

void DetachedGraphWindow::setGraphType(int type)
{
    graphWidget->setGraphType(type);
}

void DetachedGraphWindow::setGraphColor(const QColor &color)
{
    graphWidget->setGraphColor(color);
}

void DetachedGraphWindow::closeEvent(QCloseEvent *event)
{
    emit windowClosed();
    event->accept();
}
