#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>
#include <QtCharts>
#include <QLabel>

class Widget : public QWidget
{
    Q_OBJECT

public:
    Widget(QWidget *parent = nullptr);
    ~Widget();

public slots:
    void setValue(float _value);
private:
    QChart *  createChart();
private:
    QLineSeries* series;
    QChartView * chartView;
    QLabel * label;
    float idx;
};
#endif // WIDGET_H
