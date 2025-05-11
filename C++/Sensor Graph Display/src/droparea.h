#ifndef DROPAREA_H
#define DROPAREA_H

#include <QWidget>
#include <QLabel>
#include <QMimeData>
#include <QDragEnterEvent>
#include <QDropEvent>

class DropArea : public QWidget
{
    Q_OBJECT

public:
    explicit DropArea(QWidget *parent = nullptr);
    ~DropArea();

signals:
    void fileDropped(const QString &filePath);

protected:
    void dragEnterEvent(QDragEnterEvent *event) override;
    void dragLeaveEvent(QDragLeaveEvent *event) override;
    void dragMoveEvent(QDragMoveEvent *event) override;
    void dropEvent(QDropEvent *event) override;
    void paintEvent(QPaintEvent *event) override;

private:
    QLabel *messageLabel;
    bool isHighlighted;
};

#endif // DROPAREA_H
