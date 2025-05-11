#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("Sensor Graph Display");
    app.setOrganizationName("GraphApp");
    
    MainWindow mainWindow;
    mainWindow.setWindowTitle("Sensor Graph Display");
    mainWindow.resize(1024, 768);
    mainWindow.show();
    
    return app.exec();
}
