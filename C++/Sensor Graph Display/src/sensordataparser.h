#ifndef SENSORDATAPARSER_H
#define SENSORDATAPARSER_H

#include <QString>
#include <QVector>
#include <QPair>
#include <QMap>
#include <QStringList>
#include <QColor>

class SensorDataParser
{
public:
    SensorDataParser();
    
    // Structure to hold multiple data columns
    struct DataSeries {
        QString name;
        QVector<double> x;
        QVector<double> y;
        QColor color = Qt::blue;
        bool visible = true;
        int lineStyle = 0;  // 0: solid, 1: dashed, 2: dotted, 3: dash-dot
        int markerStyle = 0; // 0: none, 1: circle, 2: square, 3: triangle, 4: star
        double lineWidth = 2.0;
    };
    
    // Parse sensor data from file with multiple columns
    static bool parseFile(const QString &filePath, QMap<QString, DataSeries> &dataSeries);
    
    // Legacy support for single column
    static bool parseFile(const QString &filePath, QVector<QPair<double, double>> &data);
    
    // Parse CSV file with headers
    static bool parseCSVFile(const QString &filePath, QMap<QString, DataSeries> &dataSeries);
    
    // Parse JSON file
    static bool parseJSONFile(const QString &filePath, QMap<QString, DataSeries> &dataSeries);
    
    // Generate sine wave data
    static DataSeries generateSineWave(double frequency, double amplitude, double phase,
                                     double startX, double endX, int numPoints);
    
    // Generate multiple sine waves
    static QMap<QString, DataSeries> generateMultipleSineWaves(
        const QVector<double> &frequencies,
        const QVector<double> &amplitudes,
        const QVector<double> &phases,
        double startX, double endX, int numPoints);
    
    // Detect file format
    static int detectFormat(const QString &filePath);
    
    // Get column names from CSV header
    static QStringList getColumnNames(const QString &filePath);
    
    // Different supported formats
    enum Format {
        FORMAT_UNKNOWN = -1,
        FORMAT_CSV_TIME_VALUE = 0,
        FORMAT_CSV_VALUE_ONLY = 1,
        FORMAT_JSON = 2,
        FORMAT_ARDUINO_SERIAL = 3,
        FORMAT_TXT = 4
    };
    
    // Chart types
    enum ChartType {
        CHART_LINE = 0,
        CHART_SCATTER = 1,
        CHART_BAR = 2,
        CHART_AREA = 3,
        CHART_STEP = 4,
        CHART_SINE = 5
    };
};

#endif // SENSORDATAPARSER_H
