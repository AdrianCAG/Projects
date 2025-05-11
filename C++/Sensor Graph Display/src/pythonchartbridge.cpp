#include "pythonchartbridge.h"
#include <QDebug>
#include <QDir>
#include <QProcess>
#include <QStandardPaths>
#include <QFileInfo>
#include <QCoreApplication>
#include <QTextStream>
#include <QColorSpace>
#include <QTimer>

// Static member initialization
QString PythonChartBridge::s_pythonPath;
QString PythonChartBridge::s_scriptDir;
bool PythonChartBridge::s_initialized = false;
bool PythonChartBridge::s_initStarted = false;
int PythonChartBridge::s_instanceCount = 0;
QProcess* PythonChartBridge::s_pythonProcess = nullptr;

PythonChartBridge::PythonChartBridge()
{
    // Increment instance counter
    s_instanceCount++;
    
    // Initialize the Python environment asynchronously
    QTimer::singleShot(0, this, SLOT(initializeAsync()));
}

PythonChartBridge::~PythonChartBridge()
{
    // Decrement instance counter
    s_instanceCount--;
    
    // Only terminate the Python process if this is the last instance
    if (s_instanceCount <= 0 && s_pythonProcess) {
        s_pythonProcess->terminate();
        if (!s_pythonProcess->waitForFinished(1000)) {
            s_pythonProcess->kill();
        }
        delete s_pythonProcess;
        s_pythonProcess = nullptr;
        s_instanceCount = 0; // Reset counter to be safe
    }
}

void PythonChartBridge::initializeAsync()
{
    if (!s_initialized) {
        initialize();
    }
    startPythonServer();
}

bool PythonChartBridge::initialize()
{
    // Prevent multiple initialization attempts
    if (s_initStarted) {
        return s_initialized;
    }
    
    s_initStarted = true;
    
    // Get application directory - the base directory for all relative paths
    QDir appDir(QCoreApplication::applicationDirPath());
    
    // On macOS, handle the case where we're inside a .app bundle
    #ifdef Q_OS_MAC
    if (appDir.absolutePath().contains(".app/Contents/MacOS")) {
        // Move up to the .app's parent directory for consistency
        appDir.cdUp(); // Move from MacOS to Contents
        appDir.cdUp(); // Move from Contents to .app
        appDir.cdUp(); // Move from .app to the parent directory
    }
    #endif
    
    qDebug() << "Application base directory:" << appDir.absolutePath();
    
    // Build a comprehensive list of places to look for the virtual environment
    QStringList possibleVenvLocations;
    
    // First check relative to the application directory (most common scenario)
    possibleVenvLocations << appDir.absolutePath() + "/venv";
    
    // Check parent directories (up to 3 levels)
    QDir parentDir = appDir;
    for (int i = 0; i < 3; i++) {
        if (parentDir.cdUp()) {
            possibleVenvLocations << parentDir.absolutePath() + "/venv";
        }
    }
    
    // Add the current working directory as another possibility
    possibleVenvLocations << QDir::currentPath() + "/venv";
    
    // Find venv directory
    QString venvPath;
    for (const auto &venvLocation : possibleVenvLocations) {
        QFileInfo venvInfo(venvLocation);
        if (venvInfo.exists() && venvInfo.isDir()) {
            venvPath = venvLocation;
            qDebug() << "Found virtual environment at:" << venvPath;
            break;
        }
    }
    
    // Build list of possible Python paths
    QStringList possiblePythonPaths;
    
    // First try Python from the venv if found
    if (!venvPath.isEmpty()) {
        #ifdef Q_OS_WIN
        possiblePythonPaths << venvPath + "/Scripts/python.exe";
        #else
        possiblePythonPaths << venvPath + "/bin/python";
        #endif
    }
    
    // Add system Python options as fallbacks
    possiblePythonPaths << "python3" << "python";
    
    // Add platform-specific Python locations
    #ifdef Q_OS_WIN
    possiblePythonPaths << "C:\\Python311\\python.exe"
                       << "C:\\Python310\\python.exe"
                       << "C:\\Python39\\python.exe"
                       << "C:\\Program Files\\Python311\\python.exe"
                       << "C:\\Program Files\\Python310\\python.exe"
                       << "C:\\Program Files\\Python39\\python.exe";
    #else
    possiblePythonPaths << "/usr/bin/python3"
                       << "/usr/local/bin/python3"
                       << "/opt/homebrew/bin/python3";
    #endif
    
    // Try each Python path
    for (const QString &path : possiblePythonPaths) {
        QProcess process;
        process.start(path, QStringList() << "--version");
        if (process.waitForFinished(1000)) {
            s_pythonPath = path;
            qDebug() << "Found Python at:" << path << "with version:" 
                    << QString(process.readAllStandardOutput()).trimmed();
            break;
        }
    }
    
    if (s_pythonPath.isEmpty()) {
        qWarning() << "Python not found, charts will not be available";
        s_initialized = false;
        return false;
    }
    
    // Find the Python scripts directory with a comprehensive search
    QStringList possibleScriptDirs;
    
    // Check in and around the application directory
    possibleScriptDirs << appDir.absolutePath() + "/python";
    
    // Check parent directories
    parentDir = appDir;
    for (int i = 0; i < 3; i++) {
        if (parentDir.cdUp()) {
            possibleScriptDirs << parentDir.absolutePath() + "/python";
        }
    }
    
    // Check platform-specific locations
    #ifdef Q_OS_MAC
    possibleScriptDirs << appDir.absolutePath() + "/../Resources/python"; // macOS bundle resources
    #endif
    
    // Check current directory
    possibleScriptDirs << QDir::currentPath() + "/python";
    
    // Debug output to help with troubleshooting
    qDebug() << "Searching for Python scripts in these locations:" << possibleScriptDirs;
    
    // Find the first directory that contains the chart generator script
    for (const QString &dir : possibleScriptDirs) {
        if (QFileInfo::exists(dir + "/chart_generator.py")) {
            s_scriptDir = dir;
            qDebug() << "Found Python scripts at:" << dir;
            break;
        }
    }
    
    if (s_scriptDir.isEmpty()) {
        qWarning() << "Python scripts directory not found, charts will not be available";
        s_initialized = false;
        return false;
    }
    
    s_initialized = true;
    return true;
}

void PythonChartBridge::startPythonServer()
{
    // Start a persistent Python process that stays running
    // Use a class-wide static process to ensure only one instance exists
    if (s_pythonProcess) {
        // Process already exists, no need to start again
        return;
    }
    
    s_pythonProcess = new QProcess();
    s_pythonProcess->setProcessChannelMode(QProcess::MergedChannels);
    
    // Connect signals to handle process output and errors
    connect(s_pythonProcess, SIGNAL(readyReadStandardOutput()), this, SLOT(readProcessOutput()));
    connect(s_pythonProcess, SIGNAL(finished(int, QProcess::ExitStatus)), 
            this, SLOT(onPythonProcessFinished(int, QProcess::ExitStatus)));
    
    // Use the run_with_venv.py wrapper script to ensure we use the virtual environment
    QStringList args;
    args << s_scriptDir + "/run_with_venv.py"
         << s_scriptDir + "/chart_generator.py"
         << "--preload";  // Add a flag to indicate preloading mode
    
    qDebug() << "Starting persistent Python process with args:" << args;
    
    // Start the process
    s_pythonProcess->start(s_pythonPath, args);
    
    if (!s_pythonProcess->waitForStarted(5000)) {
        qWarning() << "Failed to start Python process:" << s_pythonProcess->errorString();
        delete s_pythonProcess;
        s_pythonProcess = nullptr;
    } else {
        qDebug() << "Started persistent Python process for chart generation";
    }
}

void PythonChartBridge::readProcessOutput()
{
    if (s_pythonProcess) {
        QByteArray output = s_pythonProcess->readAllStandardOutput();
        if (!output.isEmpty()) {
            qDebug() << "Python output:" << output;
        }
    }
}

void PythonChartBridge::onPythonProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    if (exitCode != 0 || exitStatus != QProcess::NormalExit) {
        qWarning() << "Python process terminated with exit code" << exitCode;
        // Clear the process pointer
        s_pythonProcess = nullptr;
        // Restart the process if it crashed
        QTimer::singleShot(100, this, SLOT(startPythonServer()));
    }
}

QString PythonChartBridge::generateChart(const QMap<QString, SensorDataParser::DataSeries> &dataSeries,
                                       const QString &title,
                                       const QString &xAxisLabel,
                                       const QString &yAxisLabel,
                                       int chartType,
                                       bool interpolate,
                                       int width,
                                       int height,
                                       double xMin,
                                       double xMax,
                                       double yMin,
                                       double yMax)
{
    // Ensure Python is initialized
    if (!s_initialized && !s_initStarted) {
        // Try to initialize if not already started
        initialize();
    }
    
    // If the persistent Python process isn't running, start it
    if (!s_pythonProcess || s_pythonProcess->state() != QProcess::Running) {
        startPythonServer();
    }
    
    QJsonDocument jsonData = createJsonData(dataSeries, title, xAxisLabel, yAxisLabel, 
                                          chartTypeToString(chartType), interpolate,
                                          xMin, xMax, yMin, yMax);
    
    // Create temp file for JSON data
    QTemporaryDir tempDir;
    if (!tempDir.isValid()) {
        qWarning() << "Could not create temporary directory for chart data";
        return QString();
    }
    
    QString jsonFilePath = tempDir.path() + "/chart_data.json";
    QFile jsonFile(jsonFilePath);
    if (!jsonFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not create temporary JSON file:" << jsonFilePath;
        return QString();
    }
    
    jsonFile.write(jsonData.toJson());
    jsonFile.close();
    
    // Use a separate process for chart generation but with optimizations
    QProcess process;
    process.setProcessChannelMode(QProcess::MergedChannels);
    
    // Build command with arguments for optimized chart generation
    QStringList args;
    
    // Use run_with_venv.py wrapper to ensure proper environment
    args << s_scriptDir + "/run_with_venv.py";
    args << s_scriptDir + "/chart_generator.py";
    args << jsonFilePath;
    args << "--fast";  // Add a flag to indicate we want fast processing
    
    qDebug() << "Running Python chart generator with args:" << args;
    
    // Start the process
    process.start(s_pythonPath, args);
    
    if (!process.waitForStarted(1000)) {  // Reduced timeout
        qWarning() << "Failed to start Python process:" << process.errorString();
        return QString();
    }
    
    if (!process.waitForFinished(8000)) {  // Increased timeout slightly
        qWarning() << "Python process timed out:" << process.errorString();
        process.kill();
        return QString();
    }
    
    QByteArray output = process.readAll();
    qDebug() << "Python output:" << output;
    
    // Parse the output to find the generated chart path
    QString outputStr(output);
    QStringList lines = outputStr.split('\n');
    QString chartPath;
    
    for (const QString &line : lines) {
        if (line.contains("Chart generated:")) {
            chartPath = line.mid(line.indexOf("Chart generated:") + 16).trimmed();
            break;
        }
    }
    
    if (chartPath.isEmpty()) {
        qWarning() << "Could not find chart path in Python output";
        // Add debug output to see what we got
        qDebug() << "Full Python output:" << outputStr;
        return QString();
    }
    
    return chartPath;
}

QString PythonChartBridge::generateSineWaves(const QList<double> &frequencies,
                                            const QList<double> &amplitudes,
                                            const QList<double> &phases,
                                            const QPair<double, double> &xRange,
                                            int numPoints,
                                            const QString &title,
                                            int width,
                                            int height)
{
    // Create a simpler implementation that uses the main chart generator
    QMap<QString, SensorDataParser::DataSeries> seriesMap;
    
    // Generate the sine waves using the DataSeries structure
    double startX = xRange.first;
    double endX = xRange.second;
    double step = (endX - startX) / numPoints;
    
    for (int i = 0; i < frequencies.size(); ++i) {
        if (i >= amplitudes.size() || i >= phases.size()) {
            continue;
        }
        
        double freq = frequencies[i];
        double amp = amplitudes[i];
        double phase = phases[i];
        
        SensorDataParser::DataSeries series;
        series.name = QString("Sine %1 Hz").arg(freq);
        
        // Generate x and y values
        for (int j = 0; j < numPoints; ++j) {
            double x = startX + j * step;
            double y = amp * qSin(2 * M_PI * freq * x + phase);
            
            series.x.append(x);
            series.y.append(y);
        }
        
        // Assign a color based on the wave index
        QColor color = QColor::fromHsv(i * 50 % 360, 200, 220);
        series.color = color;
        
        // Add to the series map
        seriesMap[series.name] = series;
    }
    
    // Generate the chart using the main chart generator
    return generateChart(seriesMap, title, "Time (s)", "Amplitude", 0, true, width, height);
}

QString PythonChartBridge::colorToString(const QColor &color)
{
    // Convert QColor to a string format that Python/matplotlib can understand
    return QString("'#%1%2%3'").arg(color.red(), 2, 16, QChar('0'))
                              .arg(color.green(), 2, 16, QChar('0'))
                              .arg(color.blue(), 2, 16, QChar('0'));
}

QString PythonChartBridge::chartTypeToString(int chartType)
{
    switch (chartType) {
        case 0: return "line";
        case 1: return "scatter";
        case 2: return "bar";
        case 3: return "area";
        case 4: return "step";
        case 5: return "sine";
        default: return "line";
    }
}

QJsonDocument PythonChartBridge::createJsonData(const QMap<QString, SensorDataParser::DataSeries> &dataSeries,
                                              const QString &title,
                                              const QString &xAxisLabel,
                                              const QString &yAxisLabel,
                                              const QString &chartType,
                                              bool interpolate,
                                              double xMin,
                                              double xMax,
                                              double yMin,
                                              double yMax)
{
    QJsonObject jsonObj;
    jsonObj["title"] = title;
    jsonObj["x_label"] = xAxisLabel;
    jsonObj["y_label"] = yAxisLabel;
    jsonObj["chart_type"] = chartType;
    jsonObj["interpolate"] = interpolate;
    
    // Set axis limits if provided
    if (xMin != -1.0 && xMax != -1.0) {
        jsonObj["x_min"] = xMin;
        jsonObj["x_max"] = xMax;
    }
    
    if (yMin != -1.0 && yMax != -1.0) {
        jsonObj["y_min"] = yMin;
        jsonObj["y_max"] = yMax;
    }
    
    QJsonArray seriesArray;
    
    // Convert each data series to a JSON object
    for (auto it = dataSeries.begin(); it != dataSeries.end(); ++it) {
        QJsonObject seriesObj;
        seriesObj["name"] = it.key();
        
        // Get color from the series or generate one
        QColor color;
        if (it.value().color.isValid()) {
            color = it.value().color;
        } else {
            // Generate a color based on the series index
            int index = std::distance(dataSeries.begin(), it);
            color = QColor::fromHsv(index * 50 % 360, 200, 220);
        }
        
        seriesObj["color"] = colorToString(color);
        seriesObj["visible"] = it.value().visible;
        
        // Set line style and marker if available
        QString lineStyleStr;
        switch (it.value().lineStyle) {
            case 1: lineStyleStr = "--"; break;  // dashed
            case 2: lineStyleStr = ":"; break;   // dotted
            case 3: lineStyleStr = "-."; break;  // dash-dot
            default: lineStyleStr = "-"; break;  // solid
        }
        seriesObj["line_style"] = lineStyleStr;
        
        QString markerStr;
        switch (it.value().markerStyle) {
            case 1: markerStr = "o"; break;  // circle
            case 2: markerStr = "s"; break;  // square
            case 3: markerStr = "^"; break;  // triangle
            case 4: markerStr = "*"; break;  // star
            default: markerStr = ""; break;  // none
        }
        seriesObj["marker"] = markerStr;
        
        seriesObj["line_width"] = it.value().lineWidth;
        
        // Convert X and Y values to JSON arrays
        QJsonArray xArray, yArray;
        
        // Use the x and y vectors from the DataSeries
        for (const auto &x : it.value().x) {
            xArray.append(x);
        }
        
        for (const auto &y : it.value().y) {
            yArray.append(y);
        }
        
        seriesObj["x_values"] = xArray;
        seriesObj["y_values"] = yArray;
        
        seriesArray.append(seriesObj);
    }
    
    jsonObj["series"] = seriesArray;
    return QJsonDocument(jsonObj);
}

bool PythonChartBridge::isPythonAvailable()
{
    // Check if Python is available
    if (!s_initialized && !s_initStarted) {
        // Try to initialize if not already started
        initialize();
    }
    
    return s_initialized && !s_pythonPath.isEmpty() && !s_scriptDir.isEmpty();
}
