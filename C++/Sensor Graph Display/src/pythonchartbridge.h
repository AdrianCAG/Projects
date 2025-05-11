#ifndef PYTHONCHARTBRIDGE_H
#define PYTHONCHARTBRIDGE_H

#include <QString>
#include <QVector>
#include <QPair>
#include <QMap>
#include <QColor>
#include <QProcess>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QTemporaryDir>
#include <QList>
#include "sensordataparser.h"

class PythonChartBridge : public QObject
{
    Q_OBJECT
    
    // Friend class declaration for testing
    friend class TestPythonChartBridge;

public:
    PythonChartBridge();
    ~PythonChartBridge();
    
    // Initialize the Python environment
    static bool initialize();

public slots:
    // Initialize the Python environment asynchronously
    void initializeAsync();
    
    // Helper method for testing
    Q_INVOKABLE QVariant getProcessCount() const { return QVariant(s_pythonProcess ? 1 : 0); }
    
    // Start the persistent Python server process
    void startPythonServer();
    
    // Read output from the Python process
    void readProcessOutput();
    
    // Handle Python process termination
    void onPythonProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    
    // Generate a chart from multiple data series
    QString generateChart(const QMap<QString, SensorDataParser::DataSeries> &dataSeries,
                        const QString &title,
                        const QString &xAxisLabel,
                        const QString &yAxisLabel,
                        int chartType,
                        bool interpolate,
                        int width,
                        int height,
                        double xMin = -1.0,
                        double xMax = -1.0,
                        double yMin = -1.0,
                        double yMax = -1.0);
    
    // Generate a chart with sine waves (like in your screenshot 3)
    QString generateSineWaves(const QList<double> &frequencies,
                            const QList<double> &amplitudes,
                            const QList<double> &phases,
                            const QPair<double, double> &xRange,
                            int numPoints = 1000,
                            const QString &title = "Sine Waves",
                            int width = 800,
                            int height = 600);
    
    // Check if Python is available
    static bool isPythonAvailable();
    
private:
    // Convert Qt color to Python color string
    QString colorToString(const QColor &color);
    
    // Convert chart type to Python chart type string
    QString chartTypeToString(int chartType);
    
    // Create a JSON representation of the data
    QJsonDocument createJsonData(const QMap<QString, SensorDataParser::DataSeries> &dataSeries,
                              const QString &title,
                              const QString &xAxisLabel,
                              const QString &yAxisLabel,
                              const QString &chartType,
                              bool interpolate,
                              double xMin = -1.0,
                              double xMax = -1.0,
                              double yMin = -1.0,
                              double yMax = -1.0);
    
    // Static variables for Python environment
    static QString s_pythonPath;
    static QString s_scriptDir;
    static bool s_initialized;
    static bool s_initStarted;
    static int s_instanceCount;
    static QProcess *s_pythonProcess;
};

#endif // PYTHONCHARTBRIDGE_H
