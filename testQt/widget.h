#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include "data_types.h"

#include <QtCharts>
#include <QLabel>
#include <QSpinBox>
#include <QPushButton>
#include <QSlider>
#include <QComboBox>

struct Measurement;
struct FlashData;
const unsigned char  polyBase = 0x0;

class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = nullptr);
    ~Widget();

signals:
    void sendToHardware(unsigned char * _data, unsigned  _size);


public slots:
    void sendDataToFlash();
    void requestDataFromFlash();
    void displayFlash(FlashData const * _value);
    void serviceMeasurement(Measurement const * _value);
    void startMeasurement(bool _checked);
    void serialProblem();
private:
    QChart *  createChart();
private:
    QLineSeries* series;
    QChartView * chartView;
    QLabel * label;
    QLabel * parLabels[4];
    QSpinBox * pulseWidth;
    QSpinBox * frequency;
    QPushButton * startButton;
    QSlider * sliderSpeed;
    QSlider * sliderForce;
    QComboBox *  parameterList;
    QLineEdit * valInput;
    unsigned char * sendBuff;

    float idx;
};
#endif // WIDGET_H
