#include "droparea.h"
#include <QPainter>
#include <QVBoxLayout>
#include <QMimeData>
#include <QUrl>

DropArea::DropArea(QWidget *parent)
    : QWidget(parent), isHighlighted(false)
{
    setAcceptDrops(true);
    setMinimumSize(200, 150);
    
    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->setAlignment(Qt::AlignCenter);
    
    messageLabel = new QLabel("Drop Arduino Sensor File Here", this);
    messageLabel->setAlignment(Qt::AlignCenter);
    layout->addWidget(messageLabel);
    
    // Set the style
    setStyleSheet("DropArea { background-color: #f0f0f0; border: 2px dashed #a0a0a0; border-radius: 8px; }");
}

DropArea::~DropArea()
{
}

void DropArea::dragEnterEvent(QDragEnterEvent *event)
{
    if (event->mimeData()->hasUrls()) {
        isHighlighted = true;
        setStyleSheet("DropArea { background-color: #e0e0e0; border: 2px dashed #606060; border-radius: 8px; }");
        event->acceptProposedAction();
    }
    update();
}

void DropArea::dragLeaveEvent(QDragLeaveEvent *event)
{
    isHighlighted = false;
    setStyleSheet("DropArea { background-color: #f0f0f0; border: 2px dashed #a0a0a0; border-radius: 8px; }");
    update();
    QWidget::dragLeaveEvent(event);
}

void DropArea::dragMoveEvent(QDragMoveEvent *event)
{
    if (event->mimeData()->hasUrls()) {
        event->acceptProposedAction();
    }
}

void DropArea::dropEvent(QDropEvent *event)
{
    if (event->mimeData()->hasUrls()) {
        QList<QUrl> urls = event->mimeData()->urls();
        if (!urls.isEmpty()) {
            QString filePath = urls.first().toLocalFile();
            emit fileDropped(filePath);
        }
    }
    
    isHighlighted = false;
    setStyleSheet("DropArea { background-color: #f0f0f0; border: 2px dashed #a0a0a0; border-radius: 8px; }");
    update();
    event->acceptProposedAction();
}

void DropArea::paintEvent(QPaintEvent *event)
{
    QWidget::paintEvent(event);
    
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    
    // Draw the "carved" look
    QColor shadowColor(0, 0, 0, 30);
    painter.setPen(Qt::NoPen);
    painter.setBrush(shadowColor);
    painter.drawRoundedRect(rect().adjusted(4, 4, 0, 0), 8, 8);
}
