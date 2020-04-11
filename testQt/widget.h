#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include "data_types.h"

#include <QtCharts>
#include <QLabel>
#include <QSpinBox>
#include <QPushButton>


struct Measurement;


class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = nullptr);
    ~Widget();

signals:
    void sendToHardware(unsigned char * _data, unsigned  _size);


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
    QSpinBox * pulseWidth;
    QSpinBox * frequency;
    QPushButton * startButton;
    unsigned char * sendBuff;

    float idx;
};
#endif // WIDGET_H
