#include "sensordataparser.h"
#include <QFile>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileInfo>
#include <QRegularExpression>
#include <QDebug>
#include <QtMath>

SensorDataParser::SensorDataParser()
{
}

QStringList SensorDataParser::getColumnNames(const QString &filePath)
{
    QStringList columnNames;
    QFile file(filePath);
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return columnNames;
    }
    
    QTextStream in(&file);
    if (!in.atEnd()) {
        QString headerLine = in.readLine().trimmed();
        
        // Check if this looks like a header (contains non-numeric values)
        bool isHeader = false;
        QStringList parts = headerLine.split(",");
        
        for (const QString &part : parts) {
            bool ok;
            part.toDouble(&ok);
            if (!ok && !part.isEmpty()) {
                isHeader = true;
                break;
            }
        }
        
        if (isHeader) {
            // Use header values as column names
            for (int i = 0; i < parts.size(); i++) {
                QString name = parts[i].trimmed();
                if (name.isEmpty()) {
                    name = QString("Column %1").arg(i);
                }
                columnNames.append(name);
            }
        } else {
            // No header, create default column names
            for (int i = 0; i < parts.size(); i++) {
                columnNames.append(QString("Column %1").arg(i));
            }
        }
    }
    
    file.close();
    return columnNames;
}

bool SensorDataParser::parseFile(const QString &filePath, QMap<QString, DataSeries> &dataSeries)
{
    dataSeries.clear();
    int format = detectFormat(filePath);
    
    switch (format) {
        case FORMAT_CSV_TIME_VALUE:
        case FORMAT_CSV_VALUE_ONLY:
        case FORMAT_TXT:
            return parseCSVFile(filePath, dataSeries);
            
        case FORMAT_JSON:
            return parseJSONFile(filePath, dataSeries);
            
        case FORMAT_ARDUINO_SERIAL:
            // For Arduino serial data, we should handle differently
            return parseCSVFile(filePath, dataSeries); // Default to CSV for now
            
        default:
            return false;
    }
}

bool SensorDataParser::parseCSVFile(const QString &filePath, QMap<QString, DataSeries> &dataSeries)
{
    QFile file(filePath);
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return false;
    }
    
    QTextStream in(&file);
    
    // Read the header line for column names
    QStringList columnNames;
    if (!in.atEnd()) {
        QString headerLine = in.readLine().trimmed();
        
        // Check if this looks like a header (contains non-numeric values)
        bool isHeader = false;
        QStringList parts = headerLine.split(",");
        
        for (const QString &part : parts) {
            bool ok;
            part.toDouble(&ok);
            if (!ok && !part.isEmpty()) {
                isHeader = true;
                break;
            }
        }
        
        if (isHeader) {
            // Use header values as column names
            for (int i = 0; i < parts.size(); i++) {
                QString name = parts[i].trimmed();
                if (name.isEmpty()) {
                    name = QString("Column %1").arg(i);
                }
                columnNames.append(name);
            }
        } else {
            // No header, create default column names and reset the file
            file.seek(0);
            for (int i = 0; i < parts.size(); i++) {
                columnNames.append(QString("Column %1").arg(i));
            }
        }
    }
    
    // Create data series for each column (except first if it's time/index)
    QVector<QVector<double>> columnData(columnNames.size());
    int format = detectFormat(filePath);
    int startColumn = (format == FORMAT_CSV_TIME_VALUE) ? 1 : 0;
    
    // Initialize column data vectors
    for (int i = 0; i < columnNames.size(); i++) {
        columnData[i] = QVector<double>();
    }
    
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) {
            continue;
        }
        
        QStringList parts = line.split(",");
        if (parts.size() != columnNames.size()) {
            continue; // Skip malformed lines
        }
        
        bool okX;
        double x = parts[0].toDouble(&okX);
        
        if (!okX) {
            continue; // Skip lines with non-numeric first column
        }
        
        // Add the x value (time/index) to the first column
        columnData[0].append(x);
        
        // Add each y value to its respective column
        for (int i = 1; i < parts.size(); i++) {
            bool okY;
            double y = parts[i].toDouble(&okY);
            if (okY) {
                columnData[i].append(y);
            } else {
                columnData[i].append(0.0); // Use 0 for non-numeric values
            }
        }
    }
    
    // Static list of colors for the series
    static const QColor colors[] = {
        QColor(0, 114, 189),  // Blue
        QColor(217, 83, 25),  // Orange
        QColor(237, 177, 32), // Yellow
        QColor(126, 47, 142), // Purple
        QColor(119, 172, 48), // Green
        QColor(77, 190, 238), // Light blue
        QColor(162, 20, 47),  // Dark red
        QColor(0, 128, 128),  // Teal
        QColor(218, 165, 32), // Goldenrod
        QColor(188, 143, 143), // Rosy brown
        QColor(139, 0, 139),  // Dark magenta
        QColor(85, 107, 47)   // Dark olive green
    };
    
    // Create data series for each column
    for (int i = startColumn; i < columnNames.size(); i++) {
        DataSeries series;
        series.name = columnNames[i].trimmed();
        series.color = colors[(i - startColumn) % 12];
        
        // Use time column for x values if available
        series.x = columnData[0];
        series.y = columnData[i];
        
        dataSeries[series.name] = series;
    }
    
    file.close();
    return !dataSeries.isEmpty();
}

bool SensorDataParser::parseJSONFile(const QString &filePath, QMap<QString, DataSeries> &dataSeries)
{
    QFile file(filePath);
    
    if (!file.open(QIODevice::ReadOnly)) {
        return false;
    }
    
    QByteArray jsonData = file.readAll();
    QJsonDocument document = QJsonDocument::fromJson(jsonData);
    
    if (document.isNull() || !document.isObject()) {
        return false;
    }
    
    QJsonObject root = document.object();
    
    // Check if this is our expected format
    if (root.contains("series") && root["series"].isArray()) {
        QJsonArray seriesArray = root["series"].toArray();
        
        for (int i = 0; i < seriesArray.size(); i++) {
            QJsonObject seriesObj = seriesArray[i].toObject();
            DataSeries series;
            
            // Parse series name
            if (seriesObj.contains("name")) {
                series.name = seriesObj["name"].toString();
            } else {
                series.name = QString("Series %1").arg(i + 1);
            }
            
            // Parse color if available
            if (seriesObj.contains("color")) {
                QString colorStr = seriesObj["color"].toString();
                if (colorStr.startsWith("#")) {
                    series.color = QColor(colorStr);
                }
            } else {
                // Use a default color from our palette
                static const QColor colors[] = {
                    QColor(0, 114, 189),  // Blue
                    QColor(217, 83, 25),  // Orange
                    QColor(237, 177, 32), // Yellow
                    QColor(126, 47, 142), // Purple
                    QColor(119, 172, 48), // Green
                    QColor(77, 190, 238)  // Light blue
                };
                series.color = colors[i % 6];
            }
            
            // Parse other series properties
            if (seriesObj.contains("visible")) {
                series.visible = seriesObj["visible"].toBool();
            }
            
            if (seriesObj.contains("lineStyle")) {
                series.lineStyle = seriesObj["lineStyle"].toInt();
            }
            
            if (seriesObj.contains("markerStyle")) {
                series.markerStyle = seriesObj["markerStyle"].toInt();
            }
            
            if (seriesObj.contains("lineWidth")) {
                series.lineWidth = seriesObj["lineWidth"].toDouble();
            }
            
            // Parse data points
            if (seriesObj.contains("x_values") && seriesObj.contains("y_values")) {
                QJsonArray xValues = seriesObj["x_values"].toArray();
                QJsonArray yValues = seriesObj["y_values"].toArray();
                
                // Get the minimum size to avoid out-of-bounds access
                int numPoints = qMin(xValues.size(), yValues.size());
                
                for (int j = 0; j < numPoints; j++) {
                    series.x.append(xValues[j].toDouble());
                    series.y.append(yValues[j].toDouble());
                }
            } else if (seriesObj.contains("data") && seriesObj["data"].isArray()) {
                QJsonArray dataArray = seriesObj["data"].toArray();
                
                for (int j = 0; j < dataArray.size(); j++) {
                    QJsonObject dataPoint = dataArray[j].toObject();
                    if (dataPoint.contains("x") && dataPoint.contains("y")) {
                        series.x.append(dataPoint["x"].toDouble());
                        series.y.append(dataPoint["y"].toDouble());
                    }
                }
            }
            
            // Add series to the map
            dataSeries[series.name] = series;
        }
    }
    
    file.close();
    return !dataSeries.isEmpty();
}

bool SensorDataParser::parseFile(const QString &filePath, QVector<QPair<double, double>> &data)
{
    data.clear();
    
    QFile file(filePath);
    
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return false;
    }
    
    int format = detectFormat(filePath);
    
    switch (format) {
        case FORMAT_CSV_TIME_VALUE:
            {
                QTextStream in(&file);
                
                // Check for header
                if (!in.atEnd()) {
                    QString line = in.readLine();
                    bool hasHeader = false;
                    
                    QStringList parts = line.split(",");
                    if (parts.size() >= 2) {
                        bool isNumber = false;
                        parts[0].toDouble(&isNumber);
                        if (!isNumber) {
                            hasHeader = true;
                        }
                    }
                    
                    if (!hasHeader) {
                        // If no header, reset to start
                        file.seek(0);
                    }
                }
                
                while (!in.atEnd()) {
                    QString line = in.readLine().trimmed();
                    if (line.isEmpty() || line.startsWith("#")) {
                        continue;
                    }
                    
                    QStringList parts = line.split(",");
                    if (parts.size() < 2) continue;
                    
                    bool okX, okY;
                    double x = parts[0].toDouble(&okX);
                    double y = parts[1].toDouble(&okY);
                    
                    if (okX && okY) {
                        data.append(qMakePair(x, y));
                    }
                }
            }
            break;
            
        case FORMAT_CSV_VALUE_ONLY:
            {
                QTextStream in(&file);
                int index = 0;
                
                // Check for header
                if (!in.atEnd()) {
                    QString line = in.readLine();
                    bool hasHeader = false;
                    
                    QStringList parts = line.split(",");
                    if (!parts.isEmpty()) {
                        bool isNumber = false;
                        parts[0].toDouble(&isNumber);
                        if (!isNumber) {
                            hasHeader = true;
                        }
                    }
                    
                    if (!hasHeader) {
                        // If no header, reset to start
                        file.seek(0);
                    }
                }
                
                while (!in.atEnd()) {
                    QString line = in.readLine().trimmed();
                    if (line.isEmpty() || line.startsWith("#")) {
                        continue;
                    }
                    
                    bool okY;
                    double y = line.toDouble(&okY);
                    
                    if (okY) {
                        data.append(qMakePair(static_cast<double>(index++), y));
                    }
                }
            }
            break;
            
        case FORMAT_JSON:
            {
                QByteArray jsonData = file.readAll();
                QJsonDocument doc = QJsonDocument::fromJson(jsonData);
                
                // Try to parse as array of objects with x,y
                if (doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (int i = 0; i < array.size(); ++i) {
                        QJsonObject obj = array[i].toObject();
                        if (obj.contains("x") && obj.contains("y")) {
                            double x = obj["x"].toDouble();
                            double y = obj["y"].toDouble();
                            data.append(qMakePair(x, y));
                        }
                    }
                }
                
                // If no data, try to parse as array of values
                if (data.isEmpty() && doc.isArray()) {
                    QJsonArray array = doc.array();
                    for (int i = 0; i < array.size(); ++i) {
                        double y = array[i].toDouble();
                        data.append(qMakePair(static_cast<double>(i), y));
                    }
                }
            }
            break;
            
        default:
            break;
    }
    
    file.close();
    return !data.isEmpty();
}

int SensorDataParser::detectFormat(const QString &filePath)
{
    // Check file extension
    QFileInfo fileInfo(filePath);
    QString extension = fileInfo.suffix().toLower();
    
    if (extension == "json") {
        return FORMAT_JSON;
    } else if (extension == "txt") {
        return FORMAT_TXT;
    }
    
    // Open and check content
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return FORMAT_UNKNOWN;
    }
    
    // Read first few lines
    QTextStream in(&file);
    QStringList lines;
    for (int i = 0; i < 5 && !in.atEnd(); ++i) {
        lines.append(in.readLine().trimmed());
    }
    
    file.close();
    
    // Check for JSON format
    if (!lines.isEmpty() && (lines[0].startsWith("{") || lines[0].startsWith("["))) {
        return FORMAT_JSON;
    }
    
    // Check for CSV format
    if (!lines.isEmpty()) {
        // Count commas in non-empty lines
        int commaLines = 0;
        for (const QString &line : lines) {
            if (!line.isEmpty() && line.contains(",")) {
                commaLines++;
            }
        }
        
        if (commaLines > 0) {
            // Check if first column looks like time
            bool hasTimeColumn = false;
            
            for (const QString &line : lines) {
                if (line.isEmpty() || line.startsWith("#")) continue;
                
                QStringList parts = line.split(",");
                if (parts.size() >= 2) {
                    bool ok;
                    parts[0].toDouble(&ok);
                    if (ok) {
                        hasTimeColumn = true;
                        break;
                    }
                }
            }
            
            return hasTimeColumn ? FORMAT_CSV_TIME_VALUE : FORMAT_CSV_VALUE_ONLY;
        }
    }
    
    // Default to time-value format
    return FORMAT_CSV_TIME_VALUE;
}

SensorDataParser::DataSeries SensorDataParser::generateSineWave(double frequency, double amplitude, 
                                                              double phase, double startX, 
                                                              double endX, int numPoints)
{
    DataSeries series;
    series.name = QString("Sine Wave (f=%1Hz, A=%2)").arg(frequency).arg(amplitude);
    
    double step = (endX - startX) / (numPoints - 1);
    
    for (int i = 0; i < numPoints; i++) {
        double x = startX + i * step;
        double y = amplitude * qSin(2 * M_PI * frequency * x + phase);
        
        series.x.append(x);
        series.y.append(y);
    }
    
    return series;
}

QMap<QString, SensorDataParser::DataSeries> SensorDataParser::generateMultipleSineWaves(
    const QVector<double> &frequencies,
    const QVector<double> &amplitudes,
    const QVector<double> &phases,
    double startX, double endX, int numPoints)
{
    QMap<QString, DataSeries> result;
    
    // Define a set of colors
    static const QColor colors[] = {
        QColor(0, 0, 255),      // Blue
        QColor(255, 0, 0),      // Red
        QColor(0, 255, 0),      // Green
        QColor(128, 0, 128),    // Purple
        QColor(255, 165, 0),    // Orange
        QColor(0, 128, 128)     // Teal
    };
    
    // Generate sine waves
    int count = qMin(frequencies.size(), qMin(amplitudes.size(), phases.size()));
    
    for (int i = 0; i < count; i++) {
        DataSeries series = generateSineWave(
            frequencies[i], 
            amplitudes[i], 
            phases[i], 
            startX, 
            endX, 
            numPoints
        );
        
        series.name = QString("Sine Wave %1").arg(i + 1);
        series.color = colors[i % 6];
        
        result[series.name] = series;
    }
    
    return result;
}
