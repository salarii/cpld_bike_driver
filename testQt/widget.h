#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include <QtCharts>
#include <QLabel>
#include <QSpinBox>

struct Measurement;

class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = nullptr);
    ~Widget();

signals:
    void sendToHardware(char _byte);


public slots:
    void serviceMeasurement(Measurement const * _value);
    void startMeasurement(bool _checked);
    void serialProblem();
private:
    QChart *  createChart();
private:
    QLineSeries* series;
    QChartView * chartView;
    QLabel * label;
    QSpinBox * force;
    float idx;
};
#endif // WIDGET_H
